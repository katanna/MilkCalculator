//
//  FortifyModel.swift
//  MilkCalculator
//
//  Created by Matthew Kelling on 5/6/23.
//

import Foundation

class Fortify {
	var milkType: FortifyMilkType = .formula
	var startOrEnd: FortifyStartOrEnd = .start
	var volume = 0.0
	var volumeUnit: FortifyVolumeUnit = .oz
	var concentration = 0
}

enum FortifyMilkType: CaseIterable {
	case breast
	case formula
	case water
	
	func description() -> String {
		switch self {
		case .breast:
			return "breast milk"
		case .formula:
			return "prepared formula milk"
		case .water:
			return "water"
		}
	}
}

enum FortifyStartOrEnd: CaseIterable {
	case start
	case end
	
	func description() -> String {
		switch self {
		case .start:
			return "start with"
		case .end:
			return "end with"
		}
	}
}

enum FortifyVolumeUnit: CaseIterable {
	case ml
	case oz

	func description() -> String {
		switch self {
		case .ml:
			return "ml"
		case .oz:
			return "oz"
		}
	}
}
