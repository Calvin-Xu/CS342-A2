//
//  BloodType.swift
//  CS342-A1
//
//  Created by Calvin Xu on 1/12/25.
//

// a type called BloodType, which can be A+, A-, B+, B-, O+, O-, AB+ or AB-.

enum BloodType: String, Codable, CaseIterable {
    case APositive = "A+"
    case ANegative = "A-"
    case BPositive = "B+"
    case BNegative = "B-"
    case OPositive = "O+"
    case ONegative = "O-"
    case ABPositive = "AB+"
    case ABNegative = "AB-"

    func compatibleBloodTypes() -> [BloodType] {
        switch self {
        case .ABPositive:
            return BloodType.allCases
        case .ABNegative:
            return [.ONegative, .BNegative, .ANegative, .ABNegative]
        case .APositive:
            return [.ONegative, .OPositive, .ANegative, .APositive]
        case .ANegative:
            return [.ONegative, .ANegative]
        case .BPositive:
            return [.ONegative, .OPositive, .BNegative, .BPositive]
        case .BNegative:
            return [.ONegative, .BNegative]
        case .OPositive:
            return [.ONegative, .OPositive]
        case .ONegative:
            return [.ONegative]
        }
    }
}
