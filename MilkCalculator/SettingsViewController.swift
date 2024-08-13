//
//  SettingsViewController.swift
//  MilkCalculator
//
//  Created by Matthew Kelling on 6/3/23.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate {
	
	@IBOutlet var pumpTimerUnitsSelector: UISegmentedControl!
	@IBOutlet var fortifyingVolumeUnitsSelector: UISegmentedControl!
	@IBOutlet var buyingTimeUnitsSelector: UISegmentedControl!
	@IBOutlet var disclaimerText: UILabel!
	
	
//	@IBOutlet var formulaScoopSizeText: UITextField!
//	@IBOutlet var formulaScoopSizeUnitSelector: UISegmentedControl!
//	@IBOutlet var formulaWaterMixVolumeText: UITextField!
//	@IBOutlet var formulaWaterMixVolumeUnitSelector: UISegmentedControl!
//	@IBOutlet var formulaConcentrationText: UITextField!
	
	var activeTextField: UITextField? = nil
	var nextTextField: UIControl? = nil
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setUpSegmentedControllers()
		loadDefaults()
		
		disclaimerText.text = "This app assumes some factors about your formula, such as a scoop size of 3.5 tablespoons, one scoop mixes with 2 fluid ounces of water, and a concentration of 20 kcal."
	}
	
	func setUpSegmentedControllers() {
		pumpTimerUnitsSelector.removeAllSegments()
		PumpFlowRateUnit.allCases.forEach {
			pumpTimerUnitsSelector.insertSegment(withTitle: $0.description(), at: pumpTimerUnitsSelector.numberOfSegments, animated: false)
		}
		
		fortifyingVolumeUnitsSelector.removeAllSegments()
		FortifyAdditionalVolumeUnit.allCases.forEach {
			fortifyingVolumeUnitsSelector.insertSegment(withTitle: $0.description(), at: fortifyingVolumeUnitsSelector.numberOfSegments, animated: false)
		}
		
		buyingTimeUnitsSelector.removeAllSegments()
		BuyDurationUnit.allCases.forEach {
			buyingTimeUnitsSelector.insertSegment(withTitle: $0.description(), at: buyingTimeUnitsSelector.numberOfSegments, animated: false)
		}
	}
	
	func loadDefaults() {
		pumpTimerUnitsSelector.selectedSegmentIndex = PumpFlowRateUnit.allCases.firstIndex(of: Settings.pumpFlowRateUnit)!
		fortifyingVolumeUnitsSelector.selectedSegmentIndex = FortifyAdditionalVolumeUnit.allCases.firstIndex(of: Settings.fortifyAdditionalVolumeUnit)!
		buyingTimeUnitsSelector.selectedSegmentIndex = BuyDurationUnit.allCases.firstIndex(of: Settings.buyDurationUnit)!
	}
	
	@IBAction func pumpFlowRateUnitChanged(_ sender: UISegmentedControl) {
		Settings.pumpFlowRateUnit = PumpFlowRateUnit.allCases[sender.selectedSegmentIndex]
	}
	
	@IBAction func fortifyAdditionalVolumeUnitChanged(_ sender: UISegmentedControl) {
		Settings.fortifyAdditionalVolumeUnit = FortifyAdditionalVolumeUnit.allCases[sender.selectedSegmentIndex]
	}
	
	@IBAction func buyDurationUnitChanged(_ sender: UISegmentedControl) {
		Settings.buyDurationUnit = BuyDurationUnit.allCases[sender.selectedSegmentIndex]
	}
}
