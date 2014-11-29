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

class Soldier: NSObject {
	var type:SoldierType = .legionary
	var army:Army = .red
	
	var health:Int
	var scuta:Int
	var pilum:Int
	var gladius:Int
	var archerDodged = false
	init(army:Army,type:SoldierType){
		self.army = army
		self.type = type
		health = Soldier.totalHealthForType(type)
		scuta = Soldier.totalScutaForType(type)
		pilum = Soldier.totalPilumForType(type)
		gladius = Soldier.totalGladiusForType(type)
	}

	
	var x:Int = -1
	var y:Int = -1
	
	weak var view:SoldierView?
	weak var cell:BattleCell? {
		return view?.cell
	}
	var attackableSoldiers:[Soldier] = []
	
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
