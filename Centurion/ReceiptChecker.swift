//
//  ReceiptChecker.swift
//  FlashcardDoc
//
//  Created by Robbie Markwick on 7/28/14.
//  Copyright (c) 2014 Markwick. All rights reserved.
//


import Foundation
import StoreKit;

var lastLoad:NSDate=NSDate()
var purchases:[String:AnyObject]!

// Refresh
let cryptoKey=UIDevice.currentDevice().identifierForVendor.UUIDString

class ReceiptRefreshObserver:NSObject,SKRequestDelegate {
	func requestDidFinish(request:SKRequest){
		verifyReceiptForInAppPurchases();
	}
	func request(request:SKRequest,didFailWithError error:NSError){
		dispatch_async(dispatch_get_main_queue(),{
			NSNotificationCenter.defaultCenter().postNotificationName("ReceiptCheckerError", object: nil)
		})
	}
	
}
var refreshObserver=ReceiptRefreshObserver()

func receiptFail(){
	let request = SKReceiptRefreshRequest()
	request.delegate=refreshObserver
	request.start()
}

let archerProductID = "Archery"


//Cryptography
enum cryptoOp{
	case DECRYPT
	case ENCRYPT
}
func multiCrypto(op:cryptoOp, times:UInt, data:NSData, key:String=cryptoKey)->NSData {
	if times == 0 { return data }
	let prevCrypto=multiCrypto(op, times-1, data, key: key)
	return crypto(op, prevCrypto, key: key)!
}
func crypto(op:cryptoOp, data:NSData, key: String = cryptoKey)->NSData?{
	var keyPtr=key.cStringUsingEncoding(NSUTF8StringEncoding)!
	while keyPtr.count > kCCKeySizeAES256 { keyPtr.removeLast() }
	while keyPtr.count < (kCCKeySizeAES256 + 1) { keyPtr += [0] }
	
	let dataLength =  UInt(data.length)
	let bufferSize = dataLength + UInt(kCCBlockSizeAES128)
	var buffer = malloc(bufferSize)
	
	var numBytesEncrypted:UInt=0
	let operation = CCOperation(op == .DECRYPT ? kCCDecrypt : kCCEncrypt)
	let algorithm = CCAlgorithm(kCCAlgorithmAES128)
	let options = CCOptions(kCCOptionPKCS7Padding)
	let keyLen = UInt(kCCKeySizeAES256)
	let cryptStatus = CCCrypt(operation, algorithm, options, keyPtr, keyLen, nullptr, data.bytes, dataLength, buffer, bufferSize, &numBytesEncrypted)
	if cryptStatus == CCCryptorStatus(kCCSuccess) {
		var data=NSMutableData()
		data.appendBytes(buffer, length: Int(bufferSize))
	}
	free(buffer)
	return nil
}

//Save and load
let cryptoFileName="__LKM_RNM__"

func saveDictionary(dictionary:[String:AnyObject]){
	purchases=dictionary
	lastLoad=NSDate()
	//Encrypt dictionary data
	let JSONData=NSJSONSerialization.dataWithJSONObject(dictionary, options: nil, error: nil)!
	let encryptedData=multiCrypto(.ENCRYPT,2, JSONData)
	//Save Data
	let directory=NSFileManager.defaultManager().URLsForDirectory(.LibraryDirectory, inDomains: .UserDomainMask)[0] as NSURL
	let file=directory.URLByAppendingPathComponent(cryptoFileName)
	encryptedData.writeToURL(file, atomically: true)
}

func loadDictionary(wait:Bool){
	if BETA{
		purchases=[archerProductID:["product_id":archerProductID]]
		lastLoad=NSDate()
	} else {
		let loadBlock: ()->() = {
			let directory=NSFileManager.defaultManager().URLsForDirectory(.LibraryDirectory, inDomains: .UserDomainMask)[0] as NSURL
			let file=directory.URLByAppendingPathComponent(cryptoFileName)
			if NSFileManager.defaultManager().fileExistsAtPath(file.path!) {
				let encryptedData=NSData(contentsOfURL: file)
				let JSONData=multiCrypto(.DECRYPT,2, encryptedData!)
				purchases=NSJSONSerialization.JSONObjectWithData(JSONData, options: nil, error: nil) as [String:AnyObject]
			} else {
				purchases=Dictionary<String,AnyObject>()
			}
			lastLoad=NSDate()
		}
		if wait { loadBlock() }
		else { dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), loadBlock) }
	}
}
func checkPurchaseForProductID(product:String)->Bool {
	if purchases == nil || lastLoad.timeIntervalSinceNow>=1024{
		loadDictionary(true)
	}
	if let index=purchases!.indexForKey(product){
		let (_,receipt: AnyObject) = purchases![index]
		if let receiptInfo = receipt as? [String:AnyObject] {
			if let index2=receiptInfo.indexForKey("product_id"){
				let (_,receiptProductID: AnyObject) = receiptInfo[index2]
				if (receiptProductID as String) == product { return true }
			}
		}
	}
	return false
}

