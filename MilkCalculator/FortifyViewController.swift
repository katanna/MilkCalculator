//
//  FortifyViewController.swift
//  MilkCalculator
//
//  Created by Matthew Kelling on 5/6/23.
//

import UIKit

class FortifyViewController: UIViewController, UITextFieldDelegate {
	
	var fortify = Fortify()
	
	@IBOutlet var milkTypeSelector: UISegmentedControl!
	@IBOutlet var startOrEndSelector: UISegmentedControl!
	@IBOutlet var volumeTextField: UITextField!
	@IBOutlet var volumeUnitSelector: UISegmentedControl!
	@IBOutlet var concentrationTextField: UITextField!
	@IBOutlet var calculateButton: UIButton!
	@IBOutlet var answerText: UILabel!
	
	var activeTextField: UITextField? = nil
	var nextTextField: UIControl? = nil
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		concentrationTextField.delegate = self
		volumeTextField.delegate = self
		
		addDoneButtonOnNumpad(self, textField: concentrationTextField)
		addDoneButtonOnNumpad(self, textField: volumeTextField)
		
		loadKeyboardNotifications(self)
		
		setUpSegmentedControllers()
		loadDefaults()
	}
	
	func setUpSegmentedControllers() {
		milkTypeSelector.removeAllSegments()
		FortifyMilkType.allCases.forEach {
			milkTypeSelector.insertSegment(withTitle: $0.description(), at: milkTypeSelector.numberOfSegments, animated: false)
		}
		
		startOrEndSelector.removeAllSegments()
		FortifyStartOrEnd.allCases.forEach {
			startOrEndSelector.insertSegment(withTitle: $0.description(), at: startOrEndSelector.numberOfSegments, animated: false)
		}
		
		volumeUnitSelector.removeAllSegments()
		FortifyVolumeUnit.allCases.forEach {
			volumeUnitSelector.insertSegment(withTitle: $0.description(), at: volumeUnitSelector.numberOfSegments, animated: false)
		}
	}
	
	func loadDefaults() {
		milkTypeSelector.selectedSegmentIndex = FortifyMilkType.allCases.firstIndex(of: fortify.milkType)!
		
		startOrEndSelector.selectedSegmentIndex = FortifyStartOrEnd.allCases.firstIndex(of: fortify.startOrEnd)!
		
		if fortify.volume == 0 {
			volumeTextField.text = ""
		} else {
			volumeTextField.text = fortify.volume.stringWithoutTrailingZero
		}
		
		volumeUnitSelector.selectedSegmentIndex = FortifyVolumeUnit.allCases.firstIndex(of: fortify.volumeUnit)!
		
		if fortify.concentration == 0 {
			concentrationTextField.text = ""
		} else {
			concentrationTextField.text = String(fortify.concentration)
		}
		
		answerText.text = ""
		
		calculateButton.isEnabled = false
		checkCalculateButton()
		if calculateButton.isEnabled {
			findAnswer(withAnimation: false)
		}
	}
	
	@IBAction func milkTypeChanged(_ sender: UISegmentedControl) {
		fortify.milkType = FortifyMilkType.allCases[sender.selectedSegmentIndex]
	}
	
	@IBAction func startOrEndChanged(_ sender: UISegmentedControl) {
		fortify.startOrEnd = FortifyStartOrEnd.allCases[sender.selectedSegmentIndex]
	}
	
	@IBAction func volumeChanged(_ sender: UITextField) {
		textFieldChanged(sender, variable: &fortify.volume)
	}
	
	@IBAction func volumeUnitChanged(_ sender: UISegmentedControl) {
		fortify.volumeUnit = FortifyVolumeUnit.allCases[sender.selectedSegmentIndex]
	}
	
	@IBAction func concentrationChanged(_ sender: UITextField) {
		textFieldChanged(sender, variable: &fortify.concentration)
	}
	
	@IBAction func calculateButtonPressed(_ sender: UIButton) {
		concentrationTextField.resignFirstResponder()
		volumeTextField.resignFirstResponder()
		
		findAnswer(withAnimation: true)
	}
	
	func findAnswer (withAnimation animate: Bool) {
	//Set Starting Concentration
		let startingConcentration: Int
		
		switch fortify.milkType {
		case .breast:
			startingConcentration = 20
		case .formula:
			startingConcentration = 20
		case .water:
			startingConcentration = 0
		}
		
	//Set Starting and Ending Volume
		let startingVolumeInOz: Double?
		let endingVolumeInOz: Double?
		
		switch fortify.startOrEnd {
		case .start:
			let volumeUnit: UnitVolume
			
			switch fortify.volumeUnit {
			case .ml:
				volumeUnit = UnitVolume.milliliters
			case .oz:
				volumeUnit = UnitVolume.fluidOunces
			}
			
			let volumeAsMeasurement = Measurement(value: fortify.volume, unit: volumeUnit)
			startingVolumeInOz = volumeAsMeasurement.converted(to: UnitVolume.fluidOunces).value
			
			endingVolumeInOz = nil
			
		case .end:
			startingVolumeInOz = nil
			
			let volumeUnit: UnitVolume
			
			switch fortify.volumeUnit {
			case .ml:
				volumeUnit = UnitVolume.milliliters
			case .oz:
				volumeUnit = UnitVolume.fluidOunces
			}
			
			let volumeAsMeasurement = Measurement(value: fortify.volume, unit: volumeUnit)
			endingVolumeInOz = volumeAsMeasurement.converted(to: UnitVolume.fluidOunces).value
		}
		
	//Set Formula Concentration
		let formulaConcentration = 22.0
		
//		let waterVolumeAsOz: Double
//		let waterVolumeUnit: UnitVolume
//
//		switch Settings.formulaWaterVolumeUnit {
//		case .ml:
//			waterVolumeUnit = UnitVolume.milliliters
//		case .oz:
//			waterVolumeUnit = UnitVolume.fluidOunces
//		}
//
//		let waterAsMeasurement = Measurement(value: Settings.formulaWaterVolume, unit: waterVolumeUnit)
//		waterVolumeAsOz = waterAsMeasurement.converted(to: UnitVolume.fluidOunces).value
//
//		let formulaConcentration = waterVolumeAsOz * Double(Settings.formulaConcentration) / 0.2
		
	//Set Ending Concentration
		let endingConcentration = fortify.concentration
		
	//Calculate
		let amountOfPowerPerVolumeToAdd: Double
		
		switch fortify.startOrEnd {
		case .start:
			amountOfPowerPerVolumeToAdd = ( (Double(startingConcentration) * startingVolumeInOz!) - (Double(endingConcentration) * startingVolumeInOz!) ) / (Double(endingConcentration) - formulaConcentration)
		case .end:
			amountOfPowerPerVolumeToAdd = 0
		}
		
		let numberOfScoopsToAdd = amountOfPowerPerVolumeToAdd / 0.2
		
	//Convert to Output Unit
		let outputUnit: UnitVolume
		
		switch Settings.fortifyAdditionalVolumeUnit {
		case .imperial:
			outputUnit = UnitVolume.teaspoons
		case .ml:
			outputUnit = UnitVolume.milliliters
		case .scoop:
			outputUnit = UnitVolume.scoop
		}
		
		let outputAsMeasurement = Measurement(value: numberOfScoopsToAdd, unit: UnitVolume.scoop)
		let outputAdjusted = outputAsMeasurement.converted(to: outputUnit).value
		
	//Show Answer
		let outputRounded = round(outputAdjusted * 100) / 100

		if outputRounded >= 0.0625 {
			answerText.text = "So I need to add \(outputRounded) \(Settings.fortifyAdditionalVolumeUnit.description()) of formula."
		} else {
			answerText.text = "There is no need to fortify."
		}

		if animate {
			UIView.animate(withDuration: 0.5, animations: {
				self.answerText.transform = CGAffineTransform(scaleX: 2, y: 2)
				self.answerText.transform = CGAffineTransform(scaleX: 1, y: 1)
			})
		}
	}
	
	@IBAction func textEditingchanged(_ sender: UITextField) {
		checkCalculateButton()
	}
	
	func checkCalculateButton() {
		let volume = Double(volumeTextField.text!) ?? 0
		let concentration = Int(concentrationTextField.text!) ?? 0
		
		if concentration >= 20 && volume > 0 {
			calculateButton.isEnabled = true
		} else {
			calculateButton.isEnabled = false
		}
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		
		switch textField.tag {
		case 1:
			return checkIfTextIsDouble(textField.text!.appending(string))
		case 2:
			return checkIfTextIsInt(textField.text!.appending(string))
		default:
			return false
		}
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		self.activeTextField = textField
		
		if let possibleNextTextField = view.viewWithTag(textField.tag + 1) as? UIControl {
			self.nextTextField = possibleNextTextField
		} else {
			self.nextTextField = nil
		}
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		self.activeTextField = nil
		self.nextTextField = nil
		
		checkCalculateButton()
	}
	
	@objc func keyboardWillShow(notification: NSNotification) {
		guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
		
		if let _ = activeTextField, let nextTextField = nextTextField {
			let bottomOfNextItem = nextTextField.convert(nextTextField.bounds, to: self.view).maxY
			let topOfKeyboard = keyboardSize.origin.y
			
			if bottomOfNextItem > topOfKeyboard {
				UIView.animate(withDuration: 0.5, animations: {
					self.view.bounds.origin.y = bottomOfNextItem - topOfKeyboard
				})
			} else {
				UIView.animate(withDuration: 0.5, animations: {
					self.view.bounds.origin.y = 0
				})
			}
		}
	}
	
	@objc func keyboardWillHide(notification: NSNotification) {
		self.view.bounds.origin.y = 0
	}
}
