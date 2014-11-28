//
//  StoreManager.swift
//  StudyCards
//
//  Created by Robbie Markwick on 11/20/14.
//
//


import Foundation
import StoreKit

@objc protocol StoreManagerDelegate {
	func confirmPurchaseForProduct(productName:String,price:String)
	func priceDidLoad(price:String,forProduct product:String)
	func showAlreadyPurchased(productID:String)
	func hideButton(productID:String)
	func purchaseSuccessful()
	func purchaseError()
}


class StoreManager: NSObject {
	
	weak var delegate:StoreManagerDelegate?
	
	var confirmQueue:[SKProduct]=[]
	var purchaseQueue:[SKProduct]=[]
	var archerProduct:SKProduct!
	
	func restorePurchases(){
		SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
	}
	func loadProductIDs()->NSSet {
		var requests = NSMutableSet()
		if checkPurchaseForProductID(archerProductID){
			delegate?.showAlreadyPurchased(archerProductID)
		} else {
			delegate?.hideButton(archerProductID)
			requests += [archerProductID]
		}
		return requests
	}
	func loadProducts() {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "purchaseSuccessful:", name: "FCReceiptCheckerSuccess", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "purchaseError:", name: "FCReceiptCheckerError", object: nil)
		SKPaymentQueue.defaultQueue().addTransactionObserver(self)
		//Set up requests
		let requests = loadProductIDs()
		if requests.count>0 {
			let request=SKProductsRequest(productIdentifiers: requests)
			request.delegate=self
			request.start()
		}
	}
	func productForID(productID:String)->SKProduct?{
		switch productID{
		case archerProductID: return archerProduct
		default: return nil
		}
	}
	func buyProduct(productID:String) {
		if let product = productForID(productID) {
			confirmQueue += [product]
			if confirmQueue.count == 1 {
				confirmOneProduct()
			}
		}
	}
	func confirmOneProduct() {
		if confirmQueue.count==0 {
			for product in purchaseQueue {
				let payment=SKPayment(product:product)
				SKPaymentQueue.defaultQueue().addPayment(payment)
			}
		}
		else {
			let product=confirmQueue[0]
			let price=priceForProduct(product)
			delegate?.confirmPurchaseForProduct(product.localizedTitle, price:price)
		}
	}
	func confirmPurchase(confirm:Bool){
		if confirm { purchaseQueue+=[confirmQueue[0]] }
		confirmQueue.removeAtIndex(0)
		confirmOneProduct()
	}
	func priceForProduct(product:SKProduct)->String{
		let numberFormatter=NSNumberFormatter()
		numberFormatter.numberStyle=NSNumberFormatterStyle.CurrencyStyle
		numberFormatter.locale=product.priceLocale
		return numberFormatter.stringFromNumber(product.price)!
	}
}


extension StoreManager: SKProductsRequestDelegate, SKPaymentTransactionObserver { //Store Kit Stuff
	func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
		for product in response.products as [SKProduct] {
			let price = priceForProduct(product)
			switch product.productIdentifier {
			case archerProductID:
				archerProduct=product
				delegate?.priceDidLoad(price,forProduct:product.productIdentifier)
			default:break
			}
		}
	}
	func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
		verifyReceiptForInAppPurchases(transactions: transactions as [SKPaymentTransaction])
	}
}


extension StoreManager{ //Receipt Notifications
	func purchaseSuccessful(notification:NSNotification){
		let productID=notification.object as String
		delegate?.showAlreadyPurchased(productID)
		delegate?.purchaseSuccessful()
	}
	func purchaseError(notification:NSNotification){
		delegate?.purchaseError()
	}
}
