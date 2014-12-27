//
//  BattleField.swift
//  Centurion
//
//  Created by Robbie Markwick on 11/27/14.
//
//

import UIKit

class BattleCell: UIView {
	var location:Location = Location(x: 0, y: 0)
	var soldier:SoldierView?
}

class BattleField: UIView, UIScrollViewDelegate {
	var cells:[[BattleCell]]=[]
	subscript(location: Location)->BattleCell{
		get{
			return cells[location.x][location.y]
		}
		set(newCell){
			cells[location.x][location.y] = newCell
		}
	}
	var gameCells:[BattleCell] {
		var gameCells:[BattleCell] = []
		for i in 1..<10 { gameCells += [cells[0][i]]}
		for i in 1..<10 { gameCells += cells[i] }
		for i in 1..<10 { gameCells += [cells[10][i]]}
		return gameCells
	}
	
	func createField() {
		(superview as? UIScrollView)?.contentSize = frame.size
		//Create Cells
		let cellSpacing:CGFloat = 1
		let boardSize = frame.size.width
		let cellSize = (frame.size.width - 10 * cellSpacing)/11
		for x in 0 ..< 11 {
			var row:[BattleCell]=[]
			for y in 0 ..< 11 {
				let cellX = CGFloat(x)*(cellSize+cellSpacing)
				let cellY = CGFloat(y)*(cellSize+cellSpacing)
				let cell = BattleCell(frame: CGRect(x:cellX, y: cellY, width: cellSize, height: cellSize))
				cell.location = Location(x: x, y: y)
				if (x==0||x==10)&&(y==0||y==10){
					cell.backgroundColor = UIColor(red: 0, green: 0.3, blue: 0, alpha: 1)
				}else{
					cell.backgroundColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1)
				}
				addSubview(cell)
				row+=[cell]
			}
			cells += [row]
		}
	}
	func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
		return self
	}
}

