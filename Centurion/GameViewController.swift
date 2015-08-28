//
//  GameViewController.swift
//  Centurion
//
//  Created by Robbie Markwick on 11/27/14.
//
//

import UIKit

class GameViewController:UIViewController, UIAlertViewDelegate{
	@IBOutlet var blueControl:UIView?
	@IBOutlet var battleField:BattleField?
	
	@IBOutlet var bluePilumButton:UIButton?
	@IBOutlet var redPilumButton:UIButton?
	@IBOutlet var blueGladiusButton:UIButton?
	@IBOutlet var redGladiusButton:UIButton?
	
	@IBOutlet var blueScutaMeter:LevelMeter?
	@IBOutlet var redScutaMeter:LevelMeter?
	@IBOutlet var bluePilumMeter:LevelMeter?
	@IBOutlet var redPilumMeter:LevelMeter?
	@IBOutlet var blueGladiusMeter:LevelMeter?
	@IBOutlet var redGladiusMeter:LevelMeter?
	@IBOutlet var blueMeterBlock:UIView?
	@IBOutlet var redMeterBlock:UIView?
	
	@IBOutlet var redHealthOnRed:UIProgressView?
	@IBOutlet var redHealthOnBlue:UIProgressView?
	@IBOutlet var blueHealthOnRed:UIProgressView?
	@IBOutlet var blueHealthOnBlue:UIProgressView?
	
	@IBOutlet var redHelmet:UIImageView?
	@IBOutlet var blueHelmet:UIImageView?
	
	var isSingle = false
	var rulesEngine = RulesEngine()
	var intelligence:AIPlayer?
	
	var selectedSoldier:Soldier?
	var selectedWeapon:Weapon?
	var animating = false
	
	override func viewWillAppear(animated: Bool) {
		rulesEngine.game = self
		rulesEngine.field = battleField
		//Interface
		let rotation = CGAffineTransformMakeRotation(CGFloat(M_PI))
		blueControl?.transform = rotation
		bluePilumButton?.transform = rotation
		blueGladiusButton?.transform = rotation
	}
	override func viewDidAppear(animated: Bool) {
		//set up icon progress bars
		redScutaMeter?.setup(UIImage(named: "shield.png"))
		blueScutaMeter?.setup(UIImage(named: "shield.png"))
		redPilumMeter?.setup(UIImage(named: "Spear_graphic.png"))
		bluePilumMeter?.setup( UIImage(named: "Spear_graphic.png"))
		redGladiusMeter?.setup( UIImage(named: "Sword_graphic.png"))
		blueGladiusMeter?.setup( UIImage(named: "Sword_graphic.png"))
		//Initialize AI
		if isSingle {
			intelligence = AIPlayer(rules: rulesEngine)
		}
		loadField()
		highlightCells()
		
	}
	override func prefersStatusBarHidden() -> Bool {
		return true
	}
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		let destVC = segue.destinationViewController as? WinnerViewController
		if segue.identifier == "RedWins" {
			destVC?.winningArmy = .red
		} else if segue.identifier == "BlueWins" {
			destVC?.winningArmy = .blue
		}
	}

	@IBAction func quit(sender:AnyObject){
		UIAlertView(title: "Quit", message: "Are you sure you want to quit?", delegate: self, cancelButtonTitle: "No", otherButtonTitles: "Yes").show()
	}
	func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
		guard buttonIndex == 1 else { return }
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
//MARK: Loading Field
	
	func createSoldier(type:SoldierType,army:Army,location:Location)->Soldier{
		let cellSize = battleField?[location].frame.size ?? CGSize()
		let soldierView = SoldierView(frame: CGRect(origin: CGPoint(), size: cellSize), army: army, type: type)
		let soldier = soldierView.soldier
		soldier.location = location
		soldierView.cell = battleField?[location]
		battleField?[location].soldier = soldierView
		battleField?[location].addSubview(soldierView)
		return soldier
	}
	func loadField(){
		battleField?.createField()
		for cell in battleField?.gameCells ?? [] {
			let tap = UITapGestureRecognizer(target: self, action: "tapSpace:")
			cell.addGestureRecognizer(tap)
		}
		rulesEngine.createSoldiers()
	}
