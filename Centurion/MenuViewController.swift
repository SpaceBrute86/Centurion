//
//  ViewController.swift
//  Centurion
//
//  Created by Robbie Markwick on 11/27/14.
//
//

import UIKit

class MenuViewController: UIViewController {

	class func dismiss(){
		(UIApplication.sharedApplication().delegate as! AppDelegate).window?.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "1P" {
			(segue.destinationViewController as! GameViewController).isSingle = true
			//IS SINGLE PLAYER
		}
	}
}