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
	@IBOutlet var ad:ADBannerView!

	func scrollViewDidEndDecelerating(scrollView:UIScrollView){
		let pageWidth = scrollView.frame.size.width
		let page = Int(floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth)+1)
		pageControl.currentPage = page
	}
	override func prefersStatusBarHidden() -> Bool {
		return true
	}
	override func viewDidAppear(animated: Bool) {
		pageView.contentSize = CGSize(width: pageView.frame.size.width*6, height: pageView.frame.size.height)
	}
	@IBAction func dimiss(sender:AnyObject){
		dismissViewControllerAnimated(true, completion: nil)
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