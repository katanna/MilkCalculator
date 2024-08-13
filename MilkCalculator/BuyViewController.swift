//
//  BuyViewController.swift
//  MilkCalculator
//
//  Created by Matthew Kelling on 5/6/23.
//

import UIKit

class BuyViewController: UIViewController, UITextFieldDelegate {
	
	var buy = Buy()
	
	@IBOutlet var volumeTextField: UITextField!
	@IBOutlet var volumeUnitSelector: UISegmentedControl!
	@IBOutlet var timesPerDayTextField: UITextField!
	@IBOutlet var canMassTextField: UITextField!
	@IBOutlet var canMassUnitSelector: UISegmentedControl!
	@IBOutlet var calculateButton: UIButton!
	@IBOutlet var answerText: UILabel!
	
	var activeTextField: UITextField? = nil
	var nextTextField: UIControl? = nil
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		volumeTextField.delegate = self
		timesPerDayTextField.delegate = self
		canMassTextField.delegate = self
		
		addDoneButtonOnNumpad(self, textField: volumeTextField)
		addDoneButtonOnNumpad(self, textField: timesPerDayTextField)
		addDoneButtonOnNumpad(self, textField: canMassTextField)
		
		loadKeyboardNotifications(self)
		
		setUpSegmentedControllers()
		loadDefaults()
	}
	
	func setUpSegmentedControllers() {
		volumeUnitSelector.removeAllSegments()
		BuyVolumeUnit.allCases.forEach {
			volumeUnitSelector.insertSegment(withTitle: $0.description(), at: volumeUnitSelector.numberOfSegments, animated: false)
		}
		
		canMassUnitSelector.removeAllSegments()
		BuyCanMassUnit.allCases.forEach {
			canMassUnitSelector.insertSegment(withTitle: $0.description(), at: canMassUnitSelector.numberOfSegments, animated: false)
		}
	}
	
	func loadDefaults() {
		if buy.volume == 0 {
			volumeTextField.text = ""
		} else {
			volumeTextField.text = buy.volume.stringWithoutTrailingZero
		}
		
		volumeUnitSelector.selectedSegmentIndex = BuyVolumeUnit.allCases.firstIndex(of: buy.volumeUnit)!
		
		if buy.timesPerDay == 0 {
			timesPerDayTextField.text = ""
		} else {
			timesPerDayTextField.text = String(buy.timesPerDay)
		}
		
		if buy.canMass == 0 {
			canMassTextField.text = ""
		} else {
			canMassTextField.text = buy.canMass.stringWithoutTrailingZero
		}
		
		canMassUnitSelector.selectedSegmentIndex = BuyCanMassUnit.allCases.firstIndex(of: buy.canMassUnit)!
		
		answerText.text = ""
		
		calculateButton.isEnabled = false
		checkCalculateButton()
		if calculateButton.isEnabled {
			findAnswer(withAnimation: false)
		}
	}
	
	@IBAction func VolumeChanged(_ sender: UITextField) {
		textFieldChanged(sender, variable: &buy.volume)
	}
	
	@IBAction func volumeUnitChanged(_ sender: UISegmentedControl) {
		buy.volumeUnit = BuyVolumeUnit.allCases[sender.selectedSegmentIndex]
	}
	
	@IBAction func timesPerDayChanged(_ sender: UITextField) {
		textFieldChanged(sender, variable: &buy.timesPerDay)
	}
	
	@IBAction func canMassChanged(_ sender: UITextField) {
		textFieldChanged(sender, variable: &buy.canMass)
	}
	
	@IBAction func canMassUnitChanged(_ sender: UISegmentedControl) {
		buy.canMassUnit = BuyCanMassUnit.allCases[sender.selectedSegmentIndex]
	}
	
	@IBAction func calculateButtonPressed(_ sender: UIButton) {
		volumeTextField.resignFirstResponder()
		timesPerDayTextField.resignFirstResponder()
		canMassTextField.resignFirstResponder()
		
		findAnswer(withAnimation: true)
	}
	
	func findAnswer (withAnimation animate: Bool) {
		
	//Set Can Mass (in ounces)
		let massUnitName: UnitMass
		
		switch buy.canMassUnit {
		case .oz:
			massUnitName = UnitMass.ounces
		case .lbs:
			massUnitName = UnitMass.pounds
		case .g:
			massUnitName = UnitMass.grams
		}
		
		let massAsMeasurement = Measurement(value: Double(canMassTextField.text!)!, unit: massUnitName)
		let canMassInOunces = massAsMeasurement.converted(to: UnitMass.ounces).value
		
	//Set Volume per Feeding (in teaspoons)
		let volumeUnitName: UnitVolume
		
		switch buy.volumeUnit {
		case .tsp:
			volumeUnitName = UnitVolume.teaspoons
		case .tbsp:
			volumeUnitName = UnitVolume.tablespoons
		case .ml:
			volumeUnitName = UnitVolume.milliliters
		case .scoop:
			volumeUnitName = UnitVolume.scoop
//		case .g:
//			volumeUnitName = UnitVolume.gram
		}
		
		let volumeAsMeasurement = Measurement(value: Double(volumeTextField.text!)!, unit: volumeUnitName)
		let volumePerFeedingInTsp = volumeAsMeasurement.converted(to: UnitVolume.teaspoons).value
		
	//Set Times per Day
		let timesPerDay = buy.timesPerDay
		
	//Math for Cans per Day
		let cansPerDay = (volumePerFeedingInTsp * Double(timesPerDay) * 0.0811301) / canMassInOunces
		
	//Convert to Cans per Duration
		let durationInDays: Int
		
		switch Settings.buyDurationUnit {
		case .day:
			durationInDays = 1
		case .week:
			durationInDays = 7
		case .month:
			durationInDays = 30
		case .year:
			durationInDays = 365
		}
		
		let cansPerDuration = cansPerDay * Double(durationInDays)
		
		var cansPerDurationWithFraction: String {
			if cansPerDuration < 10 {
				return roundToFraction(cansPerDuration)
			} else {
				return String(round(cansPerDuration * 10)/10)
			}
		}
		
	//Output the Answer
		answerText.text = "So I will need to buy about \(cansPerDurationWithFraction) cans per \(Settings.buyDurationUnit.description())."
		
		if animate {
			UIView.animate(withDuration: 0.5, animations: {
				self.answerText.transform = CGAffineTransform(scaleX: 2, y: 2)
				self.answerText.transform = CGAffineTransform(scaleX: 1, y: 1)
			})
		}
	}
	
	@IBAction func textEditingChanged(_ sender: UITextField) {
		checkCalculateButton()
	}
	
	func checkCalculateButton() {
		let scoops = Double(volumeTextField.text!) ?? 0
		let timesPerDay = Int(timesPerDayTextField.text!) ?? 0
		let canMass = Double(canMassTextField.text!) ?? 0
		
		if scoops > 0 && timesPerDay > 0 && canMass > 0 {
			calculateButton.isEnabled = true
		} else {
			calculateButton.isEnabled = false
		}
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		
		switch textField.tag {
		case 1, 3:
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
