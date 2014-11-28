//
//  GameViewController.swift
//  Centurion
//
//  Created by Robbie Markwick on 11/27/14.
//
//

import UIKit

class GameViewController:UIViewController, UIAlertViewDelegate{
	@IBOutlet var blueControl:UIView!
	@IBOutlet var battleField:BattleField!
	
	@IBOutlet var bluePilumButton:UIButton!
	@IBOutlet var redPilumButton:UIButton!
	@IBOutlet var blueGladiusButton:UIButton!
	@IBOutlet var redGladiusButton:UIButton!
	
	@IBOutlet var blueScutaMeter:LevelMeter!
	@IBOutlet var redScutaMeter:LevelMeter!
	@IBOutlet var bluePilumMeter:LevelMeter!
	@IBOutlet var redPilumMeter:LevelMeter!
	@IBOutlet var blueGladiusMeter:LevelMeter!
	@IBOutlet var redGladiusMeter:LevelMeter!
	@IBOutlet var blueMeterBlock:UIView!
	@IBOutlet var redMeterBlock:UIView!
	
	@IBOutlet var redHealthOnRed:UIProgressView!
	@IBOutlet var redHealthOnBlue:UIProgressView!
	@IBOutlet var blueHealthOnRed:UIProgressView!
	@IBOutlet var blueHealthOnBlue:UIProgressView!
	
	@IBOutlet var redHelmet:UIImageView!
	@IBOutlet var blueHelmet:UIImageView!
	
	var isSingle = false
	var rulesEngine = RulesEngine()
	var intelligence:NSObject?
	
	var selectedSoldier:Soldier?
	var selectedWeapon:RulesEngine.Weapon?
	var animating = false
	//var aiQueue = dispatch_queue_create("com.markwick.centurion.ai", 0)
	
	override func viewWillAppear(animated: Bool) {
		rulesEngine.game = self
		rulesEngine.field = battleField
		//Interface
		let rotation = CGAffineTransformMakeRotation(CGFloat(M_PI))
		blueControl.transform = rotation
		bluePilumButton.transform = rotation
		blueGladiusButton.transform = rotation
	}
	override func viewDidAppear(animated: Bool) {
		//set up icon progress bars
		redScutaMeter.setup(UIImage(named: "shield.png"))
		blueScutaMeter.setup(UIImage(named: "shield.png"))
		redPilumMeter.setup(UIImage(named: "Spear_graphic.png"))
		bluePilumMeter.setup( UIImage(named: "Spear_graphic.png"))
		redGladiusMeter.setup( UIImage(named: "Sword_graphic.png"))
		blueGladiusMeter.setup( UIImage(named: "Sword_graphic.png"))
		//Initialize AI
		if isSingle {
			/*
self.intelligence=[[RBAIEngine alloc] init];
self.intelligence.redArmy=self.rules.redSoldiers;
self.intelligence.blueArmy=self.rules.blueSoldiers;
self.intelligence.rules=self.rules;

*/
		}
		loadField()
		highlightCells()

	}
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		let destVC = segue.destinationViewController as WinnerViewController
		if segue.identifier == "RedWins" {
			destVC.winningArmy = .red
		} else if segue.identifier == "BlueWins" {
			destVC.winningArmy = .blue
		}
	}
	override func prefersStatusBarHidden() -> Bool {
		return true
	}
	@IBAction func quit(sender:AnyObject){
		UIAlertView(title: "Quit", message: "Are you sure you want to quit?", delegate: self, cancelButtonTitle: "No", otherButtonTitles: "Yes").show()
	}
	func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
		if buttonIndex == 1 {
			self.dismissViewControllerAnimated(true, completion: nil)
		}
	}
	
	@IBAction func bluePilum(sender:AnyObject){
		if rulesEngine.currentArmy == .blue {
			setWeapon(.pilum)
		}
	}
	@IBAction func blueGladius(sender:AnyObject){
		if rulesEngine.currentArmy == .blue {
			setWeapon(.gladius)
		}
	}
	@IBAction func redPilum(sender:AnyObject){
		if rulesEngine.currentArmy == .red {
			setWeapon(.pilum)
		}
	}
	@IBAction func redGladius(sender:AnyObject){
		if rulesEngine.currentArmy == .red {
			setWeapon(.gladius)
		}
	}

}
extension GameViewController { //Loading Field
	
