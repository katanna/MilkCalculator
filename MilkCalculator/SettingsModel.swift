//
//  SettingsModel.swift
//  MilkCalculator
//
//  Created by Matthew Kelling on 6/3/23.
//

import Foundation

struct Settings {
	static var pumpFlowRateUnit: PumpFlowRateUnit = .mlHr
	static var fortifyAdditionalVolumeUnit: FortifyAdditionalVolumeUnit = .imperial
	static var buyDurationUnit: BuyDurationUnit = .month
	
//	static var formulaScoopSize: Double = 3.5
//	static var formulaScoopSizeUnit: FormulaScoopSizeUnit = .tsp
//	static var formulaWaterVolume: Double = 2.0
//	static var formulaWaterVolumeUnit: FormulaWaterMixVolumeUnit = .oz
//	static var formulaConcentration: Int = 20
}

enum PumpFlowRateUnit: CaseIterable {
	case mlHr
	case ozHr
	
	func description() -> String {
		switch self {
		case .mlHr:
			return "ml/hour"
		case .ozHr:
			return "oz/hour"
		}
	}
}

enum FortifyAdditionalVolumeUnit: CaseIterable {
	case imperial
	case ml
	case scoop
	
	func description() -> String {
		switch self {
		case .imperial:
			return "tsp/tbsp"
		case .ml:
			return "ml"
		case .scoop:
			return "scoop"
		}
	}
}

enum BuyDurationUnit: CaseIterable {
	case day
	case week
	case month
	case year
	
	func description() -> String {
		switch self {
		case .day:
			return "day"
		case .week:
			return "week"
		case .month:
			return "month"
		case .year:
			return "year"
		}
	}
}

//enum FormulaScoopSizeUnit: CaseIterable {
//	case tsp
//	case tbsp
//	case ml
//	
//	func description() -> String {
//		switch self {
//		case .tsp:
//			return "tsp"
//		case .tbsp:
//			return "tbsp"
//		case .ml:
//			return "ml"
//		}
//	}
//}
//
//enum FormulaWaterMixVolumeUnit: CaseIterable {
//	case oz
//	case ml
//	
//	func description() -> String {
//		switch self {
//		case .oz:
//			return "fl oz"
//		case .ml:
//			return "ml"
//		}
//	}
//}
