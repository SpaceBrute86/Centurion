//
//  WinnerViewController.swift
//  Centurion
//
//  Created by Robbie Markwick on 11/28/14.
//
//

import UIKit

class WinnerViewController: UIViewController {
	
	@IBOutlet var imageView:UIImageView?
	@IBOutlet var textLabel:UILabel?
	
	var winningArmy:Army = .red

	@IBAction func done(sender:AnyObject){
		MenuViewController.dismiss()
	}
	override func prefersStatusBarHidden() -> Bool {
		return true
	}
    override func viewDidLoad() {
        super.viewDidLoad()
		switch winningArmy {
		case .red:
			imageView?.image = UIImage(named: "RedHelmet.png")
			textLabel?.text = "Red Wins"
		case .blue:
			imageView?.image = UIImage(named: "BlueHelmet.png")
			textLabel?.text = "Blue Wins"
			view.transform = CGAffineTransformMake(-1, 0, 0, -1, 0, 0)
		}
    }

}