	func createSoldier(type:SoldierType,army:Army,x:Int,y:Int)->Soldier{
		let cellSize = battleField.cells[x][y].frame.size
		let soldierView = SoldierView(frame: CGRect(origin: CGPoint(), size: cellSize), army: army, type: type)
		let soldier = soldierView.soldier
		soldier.x = x
		soldier.y = y
		soldierView.cell = battleField.cells [x][y]
		battleField.cells[x][y].soldier = soldierView
		battleField.cells[x][y].addSubview(soldierView)
		return soldier
	}
	func loadField(){
		battleField.createField()
		for x in 0..<11 {
			for y in 0..<11 {
				if (x > 0 && x < 10) || (y > 0 && y < 10) {
					let tap = UITapGestureRecognizer(target: self, action: "tapSpace:")
					battleField.cells[x][y].addGestureRecognizer(tap)
				}
			}
		}
		rulesEngine.createSoldiers()
	}
}
extension GameViewController{//Game Display
	func highlightCells(){
		let normalColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1)
		let selectableColor = UIColor(red: 0, green: 0.7, blue: 0, alpha: 1)
		let selectedEnemyColor = UIColor(red: 0, green: 0.8, blue: 0, alpha: 1)
		let selectedColor = UIColor(red: 0, green: 1, blue: 0, alpha: 1)
		for x in 0..<11 {
			for y in 0..<11 {
				let cell = battleField.cells[x][y]
				if (x==0||x==10)&&(y==0||y==10) {
					cell.backgroundColor = normalColor
				} else if animating{
					cell.backgroundColor = normalColor
				} else if selectedSoldier == nil || !rulesEngine.isTurn(selectedSoldier!) {
					if cell.soldier == nil {
						cell.backgroundColor = normalColor
					} else if cell.soldier?.soldier == selectedSoldier {
						cell.backgroundColor = selectedEnemyColor
					} else {
						let soldier = cell.soldier!.soldier
						switch selectedWeapon {
						case .None:
							if rulesEngine.isTurn(soldier) {
								cell.backgroundColor = selectableColor
							} else {
								cell.backgroundColor = normalColor
							}
						case .Some(.gladius):
								if soldier.gladius>0 && rulesEngine.isTurn(soldier) {
									cell.backgroundColor = selectableColor
								} else {
									cell.backgroundColor = normalColor
								}
						case .Some(.pilum):
							if soldier.pilum>0 && rulesEngine.isTurn(soldier) {
								cell.backgroundColor = selectableColor
							} else {
								cell.backgroundColor = normalColor
							}
						}
					}
				} else {
					if cell.soldier?.soldier == selectedSoldier {
						cell.backgroundColor = selectedColor
					} else {
						if selectedWeapon == nil {
							if rulesEngine.soldierCanMove(selectedSoldier!, toX: x, toY: y){
								cell.backgroundColor = selectableColor
							}else {
								cell.backgroundColor = normalColor
							}
						} else {
							if cell.soldier?.soldier == nil {
								cell.backgroundColor = normalColor
							} else if rulesEngine.soldier(selectedSoldier!, canAttackSoldier: cell.soldier!.soldier, weapon: selectedWeapon!){
							} else {
								cell.backgroundColor = normalColor
							}
						}
					}
				}
				
			}
		}
	}
	func highlightHelmet(){
		redHelmet.highlighted = rulesEngine.currentArmy == .red
		blueHelmet.highlighted = rulesEngine.currentArmy == .blue
	}
	func highlightButtons() {
		let pilumDis = UIImage(named:"PilumDis.png")
		let gladiusDis = UIImage(named:"GladiusDis.png")
		let pilum = UIImage(named:"Pilum.png")
		let gladius = UIImage(named:"Gladius.png")
		bluePilumButton.setImage( pilumDis, forState: .Normal)
		blueGladiusButton.setImage( gladiusDis, forState: .Normal)
		redPilumButton.setImage( pilumDis, forState: .Normal)
		redGladiusButton.setImage( gladiusDis, forState: .Normal)
		
		if rulesEngine.currentArmy == .red && selectedWeapon == .gladius{
			redGladiusButton.setImage( gladius, forState:.Normal)
		} else if rulesEngine.currentArmy == .red && selectedWeapon == .pilum {
			redPilumButton.setImage( pilum, forState: .Normal)
		} else if rulesEngine.currentArmy == .blue && selectedWeapon == .gladius{
			blueGladiusButton.setImage( gladius, forState: .Normal)
		} else if rulesEngine.currentArmy == .blue && selectedWeapon == .pilum {
			bluePilumButton.setImage( pilum, forState: .Normal)
		}
	}
	func showMeterLevelsForSoldier(soldierView:SoldierView?){
		if let soldier = soldierView?.soldier {
			redMeterBlock.hidden = true
			blueMeterBlock.hidden = true
			redScutaMeter.percent = Double (soldier.scuta) / Double(Soldier.totalScutaForType(soldier.type))
			blueScutaMeter.percent = Double (soldier.scuta) / Double(Soldier.totalScutaForType(soldier.type))
			redPilumMeter.percent = Double (soldier.pilum) / Double(Soldier.totalPilumForType(soldier.type))
			bluePilumMeter.percent = Double (soldier.pilum) / Double(Soldier.totalPilumForType(soldier.type))
			redGladiusMeter.percent = Double (soldier.gladius) / Double(Soldier.totalGladiusForType(soldier.type))
			blueGladiusMeter.percent = Double (soldier.gladius) / Double(Soldier.totalGladiusForType(soldier.type))
		} else {
			redMeterBlock.hidden = false
			blueMeterBlock.hidden = false
		}
	}
}
extension GameViewController { //Game controls
	func setWeapon(weapon:RulesEngine.Weapon){
		if selectedWeapon == weapon {
			selectedWeapon = nil
		} else {
			selectedWeapon = weapon
		}
		highlightButtons()
		highlightCells()
	}
	
