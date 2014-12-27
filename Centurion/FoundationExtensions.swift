//
//  FoundationExtensions.swift
//  StudyCards
//
//  Created by Robbie Markwick on 11/20/14.
//
//

import UIKit

//Null Pointers
let nullptr = UnsafeMutablePointer<()>.null()
let nullU8 = UnsafeMutablePointer<UInt8>.null()
let null16 = UnsafeMutablePointer<Int16>.null()
let null32 = UnsafeMutablePointer<Int32>.null()


func performAfterDelay(delay: Double,block: ()->() ){
	let nanoSeconds = Int64(delay * Double(NSEC_PER_SEC))
	let time : dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC)*delay))
	dispatch_after(time, dispatch_get_main_queue(),block)
}
extension NSSet{
	func isEmpty()->Bool{
		return count<=0
	}
}
func += (inout left:NSMutableSet,right:[AnyObject]){
	left.addObjectsFromArray(right)
}
func * (size: CGSize, scale:CGFloat) -> CGSize {
	return CGSize(width: size.width*scale, height: size.height*scale)
}
extension NSIndexSet {
	var allIndexes:[Int] {
		var indexes:[Int] = []
		self.enumerateIndexesUsingBlock { idx, stop in
			indexes += [idx]
		}
		return indexes
	}
}

extension NSUserDefaults{
	subscript(key: String)->AnyObject?{
		get{
			return objectForKey(key)
		}
		set(object){
			setObject(object, forKey: key)
		}
	}
}
extension NSUbiquitousKeyValueStore{
	subscript(key: String)->AnyObject?{
		get{
			return objectForKey(key)
		}
		set(object){
			setObject(object, forKey: key)
		}
	}
}

extension NSCache{
	subscript(key: String)->AnyObject?{
		get{
			return objectForKey(key)
		}
		set(obj){
			setObject(obj!, forKey: key)
		}
	}
}