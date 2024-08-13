//
//  PumpViewController.swift
//  MilkCalculator
//
//  Created by Matthew Kelling on 5/6/23.
//

import UIKit

class PumpViewController: UIViewController, UITextFieldDelegate {
	
	var pump = Pump()
	
	@IBOutlet var volumeTextField: UITextField!
	@IBOutlet var volumeUnitSelector: UISegmentedControl!
	@IBOutlet var durationTextField: UITextField!
	@IBOutlet var durationUnitSelector: UISegmentedControl!
	@IBOutlet var calculateButton: UIButton!
	@IBOutlet var answerText: UILabel!
	
	var activeTextField: UITextField? = nil
	var nextTextField: UIControl? = nil
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		volumeTextField.delegate = self
		durationTextField.delegate = self
		
		addDoneButtonOnNumpad(self, textField: volumeTextField)
		addDoneButtonOnNumpad(self, textField: durationTextField)
		
		loadKeyboardNotifications(self)
		
		setSegmentedControllers()
		loadDefaults()
	}
	
	func setSegmentedControllers() {
		volumeUnitSelector.removeAllSegments()
		PumpVolumeUnit.allCases.forEach {
			volumeUnitSelector.insertSegment(withTitle: $0.description(), at: volumeUnitSelector.numberOfSegments, animated: false)
		}
		
		durationUnitSelector.removeAllSegments()
		PumpDurationUnit.allCases.forEach {
			durationUnitSelector.insertSegment(withTitle: $0.description(), at: durationUnitSelector.numberOfSegments, animated: false)
		}
	}
	
	func loadDefaults() {
		if pump.volume == 0 {
			volumeTextField.text = ""
		} else {
			volumeTextField.text = pump.volume.stringWithoutTrailingZero
		}
		
		volumeUnitSelector.selectedSegmentIndex = PumpVolumeUnit.allCases.firstIndex(of: pump.volumeUnit)!
		
		if pump.duration == 0 {
			durationTextField.text = ""
		} else {
			durationTextField.text = pump.duration.stringWithoutTrailingZero
		}
		
		durationUnitSelector.selectedSegmentIndex = PumpDurationUnit.allCases.firstIndex(of: pump.durationUnit)!
		
		answerText.text = ""
		
		calculateButton.isEnabled = false
		checkCalculateButton()
		if calculateButton.isEnabled {
			findAnswer(withAnimation: false)
		}
	}
	
	@IBAction func volumeChanged(_ sender: UITextField) {
		textFieldChanged(sender, variable: &pump.volume)
	}
	
	@IBAction func volumeUnitChanged(_ sender: UISegmentedControl) {
		pump.volumeUnit = PumpVolumeUnit.allCases[sender.selectedSegmentIndex]
	}
	
	@IBAction func durationChanged(_ sender: UITextField) {
		textFieldChanged(sender, variable: &pump.duration)
	}
	
	@IBAction func durationUnitChanged(_ sender: UISegmentedControl) {
		pump.durationUnit = PumpDurationUnit.allCases[sender.selectedSegmentIndex]
	}
	
	@IBAction func calculateButtonPressed(_ sender: UIButton) {
		volumeTextField.resignFirstResponder()
		durationTextField.resignFirstResponder()
		
		findAnswer(withAnimation: true)
	}
	
	func findAnswer (withAnimation animate: Bool) {
		
	//Set Volume in ml
		let volumeUnit: UnitVolume
		
		switch pump.volumeUnit {
		case .ml:
			volumeUnit = UnitVolume.milliliters
		case .oz:
			volumeUnit = UnitVolume.fluidOunces
		}
		
		let volumeAsMeasurement = Measurement(value: pump.volume, unit: volumeUnit)
		let volumeInMl = volumeAsMeasurement.converted(to: UnitVolume.milliliters).value
		
	//Set Duration in Hours
		let durationInHours: Double
		
		switch pump.durationUnit {
		case .min:
			durationInHours = pump.duration / 60
		case .hour:
			durationInHours = pump.duration
		}
		
	//Calculate
		let answerInMlPerHour = volumeInMl / durationInHours
		
	//Set Flow Rate Volume (output) Unit
		 let flowRateVolumeUnit: UnitVolume
		 
		 switch Settings.pumpFlowRateUnit {
		 case .mlHr:
			 flowRateVolumeUnit = UnitVolume.milliliters
		 case .ozHr:
			 flowRateVolumeUnit = UnitVolume.fluidOunces
		 }
		
	//Final Conversion
		let answerAsMeasurement = Measurement(value: answerInMlPerHour, unit: UnitVolume.milliliters)
		var answerConverted = answerAsMeasurement.converted(to: flowRateVolumeUnit).value
		
	//Display Result
		if answerConverted < 1 {
			answerConverted = 1
		}
		
		answerText.text = "So I need to set my pump to \(Int(answerConverted)) \(Settings.pumpFlowRateUnit.description())."
		
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
		let volume = Double(volumeTextField.text!) ?? 0
		let duration = Double(durationTextField.text!) ?? 0
		
		if volume > 0 && duration > 0 {
			calculateButton.isEnabled = true
		} else {
			calculateButton.isEnabled = false
		}
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		return checkIfTextIsDouble(textField.text!.appending(string))
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
