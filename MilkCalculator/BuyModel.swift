//
//  BuyModel.swift
//  MilkCalculator
//
//  Created by Matthew Kelling on 5/6/23.
//

import Foundation

class Buy {
	var volume = 0.0
	var volumeUnit: BuyVolumeUnit = .scoop
	var timesPerDay = 0
	var canMass = 0.0
	var canMassUnit: BuyCanMassUnit = .oz
}

enum BuyVolumeUnit: CaseIterable {
	case tsp
	case tbsp
	case ml
	case scoop
//	case g
	
	func description() -> String {
		switch self {
		case .tsp:
			return "tsp"
		case .tbsp:
			return "tbsp"
		case .ml:
			return "ml"
		case .scoop:
			return "scoop"
//		case .g:
//			return "gram"
		}
	}
}

enum BuyCanMassUnit: CaseIterable {
	case oz
	case lbs
	case g
	
	func description() -> String {
		switch self {
		case .oz:
			return "oz"
		case .lbs:
			return "lbs"
		case .g:
			return "gram"
		}
	}
}
