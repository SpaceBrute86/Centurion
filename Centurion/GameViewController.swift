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
	var aiQueue = dispatch_queue_create("com.markwick.centurion.ai", 0)
	
	
	override func viewDidLoad() {
		rulesEngine.field = battleField
		//set up icon progress bars
		redScutaMeter.progressImage = UIImage(named: "shield.png")
		blueScutaMeter.progressImage = UIImage(named: "shield.png")
		redPilumMeter.progressImage = UIImage(named: "Spear_graphic.png")
		bluePilumMeter.progressImage = UIImage(named: "Spear_graphic.png")
		redGladiusMeter.progressImage = UIImage(named: "Sword_graphic.png")
		blueGladiusMeter.progressImage = UIImage(named: "Sword_graphic.png")
		//Interface
		let rotation = CGAffineTransformMakeRotation(CGFloat(M_PI))
		blueControl.transform = rotation
		bluePilumButton.transform = rotation
		blueGladiusButton.transform = rotation
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
	
	func createSoldier(type:SoldierType,army:Army,x:Int,y:Int){
		let cellSize = battleField.cells[x][y].frame.size
		let soldierView = SoldierView(frame: CGRect(origin: CGPoint(), size: cellSize), army: army, type: type)
		let soldier = soldierView.soldier
		switch soldier.army {
		case .red: rulesEngine.redArmy += [soldier]
		case .blue: rulesEngine.blueArmy += [soldier]
		}
		soldierView.cell = battleField.cells [x][y]
		battleField.cells[x][y].soldier = soldierView
		battleField.cells[x][y].addSubview(soldierView)
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
		var archerType:SoldierType
		if checkPurchaseForProductID(archerProductID) {
			archerType = .archer
		} else {
			archerType = .legionary
		}
		//Red army
		createSoldier(.cavalry, army: .blue, x: 2, y: 9)
		createSoldier(archerType, army: .blue, x: 4, y: 9)
		createSoldier(archerType, army: .blue, x: 6, y: 9)
		createSoldier(.cavalry, army: .blue, x: 8, y: 9)
		createSoldier(.legionary, army: .blue, x: 3, y: 8)
		createSoldier(.legionary, army: .blue, x: 5, y: 8)
		createSoldier(.legionary, army: .blue, x: 7, y: 8)
		createSoldier(.cavalry, army: .blue, x: 2, y: 7)
		createSoldier(.legionary, army: .blue, x: 4, y: 7)
		createSoldier(.legionary, army: .blue, x: 6, y: 7)
		createSoldier(.cavalry, army: .blue, x: 8, y: 7)
		//Blue army
		createSoldier(.cavalry, army: .blue, x: 2, y: 1)
		createSoldier(archerType, army: .blue, x: 4, y: 1)
		createSoldier(archerType, army: .blue, x: 6, y: 1)
		createSoldier(.cavalry, army: .blue, x: 8, y: 1)
		createSoldier(.legionary, army: .blue, x: 3, y: 2)
		createSoldier(.legionary, army: .blue, x: 5, y: 2)
		createSoldier(.legionary, army: .blue, x: 7, y: 2)
		createSoldier(.cavalry, army: .blue, x: 2, y: 3)
		createSoldier(.legionary, army: .blue, x: 4, y: 3)
		createSoldier(.legionary, army: .blue, x: 6, y: 3)
		createSoldier(.cavalry, army: .blue, x: 8, y: 3)
	}
}
extension GameViewController{//Game Display
	func highlightCells(){
		let normalColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1)
		let selectableColor = UIColor(red: 0, green: 0.7, blue: 0, alpha: 1)
		let selectedColor = UIColor(red: 0, green: 1, blue: 0, alpha: 1)
		for x in 0..<11 {
			for y in 0..<11 {
				let cell = battleField.cells[x][y]
				if (x==0||x==10)&&(y==0||y==10) {
					cell.backgroundColor = UIColor(red: 0, green: 0.3, blue: 0, alpha: 1)
				} else if animating{
					cell.backgroundColor = normalColor
				} else if selectedSoldier == nil {
					if cell.soldier == nil {
						cell.backgroundColor = normalColor
					} else {
						let soldier = cell.soldier!.soldier
						switch selectedWeapon {
						case .None:
							cell.backgroundColor = normalColor
							if rulesEngine.currentArmy == soldier.army {
								for i in 0..<25 {
									if rulesEngine.soldierCanMove(soldier, toX: i%5-2, toY: i/5-2){
										cell.backgroundColor = selectableColor
										break
									}
								}
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
			redGladiusButton.setImage( gladiusDis, forState:.Normal)
		} else if rulesEngine.currentArmy == .red && selectedWeapon == .pilum {
			redPilumButton.setImage( pilum, forState: .Normal)
		} else if rulesEngine.currentArmy == .blue && selectedWeapon == .gladius{
			redGladiusButton.setImage( gladius, forState: .Normal)
		} else if rulesEngine.currentArmy == .blue && selectedWeapon == .pilum {
			redPilumButton.setImage( pilum, forState: .Normal)
		}
	}
	func showMeterLevelsForSoldier(soldierView:SoldierView?){
		if let soldier = soldierView?.soldier {
			redMeterBlock.hidden = false
			blueMeterBlock.hidden = false
			redScutaMeter.percent = Double (soldier.scuta) / Double(Soldier.totalScutaForType(soldier.type))
			blueScutaMeter.percent = Double (soldier.scuta) / Double(Soldier.totalScutaForType(soldier.type))
			redPilumMeter.percent = Double (soldier.pilum) / Double(Soldier.totalPilumForType(soldier.type))
			bluePilumMeter.percent = Double (soldier.pilum) / Double(Soldier.totalPilumForType(soldier.type))
			redGladiusMeter.percent = Double (soldier.gladius) / Double(Soldier.totalGladiusForType(soldier.type))
			blueGladiusMeter.percent = Double (soldier.gladius) / Double(Soldier.totalGladiusForType(soldier.type))
		} else {
			redMeterBlock.hidden = true
			blueMeterBlock.hidden = true
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
				if selectedWeapon != nil && rulesEngine.soldier(selectedSoldier!, canAttackSoldier: soldier, weapon: selectedWeapon!) { //Perform attack
						attack(soldier,withWeapon:selectedWeapon!)
				} else {
					selectedSoldier = nil
					showMeterLevelsForSoldier(nil)
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
	func moveSoldier (soldier:Soldier,toCell cell:BattleCell){
		if animating { return }
		animating = true
		let normalCenter = soldier.view!.center
		soldier.view!.removeFromSuperview()
		soldier.view!.center = soldier.view!.cell!.center
		battleField.addSubview(soldier.view!)
		animating = true
		UIView.animateWithDuration(0.7, animations: {
			soldier.view!.center = cell.center
		}) { finished in
			soldier.view!.removeFromSuperview()
			soldier.view!.center = normalCenter
			cell.addSubview(soldier.view!)
			soldier.view!.cell?.soldier = nil
			soldier.view!.cell = cell
			cell.soldier = soldier.view!
			self.animating = false
			//Take turn
			self.rulesEngine.takeTurn()
			self.highlightHelmet()
			self.highlightCells()
		}
	}
	func imageViewForWeapon(weapon:RulesEngine.Weapon, fromCell:BattleCell, toCell:BattleCell)->UIImageView {
		var img:UIImageView
		switch weapon {
		case .pilum: img = UIImageView(image: UIImage(named: "Spear.png"))
		case .gladius: img = UIImageView(image: UIImage(named: "Sword.png"))
		}
		img.opaque = false;
		let imgSize = fromCell.frame.size.width*1.6
		img.frame = CGRect(x: fromCell.center.x-imgSize/2, y: fromCell.center.y-imgSize/2, width: imgSize, height: imgSize)
		let angle = atan2(Double(fromCell.y-toCell.y) ,Double(fromCell.x-toCell.x))
		img.transform=CGAffineTransformMakeRotation( CGFloat(angle-M_PI_2) )
		return img
	}
	func attack(soldier:Soldier,withWeapon weapon:RulesEngine.Weapon){
		if animating { return }
		animating = true
		//set up sword animation
		let image = imageViewForWeapon(weapon, fromCell: selectedSoldier!.view!.cell!, toCell: soldier.view!.cell!)
		battleField.addSubview(image)
		var duration:Double
		switch weapon {
		case .gladius: duration = 1
		case .pilum: duration = 2
		}
		UIView.animateWithDuration(duration, animations:{
			image.center = soldier.view!.cell!.center
		}){ finished in
			self.rulesEngine.attackSoldier(soldier, withSoldier: self.selectedSoldier!, weapon: weapon)
			image.removeFromSuperview()
			self.animating = false
			self.highlightCells()
			self.highlightHelmet()
			//Health Update
			soldier.view?.healthBar.progress = Float(soldier.health) / Float(Soldier.totalHealthForType(soldier.type))
			let red = Float(self.rulesEngine.currentHealthForArmy(.red))/Float(self.rulesEngine.totalHealthForArmy(.red))
			let blue = Float(self.rulesEngine.currentHealthForArmy(.blue))/Float(self.rulesEngine.totalHealthForArmy(.blue))
			UIView.animateWithDuration(1){
				self.blueHealthOnBlue.progress = blue
				self.blueHealthOnRed.progress = blue
				self.redHealthOnBlue.progress = red
				self.redHealthOnRed.progress = red
			}
			//detect victory
			if blue <= 0.25 && blue < red/2 {
				self.performSegueWithIdentifier("Winner", sender: self)
			} else if red <= 0.25 && red < blue/2 {
				self.performSegueWithIdentifier("Winner", sender: nil)
			}
		}
	}
	
	func killSoldier(soldier:Soldier){
		soldier.view?.cell?.soldier=nil
		soldier.view?.cell=nil
		soldier.health=0
		soldier.view?.removeFromSuperview()
	}
	
}





























