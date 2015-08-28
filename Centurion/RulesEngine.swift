//
//  RulesEngine.swift
//  Centurion
//
//  Created by Robbie Markwick on 11/27/14.
//
//

import UIKit

enum Weapon{
	case Gladius
	case Pilum
}

class RulesEngine: NSObject {
	weak var field:BattleField?
	weak var game:GameViewController!
	var redArmy:[Soldier]=[]
	var blueArmy:[Soldier]=[]
	var turn = 1
	
	//MARK: Setup
	func createSoldiers(){
		//Red army
		redArmy += [game.createSoldier(.cavalry, 	army: .red,		location:Location(x: 2, y: 9))]
		redArmy += [game.createSoldier(.archer, 	army: .red,		location:Location(x: 4, y: 9))]
		redArmy += [game.createSoldier(.archer, 	army: .red,		location:Location(x: 6, y: 9))]
		redArmy += [game.createSoldier(.cavalry, 	army: .red,		location:Location(x: 8, y: 9))]
		redArmy += [game.createSoldier(.legionary, 	army: .red,		location:Location(x: 3, y: 8))]
		redArmy += [game.createSoldier(.legionary, 	army: .red,		location:Location(x: 5, y: 8))]
		redArmy += [game.createSoldier(.legionary, 	army: .red,		location:Location(x: 7, y: 8))]
		redArmy += [game.createSoldier(.cavalry, 	army: .red,		location:Location(x: 2, y: 7))]
		redArmy += [game.createSoldier(.legionary, 	army: .red,		location:Location(x: 4, y: 7))]
		redArmy += [game.createSoldier(.legionary, 	army: .red,		location:Location(x: 6, y: 7))]
		redArmy += [game.createSoldier(.cavalry, 	army: .red,		location:Location(x: 8, y: 7))]
		//Blue army
		blueArmy += [game.createSoldier(.cavalry, 	army: .blue,	location:Location(x: 2, y: 1))]
		blueArmy += [game.createSoldier(.archer,	army: .blue,	location:Location(x: 4, y: 1))]
		blueArmy += [game.createSoldier(.archer,	army: .blue,	location:Location(x: 6, y: 1))]
		blueArmy += [game.createSoldier(.cavalry, 	army: .blue,	location:Location(x: 8, y: 1))]
		blueArmy += [game.createSoldier(.legionary,	army: .blue,	location:Location(x: 3, y: 2))]
		blueArmy += [game.createSoldier(.legionary,	army: .blue,	location:Location(x: 5, y: 2))]
		blueArmy += [game.createSoldier(.legionary,	army: .blue,	location:Location(x: 7, y: 2))]
		blueArmy += [game.createSoldier(.cavalry,	army: .blue,	location:Location(x: 2, y: 3))]
		blueArmy += [game.createSoldier(.legionary,	army: .blue,	location:Location(x: 4, y: 3))]
		blueArmy += [game.createSoldier(.legionary,	army: .blue,	location:Location(x: 6, y: 3))]
		blueArmy += [game.createSoldier(.cavalry, 	army: .blue,	location:Location(x: 8, y: 3))]
	}
	//MARK: Health Levels
	func totalHealthForArmy(	army:Army)->Int{
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
	//MARK: Turn Management
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
	
	//MARK: Making Moves
	private func rollGladiusDice(var numRolls:Int)->Int{
		if numRolls > 10 { numRolls = 10 }
		var gladiusDamage = 0
		for _ in 0 ..< numRolls {
			if arc4random()%8 >= 3 { ++gladiusDamage }
		}
		return gladiusDamage
	}
	private func rollPilumDice(var numRolls:Int,range:Int)->Int{
		if numRolls > 10 { numRolls = 10 }
		var pilumDamage = 0
		for _ in 0 ..< numRolls {
			if Int(arc4random()%10) >= 5+abs(range-5) { ++pilumDamage }
		}
		return pilumDamage
	}
	private func rollDefenseDice(numRolls:Int,useExtraShields:Bool)->(Int,Int){
		var dodge = 0 , shield = 0
		for _ in 0 ..< numRolls {
			let roll = Int(arc4random()%8)
			if roll >= 7 { ++dodge }
			else if roll >= 4 { ++shield }
			else if roll >= 2 && useExtraShields { ++shield }
		}
		return (dodge,shield)
	}
	private func attackerRoll(soldier:Soldier, range:Int, weapon:Weapon)->Int{
		var hits:Int
		switch weapon {
		case .Gladius:
			hits = rollGladiusDice(soldier.gladius)
			soldier.gladius -= hits
		case .Pilum:
			hits = rollPilumDice(soldier.pilum, range: range)
			soldier.pilum -= min(10,soldier.pilum)
		}
		return hits
	}
	private func defenderRoll(soldier:Soldier,weapon:Weapon)->(Int,Int){
		let shieldPercent = soldier.scuta/Soldier.totalScutaForType(soldier.type)
		var (dodge, shield) = rollDefenseDice(Int(5 + 5*shieldPercent), useExtraShields: weapon == .Pilum)
		shield = min(shield, soldier.scuta)
		return (dodge,shield)
	}
	private func resolveDamage(hits hits:Int,dodge:Int,shield:Int,attacker:Soldier,defender:Soldier){
		//Attack takes effect
		let undodgedHits = max(hits-dodge,0)
		if shield > undodgedHits {
			defender.scuta -= undodgedHits
		} else {
			defender.scuta -= shield
			defender.health -= 5*(undodgedHits-shield)
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
	func executeMove(move:GameMove){
		switch move.type{
		case .Movement:
			move.soldierAttacker?.location = move.destination!
			takeTurn()
		case .Attack(.Gladius):
			let hits = attackerRoll(move.soldierAttacker!, range: 0, weapon: .Gladius)
			let (dodge,shield) = defenderRoll(move.soldierDefender!, weapon: .Gladius)
			resolveDamage(hits: hits, dodge: dodge, shield: shield, attacker: move.soldierAttacker!, defender: move.soldierDefender!)
		case .Attack(.Pilum):
			let range = Location.distance(move.soldierAttacker!.location, move.soldierDefender!.location)/2 + 1
			let hits = attackerRoll(move.soldierAttacker!, range: range, weapon: .Pilum)
			let (dodge,shield) = defenderRoll(move.soldierDefender!, weapon: .Pilum)
			resolveDamage(hits: hits, dodge: dodge, shield: shield, attacker: move.soldierAttacker!, defender: move.soldierDefender!)
		}
	}
	//MAKR: Move validity
	func moveIsLegal(move:GameMove)->Bool{
		guard let attacker = move.soldierAttacker else { return false }
		if attacker.army != currentArmy || attacker.health <= 0 { return false }
		switch move.type{
		case .Movement:
			guard let location = move.destination where
				location.x>=0 && location.x<=10 && location.y>=0 && location.y<=10 && !((location.x==0||location.x==10)&&(location.y==0||location.y==10)) else { return false }
			//Occupied
			guard let _ = field?[location].soldier else { return false }
			//out of range
			let dist = Location.distance(location, attacker.location)
			switch attacker.type{
			case .legionary: return dist <= 1
			case .cavalry: return dist <= 2
			case .archer: return dist <= 1
			}
		case .Attack(.Pilum):
			guard let enemy = move.soldierDefender else { return false }
			return attacker.pilum > 0 && enemy.army != attacker.army && enemy.health > 0
		case .Attack(.Gladius):
			guard let enemy = move.soldierDefender else { return false }
			return attacker.gladius > 0 && enemy.army != attacker.army && Location.distance(attacker.location, enemy.location) == 1 && enemy.health > 0
		}
	}
}





