//
//  LevelMeter.swift
//  Centurion
//
//  Created by Robbie Markwick on 11/27/14.
//
//

import UIKit

class LevelMeter: UIView {
	var blockView:UIView!
	func setup(image:UIImage?) {
		//Create Image Views
		let imgSize = frame.size.height
		let numIMGs = Int(floor(frame.size.width/imgSize))
		let spaceWidth = (frame.size.width%frame.size.height)/CGFloat(numIMGs-1)
		for i in 0..<numIMGs {
			let imgX = (imgSize+spaceWidth)*CGFloat(i)
			let imageView = UIImageView(frame:CGRect(x: imgX, y: 0.0, width: imgSize, height: imgSize))
			imageView.image = image
			addSubview(imageView)
		}
		//Create Block View
		blockView = UIView(frame: CGRect(x: frame.size.width, y: 0.0, width: frame.size.width, height: frame.size.height))
		blockView.backgroundColor = backgroundColor
		addSubview(blockView)
	}
	var _percent:Double = 0.0
	var percent:Double {
		get { return _percent }
		set (value) {
			_percent = value
			let blockCenter = CGFloat(0.5+_percent)*frame.size.width
			UIView.animateWithDuration(0.5) {
				self.blockView.center.x = blockCenter
			}
		}
	}

}
