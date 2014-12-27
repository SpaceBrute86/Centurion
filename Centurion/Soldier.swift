//
//  Soldier.swift
//  Centurion
//
//  Created by Robbie Markwick on 11/27/14.
//
//

import UIKit

enum SoldierType {
	case legionary
	case cavalry
	case archer
}
enum Army {
	case red
	case blue
}
struct Location {
	var x:Int
	var y:Int
	static func distance(loc1:Location,_ loc2:Location)->Int{
		return abs(loc2.x-loc1.x)+abs(loc2.y-loc1.y)
	}
	static func direction(loc1:Location,_ loc2:Location)->Double {
		return atan2(Double(loc2.x-loc1.x) ,Double(loc1.y-loc2.y))
	}
}
func + (lhs:Location,rhs:Location)->Location{
	return Location(x: lhs.x+rhs.x, y: lhs.y+rhs.y)
}
class Soldier: NSObject {
	var type:SoldierType = .legionary
	var army:Army = .red
	
	var health:Int
	var scuta:Int
	var pilum:Int
	var gladius:Int
	init(army:Army,type:SoldierType){
		self.army = army
		self.type = type
		health = Soldier.totalHealthForType(type)
		scuta = Soldier.totalScutaForType(type)
		pilum = Soldier.totalPilumForType(type)
		gladius = Soldier.totalGladiusForType(type)
	}

	var location:Location = Location(x: -1, y: -1)
	
	weak var view:SoldierView?
	weak var cell:BattleCell? {
		return view?.cell
	}
	
	class func totalScutaForType(type:SoldierType)->Int{
		switch type {
		case .legionary:return 100
		case .cavalry:	return 150
		case .archer:	return 50
		}
	}
	class func totalPilumForType(type:SoldierType)->Int{
		switch type {
		case .legionary:return 100
		case .cavalry:	return 150
		case .archer:	return 350
		}
	}
	class func totalGladiusForType(type:SoldierType)->Int{
		switch type {
		case .legionary:return 100
		case .cavalry:	return 150
		case .archer:	return 100
		}
	}
	class func totalHealthForType(type:SoldierType)->Int{
		switch type {
		case .legionary:return 100
		case .cavalry:	return 150
		case .archer:	return 100
		}
	}
}
