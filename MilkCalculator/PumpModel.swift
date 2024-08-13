//
//  PumpModel.swift
//  MilkCalculator
//
//  Created by Matthew Kelling on 5/6/23.
//

import Foundation

class Pump {
	var volume = 0.0
	var volumeUnit: PumpVolumeUnit = .ml
	var duration = 0.0
	var durationUnit: PumpDurationUnit = .min
}

enum PumpVolumeUnit: CaseIterable {
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

enum PumpDurationUnit: CaseIterable {
	case min
	case hour
	
	func description() -> String {
		switch self {
		case .min:
			return "minutes"
		case .hour:
			return "hours"
		}
	}
}
