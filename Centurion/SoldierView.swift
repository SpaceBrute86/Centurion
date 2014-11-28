//
//  SoldierView.swift
//  Centurion
//
//  Created by Robbie Markwick on 11/27/14.
//
//

import UIKit

class SoldierView: UIView {
	weak var cell:BattleCell?
	var soldier:Soldier
	var healthBar:UIProgressView
	var imageView:UIImageView
	
	init(frame:CGRect,army:Army,type:SoldierType){
		soldier = Soldier(army: army, type: type)
		imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: frame.size))
		healthBar = UIProgressView(progressViewStyle: .Bar)
		healthBar.trackTintColor = UIColor(white: 0.2, alpha: 0.3)
		healthBar.progressTintColor = UIColor(red: 0.4, green: 0, blue: 0.6, alpha: 0.75)
		healthBar.transform = CGAffineTransformMakeScale(1, 0.5)
		healthBar.progress = 1
		var imageName = ""
		switch soldier.army {
		case .red:
			healthBar.frame = CGRectMake(1, frame.size.height-3, frame.size.width-2, 1)
			imageName += "Red"
		case .blue:
			healthBar.frame = CGRectMake(1, 1, frame.size.width-2, 1)
			healthBar.transform = CGAffineTransformRotate(healthBar.transform,CGFloat(M_PI))
			imageName += "Blue"
		}
		switch soldier.type {
		case .legionary: imageName += "Legion"
		case .cavalry: imageName += "Cavalry"
		case .archer: imageName += "Archer"
		}
		imageView.image = UIImage(named: "\(imageName).png")
		super.init(frame: frame)
		soldier.view = self
		addSubview(imageView)
		addSubview(healthBar)
	}

	required init(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}

}
func weaponViewForWeapon(weapon:RulesEngine.Weapon,angle:CGFloat) -> UIImageView {
	var img:UIImageView
	switch weapon {
	case .pilum: img = UIImageView(image: UIImage(named: "Spear.png"))
	case .gladius: img = UIImageView(image: UIImage(named: "Sword.png"))
	}
	img.opaque = false;
	img.transform=CGAffineTransformMakeRotation( angle-CGFloat(M_PI_2) )
	return img
	
}