	func tapSpace(sender:UIGestureRecognizer){
		let cell = sender.view  as BattleCell
		if let soldier = cell.soldier?.soldier {
			if soldier.army == rulesEngine.currentArmy {
				selectedSoldier = soldier
				showMeterLevelsForSoldier(cell.soldier)
				highlightCells()
			} else {
				if selectedWeapon != nil && selectedSoldier != nil && rulesEngine.soldier(selectedSoldier!, canAttackSoldier: soldier, weapon: selectedWeapon!) { //Perform attack
					attack(soldier,withSoldier:selectedSoldier!,weapon:selectedWeapon!)
				} else {
					selectedSoldier = soldier
					showMeterLevelsForSoldier(cell.soldier)
					highlightCells()
				}
			}
		} else {
			if selectedSoldier != nil && rulesEngine.soldierCanMove(selectedSoldier!, toX: cell.x, toY: cell.y) {
				moveSoldier(selectedSoldier!, toCell: cell)
			} else {
				selectedSoldier = nil
				showMeterLevelsForSoldier(nil)
				highlightCells()
			}
		}
	
		
	}
}
extension GameViewController { //Executing Moves
	func movePiece(piece:UIView,fromCell:BattleCell, toCell:BattleCell, duration:NSTimeInterval, completion:()->()){
		if animating { return }
		animating = true
		highlightCells()
		if let soldier = piece as? SoldierView {
			soldier.removeFromSuperview()
		}
		battleField.addSubview(piece)
		piece.center = fromCell.center
		UIView.animateWithDuration(duration, animations: {
			piece.center = toCell.center
		}, completion: { finished in
			piece.removeFromSuperview()
			if let soldier = piece as? SoldierView {
				toCell.addSubview(soldier)
				soldier.center = toCell.convertPoint(toCell.center, fromView: toCell.superview)
				fromCell.soldier = nil
				toCell.soldier = soldier
				soldier.cell = toCell
			}
			self.animating = false
			completion()
		})

	}
	func moveSoldier (soldier:Soldier,toCell cell:BattleCell){
		movePiece(soldier.view!, fromCell: soldier.cell!, toCell: cell, duration: 0.7){
			self.rulesEngine.moveSoldier(soldier, toX: cell.x, toY: cell.y)
		}
	}
	func attack(defender:Soldier, withSoldier attacker:Soldier, weapon:RulesEngine.Weapon){
		let fromCell = attacker.cell!, toCell = defender.cell!
		let weaponAngle =  CGFloat( atan2(Double(fromCell.y-toCell.y) ,Double(fromCell.x-toCell.x)) )
		let weaponView = weaponViewForWeapon(weapon, weaponAngle)
		var duration:Double
		switch weapon {
		case .gladius: duration = 1
		case .pilum: duration = 2
		}
		movePiece(weaponView, fromCell: fromCell, toCell: toCell, duration: duration){
			self.rulesEngine.attackSoldier(defender, withSoldier: attacker, weapon: weapon)
		}
	}
	func showHealth(soldier:Soldier,redTotal red:Float,blueTotal blue:Float){
		soldier.view?.healthBar.progress = Float(soldier.health) / Float(Soldier.totalHealthForType(soldier.type))
		UIView.animateWithDuration(1){
			self.blueHealthOnBlue.progress = blue
			self.blueHealthOnRed.progress = blue
			self.redHealthOnBlue.progress = red
			self.redHealthOnRed.progress = red
		}
	}
	func killSoldier(soldier:Soldier){
		soldier.view?.cell?.soldier=nil
		soldier.view?.cell=nil
		soldier.health=0
		soldier.view?.removeFromSuperview()
	}
	
}





























