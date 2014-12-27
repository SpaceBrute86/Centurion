//
//  GameMove.swift
//  Centurion
//
//  Created by Robbie Markwick on 11/29/14.
//
//

import UIKit

struct GameMove {
	enum MoveType {
		case Movement
		case Attack(Weapon)
	}
	let type:MoveType
	let soldierAttacker:Soldier?
	let soldierDefender:Soldier?
	let destination:Location?
	
}