// Receipt Checking

let sandboxURL = NSURL(string:"https://sandbox.itunes.apple.com/verifyReceipt")!
#if DEBUG
	let validationURL=sandboxURL
	#else
let validationURL=NSURL(string:"https://buy.itunes.apple.com/verifyReceipt")!
#endif

func performLaunchReceiptCheck(){
	if BETA {
		loadDictionary(false)
	} else {
		let fm = NSFileManager.defaultManager()
		let receiptURL=NSBundle.mainBundle().appStoreReceiptURL!
		if !fm.fileExistsAtPath(receiptURL.path!) { receiptFail() }
		if arc4random()%20 == 0 { verifyReceiptForInAppPurchases() }
	}
}
func verifyReceiptForInAppPurchases(transactions:[SKPaymentTransaction]=[]){
	if BETA{
		loadDictionary(false)
	} else {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)){
			verifyReceiptForInAppPurchasesWithServer(validationURL,transactions)
		}
	}
}
func verifyReceiptForInAppPurchasesWithServer(serverURL:NSURL, transactions:[SKPaymentTransaction]){
	let receiptURL=NSBundle.mainBundle().appStoreReceiptURL
	if NSFileManager.defaultManager().fileExistsAtPath(receiptURL!.path!) {
		//set up receipt request
		let receiptData = NSData(contentsOfURL: receiptURL!)
		let base64Receipt=receiptData!.base64EncodedDataWithOptions(nil)
		let requestDictionary=["receipt-data":base64Receipt]
		let jsonData=NSJSONSerialization.dataWithJSONObject(requestDictionary, options: nil, error: nil)
		//Set up network request
		let netRequest=NSMutableURLRequest(URL:serverURL)
		netRequest.HTTPMethod="POST"
		netRequest.HTTPBody=jsonData
		let session=NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: nil, delegateQueue: NSOperationQueue.mainQueue())
		session.dataTaskWithRequest(netRequest){ data, response, error in
			if error != nil {
				dispatch_async(dispatch_get_main_queue()){
					NSNotificationCenter.defaultCenter().postNotificationName("ReceiptCheckerError", object: nil)
				}
				return
			}
			var wrongServer=false
			let receipt=checkReceiptValidity(data, &wrongServer, transactions)
			if receipt == nil && !wrongServer {
				receiptFail()
			} else if let appReceipt=receipt {
				var inAppReceipts=Dictionary<String,AnyObject>()
				let dicIndex=appReceipt.indexForKey("in_app")
				let (_,inApps: AnyObject)=appReceipt[dicIndex!]
				for purchase in inApps as [[String:AnyObject]]{
					let productID: AnyObject?=purchase["product_id"]
					inAppReceipts[productID as String]=purchase;
					dispatch_async(dispatch_get_main_queue()){
						NSNotificationCenter.defaultCenter().postNotificationName("ReceiptCheckerSuccess", object: nil)
					}
				}
				saveDictionary(inAppReceipts)
				for transaction in transactions {
					SKPaymentQueue.defaultQueue().finishTransaction(transaction)
				}
			}
			}.resume()
	} else {
		receiptFail()
	}
	
}
func checkReceiptValidity(receiptData:NSData,inout wrongServer:Bool,transactions:[SKPaymentTransaction])->[String:AnyObject]?{
	if let responseDictionary = NSJSONSerialization.JSONObjectWithData(receiptData, options: .AllowFragments, error: nil) as? [String:AnyObject] {
		if (responseDictionary["status"] as NSNumber).integerValue == 21007 {
			verifyReceiptForInAppPurchasesWithServer(sandboxURL, transactions)
			wrongServer=true
			return nil
		}
		if let receipt: AnyObject! = responseDictionary["receipt"] {
			let bundleID: AnyObject! = NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleIdentifierKey)
			let bundleVersion: AnyObject! = NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey)
			let rBundleID: AnyObject! = (receipt as [String:AnyObject])["bundle_id"]
			let rBundleVersion: AnyObject! = (receipt as [String:AnyObject])["application_version"]
			if (bundleID as String) == (rBundleID as String) && (bundleVersion as String) == (rBundleVersion as String) {
				return receipt as? [String:AnyObject]
			}
		}
	}
	return nil
}

