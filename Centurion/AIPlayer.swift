//
//  AIPlayer.swift
//  Centurion
//
//  Created by Robbie Markwick on 12/26/14.
//
//

import Foundation

let AIQueue = NSOperationQueue()

struct AIPlayer {
	var soldiers:[Soldier] { return rules.blueArmy }
	var enemies:[Soldier] { return rules.redArmy }
	var rules:RulesEngine
	
	private func rankMove(move:GameMove)->Int {
		switch move.type{
		case .Movement:
			var center = Location(x: 0, y: 0)
			for enemy in enemies {
				center = center + enemy.location
			}
			center.x /= enemies.count
			center.y /= enemies.count
			
			var oldDist = abs(move.soldierAttacker!.location.x - center.x) + abs(move.soldierAttacker!.location.y - center.y)
			var newDist = abs(move.destination!.x - center.x) + abs(move.destination!.y - center.y)
			return oldDist > newDist ? oldDist-newDist/2 : 0
		case .Attack(.Gladius):
			let hits = min(move.soldierAttacker!.gladius, 10) * 5/8
			let enemyRolls = Int(10 - 5*(move.soldierDefender!.scuta/Soldier.totalScutaForType(move.soldierDefender!.type)))
			let dodge = enemyRolls * 2/8
			let shield = min(move.soldierDefender!.scuta, enemyRolls * 2/8)
			return (hits - dodge - shield/2) * 2
		case .Attack(.Pilum):
			var range = Location.distance(move.soldierAttacker!.location, move.soldierDefender!.location)/2 + 1
			if move.soldierAttacker!.type == .archer { --range }
			let hits = min(move.soldierAttacker!.pilum, 10) * (5-abs(range-5))/10
			let enemyRolls = Int(5 + 5*(move.soldierDefender!.scuta/Soldier.totalScutaForType(move.soldierDefender!.type)))
			let dodge = enemyRolls * 2/8
			let shield = min(move.soldierDefender!.scuta, enemyRolls * 4/8)
			return (hits - dodge - shield/2)
		}
	}
	
	private func calculatePossibleMoves()->[GameMove]{
		var possibleMoves:[GameMove] = []
		for soldier in soldiers {
			//Movements
			for x in 0..<11 {
				for y in 0..<11 {
					let move = GameMove(type: .Movement, soldierAttacker: soldier, soldierDefender: nil, destination: Location(x: x, y: y))
					if self.rules.moveIsLegal(move){
						possibleMoves += [move]
					}
				}
			}
			//Attacks
			for enemy in enemies {
				let gladius = GameMove(type: .Attack(.Gladius), soldierAttacker: soldier, soldierDefender: enemy, destination: nil)
				if self.rules.moveIsLegal(gladius){
					possibleMoves += [gladius]
				}
				let pilum = GameMove(type: .Attack(.Pilum), soldierAttacker: soldier, soldierDefender: enemy, destination: nil)
				if self.rules.moveIsLegal(pilum){
					possibleMoves += [pilum]
				}
			}
		}
		return possibleMoves
	}
	private func pickMove(moves:[GameMove])->GameMove{
		var i=0
		for ; arc4random()%1 != 0; i = (i+1)%moves.count { }
		return moves[i]
	}
	func chooseMove(completion:(GameMove)->()){
		AIQueue.addOperationWithBlock{
			var possibleMoves:[GameMove] = self.calculatePossibleMoves()
			possibleMoves.sort { self.rankMove($0) > self.rankMove($1) }
			let move = self.pickMove(possibleMoves)
			NSOperationQueue.mainQueue().addOperationWithBlock{
				completion(move)
			}
		}
	}
}