//MARK: Game Display
	func highlightCells(){
		let normalColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1)
		let selectableColor = UIColor(red: 0, green: 0.7, blue: 0, alpha: 1)
		let selectedEnemyColor = UIColor(red: 0, green: 0.8, blue: 0, alpha: 1)
		let selectedColor = UIColor(red: 0, green: 1, blue: 0, alpha: 1)
		for cell in battleField?.gameCells ?? [] {
			if animating{
				cell.backgroundColor = normalColor
			} else if let selectedSoldier = selectedSoldier where rulesEngine.isTurn(selectedSoldier) {
				if cell.soldier?.soldier == selectedSoldier {
					cell.backgroundColor = selectedColor
				} else {
					var move:GameMove
					if let weapon = selectedWeapon {
						move = GameMove(type: .Attack(weapon), soldierAttacker: selectedSoldier, soldierDefender: cell.soldier?.soldier, destination: nil)
					} else {
						move = GameMove(type: .Movement, soldierAttacker: selectedSoldier, soldierDefender: nil, destination: cell.location)
					}
					cell.backgroundColor = rulesEngine.moveIsLegal(move) ? selectableColor : normalColor
				}
			} else {
				guard let soldier = cell.soldier?.soldier else {
					cell.backgroundColor = normalColor
					continue
				}
				if soldier == selectedSoldier {
					cell.backgroundColor = selectedEnemyColor
				} else {
					switch selectedWeapon {
					case .None:
						if rulesEngine.isTurn(soldier) {
							cell.backgroundColor = selectableColor
						} else {
							cell.backgroundColor = normalColor
						}
					case .Some(.Gladius):
						if soldier.gladius>0 && rulesEngine.isTurn(soldier) {
							cell.backgroundColor = selectableColor
						} else {
							cell.backgroundColor = normalColor
						}
					case .Some(.Pilum):
						if soldier.pilum>0 && rulesEngine.isTurn(soldier) {
							cell.backgroundColor = selectableColor
						} else {
							cell.backgroundColor = normalColor
						}
					}
				}
			}
		}
	}
	func highlightHelmet(){
		redHelmet?.highlighted = rulesEngine.currentArmy == .red
		blueHelmet?.highlighted = rulesEngine.currentArmy == .blue
	}
	func highlightButtons() {
		let pilumDis = UIImage(named:"PilumDis.png")
		let gladiusDis = UIImage(named:"GladiusDis.png")
		let pilum = UIImage(named:"Pilum.png")
		let gladius = UIImage(named:"Gladius.png")
		bluePilumButton?.setImage( pilumDis, forState: .Normal)
		blueGladiusButton?.setImage( gladiusDis, forState: .Normal)
		redPilumButton?.setImage( pilumDis, forState: .Normal)
		redGladiusButton?.setImage( gladiusDis, forState: .Normal)
		
		switch (rulesEngine.currentArmy,selectedWeapon) {
		case (.red,.Some(.Gladius)): redGladiusButton?.setImage( gladius, forState:.Normal)
		case (.red,.Some(.Pilum)): redPilumButton?.setImage( pilum, forState:.Normal)
		case (.blue,.Some(.Gladius)): blueGladiusButton?.setImage( gladius, forState:.Normal)
		case (.blue,.Some(.Pilum)): bluePilumButton?.setImage( pilum, forState:.Normal)
		default: break
		}
	}
	func showMeterLevelsForSoldier(soldierView:SoldierView?){
		guard let soldier = soldierView?.soldier else {
			redMeterBlock?.hidden = false
			blueMeterBlock?.hidden = false
			return
		}
		redMeterBlock?.hidden = true
		blueMeterBlock?.hidden = true
		redScutaMeter?.percent = Double (soldier.scuta) / Double(Soldier.totalScutaForType(soldier.type))
		blueScutaMeter?.percent = Double (soldier.scuta) / Double(Soldier.totalScutaForType(soldier.type))
		redPilumMeter?.percent = Double (soldier.pilum) / Double(Soldier.totalPilumForType(soldier.type))
		bluePilumMeter?.percent = Double (soldier.pilum) / Double(Soldier.totalPilumForType(soldier.type))
		redGladiusMeter?.percent = Double (soldier.gladius) / Double(Soldier.totalGladiusForType(soldier.type))
		blueGladiusMeter?.percent = Double (soldier.gladius) / Double(Soldier.totalGladiusForType(soldier.type))
	}
