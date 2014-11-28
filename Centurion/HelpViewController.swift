//
//  HelpViewController.swift
//  Centurion
//
//  Created by Robbie Markwick on 11/28/14.
//
//

import UIKit
import iAd

class HelpViewController: UIViewController, UIScrollViewDelegate{

	@IBOutlet var pageView:UIScrollView!
	@IBOutlet var pageControl:UIPageControl!
	@IBOutlet var buyButton:UIButton!
	@IBOutlet var ad:ADBannerView!
	
	override func prefersStatusBarHidden() -> Bool {
		return true
	}
	var storeManager = StoreManager()
	
	override func viewDidLoad() {
		storeManager.delegate = self
		storeManager.loadProducts()
	}
	func scrollViewDidEndDecelerating(scrollView:UIScrollView){
		let pageWidth = scrollView.frame.size.width
		let page = Int(floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth)+1)
		pageControl.currentPage = page
	}
	override func viewDidAppear(animated: Bool) {
		pageView.contentSize = CGSize(width: pageView.frame.size.width*2, height: pageView.frame.size.height)
	}
	@IBAction func buy(sender:AnyObject){
		storeManager.buyProduct(archerProductID)
	}
	@IBAction func restore(sender:AnyObject){
		storeManager.restorePurchases()
	}
	@IBAction func dimiss(sender:AnyObject){
		dismissViewControllerAnimated(true, completion: nil)
	}
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension HelpViewController: StoreManagerDelegate, UIAlertViewDelegate {
		func confirmPurchaseForProduct(productName:String,price:String) {
			UIAlertView(title: "Confirm Purchase", message: "Buy \(productName) for \(price)", delegate: self, cancelButtonTitle:"No thanks", otherButtonTitles:"Yes").show()
		}
		func alertView(alertView: UIAlertView!, didDismissWithButtonIndex buttonIndex: Int){
			storeManager.confirmPurchase(buttonIndex==1)
		}
		func showAlreadyPurchased(productID:String){
		/*	buyButton.setTitle("PURCHASED!", forState: .Normal)
			buyButton.userInteractionEnabled = false
			buyButton.hidden = false*/
		}
		func hideButton(productID:String){
			//buyButton.hidden = true
		}
		func priceDidLoad(price:String,forProduct productID:String){
			//buyButton.setTitle(price, forState: .Normal)
			//buyButton.userInteractionEnabled = true
			//buyButton.hidden = false
		}
		func purchaseSuccessful() {
			UIAlertView(title: "Purchase Successful!", message: nil, delegate: nil, cancelButtonTitle: "OK").show()
		}
		func purchaseError(){
			UIAlertView(title: "Purchase Unsuccessful", message: "Please try again later", delegate: nil, cancelButtonTitle: "OK").show()
	}
}
extension HelpViewController: ADBannerViewDelegate {
	func bannerViewDidLoadAd(banner: ADBannerView!) {
		ad.hidden = false
	}
	func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
		ad.hidden = true
	}
}