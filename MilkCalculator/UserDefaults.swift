//
//  UserDefaults.swift
//  MilkCalculator
//
//  Created by Matthew Kelling on 6/12/23.
//

import Foundation
import UIKit

//let FormulaOneTeaspoonIsInOunces = 0.08768085714

func checkIfTextIsDouble(_ string: String) -> Bool {
	if let _ = Double(string) {
		return true
	} else if string == "." {
		return true
	} else {
		return false
	}
}

func checkIfTextIsInt(_ string: String) -> Bool {
	if let _ = Int(string) {
		return true
	} else if string == "." {
		return true
	} else {
		return false
	}
}

func textFieldChanged(_ textField: UITextField, variable: inout Double) {
	if let double = Double(textField.text!), double != 0 {
		variable = double
	}
	textField.text = variable.stringWithoutTrailingZero
}

func textFieldChanged(_ textField: UITextField, variable: inout Int) {
	if let int = Int(textField.text!), int != 0 {
		variable = int
	}
	textField.text = String(variable)
}

extension Double {
	var stringWithoutTrailingZero: String {
		return truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
	}
}

extension UnitVolume {
	static let scoop = UnitVolume(symbol: "sc", converter: UnitConverterLinear(coefficient: 0.00492892 * 3.5))
}

//func formulaKcalConvertToScoop(endingKcal: Int) -> Double {
//	return (Double(endingKcal) - Double(Settings.formulaConcentration)) / Double(Settings.formulaConcentration)
//}

func roundToFraction(_ number: Double) -> String {
	let wholeNumber = Int(number)
	let decimal = number - Double(wholeNumber)
	let wholeNumberAsString: String
	
	let mixedDecimal = decimal * 8
	let mixedInt = round(mixedDecimal)
	
	if wholeNumber == 0 {
		wholeNumberAsString = ""
	} else {
		wholeNumberAsString = "\(String(wholeNumber)) "
	}
	
	switch mixedInt {
	case 0:
		return "\(String(wholeNumber))"
	case 1:
		return "\(wholeNumberAsString)⅛"
	case 2:
		return "\(wholeNumberAsString)¼"
	case 3:
		return "\(wholeNumberAsString)⅜"
	case 4:
		return "\(wholeNumberAsString)½"
	case 5:
		return "\(wholeNumberAsString)⅝"
	case 6:
		return "\(wholeNumberAsString)¾"
	case 7:
		return "\(wholeNumberAsString)⅞"
	case 8:
		return "\(String(wholeNumber + 1))"
	default:
		return "error"
	}
}

func addDoneButtonOnNumpad(_ self: UIViewController, textField: UITextField) {
	   let keypadToolbar: UIToolbar = UIToolbar()
	   
	   keypadToolbar.items=[
		   UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: textField, action: #selector(UITextField.resignFirstResponder)),
		   UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
	   ]
	   
	   keypadToolbar.sizeToFit()
	   textField.inputAccessoryView = keypadToolbar
   }

func loadKeyboardNotifications(_ self: UIViewController) {
	NotificationCenter.default.addObserver(self, selector: #selector(PumpViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
	NotificationCenter.default.addObserver(self, selector: #selector(PumpViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
}