//MARK: Game controls
	
	@IBAction func bluePilum(sender:AnyObject){
		guard rulesEngine.currentArmy == .blue else { return }
		setWeapon(.Pilum)
	}
	@IBAction func blueGladius(sender:AnyObject){
		guard rulesEngine.currentArmy == .blue else { return }
		setWeapon(.Gladius)
	}
	@IBAction func redPilum(sender:AnyObject){
		guard rulesEngine.currentArmy == .red else { return }
		setWeapon(.Pilum)
	}
	@IBAction func redGladius(sender:AnyObject){
		guard rulesEngine.currentArmy == .red else { return }
		setWeapon(.Gladius)
	}
	func setWeapon(weapon:Weapon){
		selectedWeapon = selectedWeapon == weapon ? nil : weapon
		highlightButtons()
		highlightCells()
	}
	var moveType:GameMove.MoveType {
		guard let weapon = selectedWeapon else { return .Movement }
		return .Attack(weapon)
	}
	func tapSpace(sender:UIGestureRecognizer){
		let cell = sender.view  as? BattleCell
		if let soldier = cell?.soldier?.soldier {
			if soldier.army == rulesEngine.currentArmy {
				selectedSoldier = soldier
				showMeterLevelsForSoldier(cell?.soldier)
				highlightCells()
			} else {
				let move = GameMove(type: moveType, soldierAttacker: selectedSoldier, soldierDefender: soldier, destination: nil)
				if rulesEngine.moveIsLegal(move) { //Perform attack
					runMove(move)
				} else {
					selectedSoldier = soldier
					showMeterLevelsForSoldier(cell?.soldier)
					highlightCells()
				}
			}
		} else {
			let move = GameMove(type: moveType, soldierAttacker: selectedSoldier, soldierDefender: nil, destination: cell?.location)
			if rulesEngine.moveIsLegal(move) {
				runMove(move)
			} else {
				selectedSoldier = nil
				showMeterLevelsForSoldier(nil)
				highlightCells()
			}
		}
		
		
	}
//MARK: Executing Moves
	func movePiece(piece:UIView,fromCell:BattleCell, toCell:BattleCell, duration:NSTimeInterval, completion:()->()){
		guard !animating else { return }
		animating = true
		highlightCells()
		if let soldier = piece as? SoldierView {
			soldier.removeFromSuperview()
		}
		battleField?.addSubview(piece)
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
	func runMove(move:GameMove){
		guard let battleField = battleField else { return }
		let piece:UIView?
		let fromCell = move.soldierAttacker?.cell
		let toCell:BattleCell?
		var duration:Double
		switch move.type {
		case .Movement:
			guard let location = move.destination else { return }
			duration = 0.7
			toCell = battleField[location]
			piece = move.soldierAttacker?.view
		case .Attack(.Gladius):
			duration = 1
			toCell = move.soldierDefender?.cell
			let weaponAngle =  CGFloat( Location.direction(fromCell?.location ?? Location(x:0,y:0), toCell?.location ?? Location(x:0,y:0)) )
			piece = weaponViewForWeapon(.Gladius, angle: weaponAngle, cellSize: fromCell?.frame.size ?? CGSize() )
		case .Attack(.Pilum):
			duration = 2
			toCell = move.soldierDefender?.cell
			let weaponAngle =  CGFloat( Location.direction(fromCell?.location ?? Location(x:0,y:0), toCell?.location ?? Location(x:0,y:0) ) )
			piece = weaponViewForWeapon(Weapon.Pilum, angle: weaponAngle, cellSize: fromCell?.frame.size ?? CGSize() )
		}
		guard let obj = piece, from = fromCell, to = toCell else { return }
		movePiece(obj, fromCell: from, toCell: to, duration: duration){
			self.rulesEngine.executeMove(move)
			if self.isSingle && self.rulesEngine.currentArmy == .blue {
				self.intelligence?.chooseMove(self.runMove)
			}
		}
		
	}

	func showHealth(soldier:Soldier,redTotal red:Float,blueTotal blue:Float){
		soldier.view?.healthBar.progress = Float(soldier.health) / Float(Soldier.totalHealthForType(soldier.type))
		UIView.animateWithDuration(1){
			self.blueHealthOnBlue?.progress = blue
			self.blueHealthOnRed?.progress = blue
			self.redHealthOnBlue?.progress = red
			self.redHealthOnRed?.progress = red
		}
	}
	func killSoldier(soldier:Soldier){
		soldier.view?.cell?.soldier=nil
		soldier.view?.cell=nil
		soldier.health=0
		soldier.view?.removeFromSuperview()
	}
	
}





























