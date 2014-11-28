//
//  RulesEngine.swift
//  Centurion
//
//  Created by Robbie Markwick on 11/27/14.
//
//

import UIKit

class RulesEngine: NSObject {
	weak var field:BattleField?
	weak var game:GameViewController!
	var redArmy:[Soldier]=[]
	var blueArmy:[Soldier]=[]
	var turn = 1
}
extension RulesEngine { //Setup
	func createSoldiers(){
		var archerType:SoldierType
		if checkPurchaseForProductID(archerProductID) {
			archerType = .archer
		} else {
			archerType = .legionary
		}
		//Red army
		redArmy += [game.createSoldier(.cavalry, army: .red, x: 2, y: 9)]
		redArmy += [game.createSoldier(archerType, army: .red, x: 4, y: 9)]
		redArmy += [game.createSoldier(archerType, army: .red, x: 6, y: 9)]
		redArmy += [game.createSoldier(.cavalry, army: .red, x: 8, y: 9)]
		redArmy += [game.createSoldier(.legionary, army: .red, x: 3, y: 8)]
		redArmy += [game.createSoldier(.legionary, army: .red, x: 5, y: 8)]
		redArmy += [game.createSoldier(.legionary, army: .red, x: 7, y: 8)]
		redArmy += [game.createSoldier(.cavalry, army: .red, x: 2, y: 7)]
		redArmy += [game.createSoldier(.legionary, army: .red, x: 4, y: 7)]
		redArmy += [game.createSoldier(.legionary, army: .red, x: 6, y: 7)]
		redArmy += [game.createSoldier(.cavalry, army: .red, x: 8, y: 7)]
		//Blue army
		blueArmy += [game.createSoldier(.cavalry, army: .blue, x: 2, y: 1)]
		blueArmy += [game.createSoldier(archerType, army: .blue, x: 4, y: 1)]
		blueArmy += [game.createSoldier(archerType, army: .blue, x: 6, y: 1)]
		blueArmy += [game.createSoldier(.cavalry, army: .blue, x: 8, y: 1)]
		blueArmy += [game.createSoldier(.legionary, army: .blue, x: 3, y: 2)]
		blueArmy += [game.createSoldier(.legionary, army: .blue, x: 5, y: 2)]
		blueArmy += [game.createSoldier(.legionary, army: .blue, x: 7, y: 2)]
		blueArmy += [game.createSoldier(.cavalry, army: .blue, x: 2, y: 3)]
		blueArmy += [game.createSoldier(.legionary, army: .blue, x: 4, y: 3)]
		blueArmy += [game.createSoldier(.legionary, army: .blue, x: 6, y: 3)]
		blueArmy += [game.createSoldier(.cavalry, army: .blue, x: 8, y: 3)]
	}
}
extension RulesEngine { //Health Levels
	func totalHealthForArmy(army:Army)->Int{
		switch army {
		case .red:	return redArmy.reduce(0) { $0 + Soldier.totalHealthForType($1.type) }
		case .blue:	return blueArmy.reduce(0) { $0 + Soldier.totalHealthForType($1.type) }
		}
	}
	var redHealth:Float{
		return Float(redArmy.reduce(0) { $0 + $1.health }) / Float(totalHealthForArmy(.red))
	}
	var blueHealth:Float{
		return Float(blueArmy.reduce(0) { $0 + $1.health }) / Float(totalHealthForArmy(.blue))
	}
}
extension RulesEngine { //Turn Management
	func isTurn(soldier:Soldier)->Bool {
		return currentArmy == soldier.army
	}
	var currentArmy:Army {
		if turn/2 == 0 {
			return .red
		} else {
			return .blue
		}
	}
	var isFirstMove:Bool {
		return turn%2 == 0
	}
	func takeTurn() {
		++turn;
		turn %= 4
		if isFirstMove {
			game.selectedSoldier = nil
			game.selectedWeapon = nil
			game.highlightCells()
			game.highlightHelmet()
			game.highlightButtons()
		}
	}

}
extension RulesEngine { //Making Moves
	enum Weapon{
		case gladius
		case pilum
	}
	func distanceBetweenSoldiers(soldier1:Soldier,_ soldier2:Soldier)->Int{
		return abs(soldier1.x-soldier2.x) + abs(soldier1.y-soldier2.y)
	}
	func rollGladiusDice(var numRolls:Int)->Int{
		if numRolls > 10 { numRolls = 10 }
		var gladiusDamage = 0
		for roll in 0 ..< numRolls {
			if arc4random()%8 >= 3 { ++gladiusDamage }
		}
		return gladiusDamage
	}
	func rollPilumDice(var numRolls:Int,range:Int)->Int{
		if numRolls > 10 { numRolls = 10 }
		var pilumDamage = 0
		for roll in 0 ..< numRolls {
			if Int(arc4random()%10) >= range { ++pilumDamage }
		}
		return pilumDamage
	}
	func rollDefenseDice(var numRolls:Int,useExtraShields:Bool)->(Int,Int){
		var dodge = 0 , shield = 0
		for roll in 0 ..< numRolls {
			let roll = Int(arc4random()%8)
			if roll >= 6 { ++dodge }
			else if roll >= 4 { ++shield }
			else if roll >= 2 && useExtraShields { ++shield }
		}
		return (dodge,shield)
	}
	func attackSoldier(defender:Soldier, withSoldier attacker:Soldier,weapon:Weapon){
		//Attacker rolls
		var hits:Int
		switch weapon {
		case .gladius:
			hits = rollGladiusDice(attacker.gladius)
			attacker.gladius -= hits
		case .pilum:
			let range = distanceBetweenSoldiers(attacker, defender)
			hits = rollPilumDice(attacker.pilum, range: range/3)
			attacker.pilum -= 10
			if attacker.pilum < 0 { attacker.pilum == 0 }
		}
		//Defender rolls
		let shieldPercent = defender.scuta/Soldier.totalScutaForType(defender.type)
		var (dodge, shield) = rollDefenseDice(Int(10 - 5*shieldPercent), useExtraShields: weapon == .pilum)
		if shield > defender.scuta { shield = defender.scuta }
		//Attack takes effect
		hits -= dodge
		if shield > hits {
			defender.scuta -= hits
		} else {
			defender.scuta -= shield
			defender.health -= (hits-shield)
		}
		//if soldier is dead
		if defender.health <= 0 {
			game.killSoldier(defender)
		}
		//show health
		let red = redHealth, blue = blueHealth
		game.showHealth(defender, redTotal: red, blueTotal: blue)
		//detect victory
		if blue <= 0.25 && blue < red/2 {
			game.performSegueWithIdentifier("RedWins", sender: self)
		} else if red <= 0.25 && red < blue/2 {
			game.performSegueWithIdentifier("BlueWins", sender: nil)
		}
		takeTurn()
	}
	func moveSoldier(soldier:Soldier, toX x:Int, toY y:Int){
		soldier.x = x
		soldier.y = y
		takeTurn()
	}
}
extension RulesEngine {//Move validity
	func soldierCanMove(soldier:Soldier,toX x:Int,toY y:Int)->Bool{
		if soldier.army != currentArmy { return false }
		//Out of bounds
		if x<0 || x>10 || y<0 || y>10 { return false }
		if (x==0||x==10)&&(y==0||y==10) { return false }
		//Occupied
		if field?.cells[x][y].soldier != nil { return false }
		//out of range
		let dist = abs(soldier.x-x)+abs(soldier.y-y)
		switch soldier.type{
		case .legionary: return dist == 1
		case .cavalry: return dist <= 2
		case .archer: return dist == 1
		}
	}
	func soldier(attacker:Soldier,canAttackSoldier defender:Soldier, weapon:Weapon)->Bool{
		if attacker.army != currentArmy || attacker.army == defender.army { return false }
		switch weapon {
		case .gladius:
			return attacker.gladius > 0 && distanceBetweenSoldiers(attacker, defender) == 1
		case .pilum:
			return attacker.pilum > 0
		}
	}
}





