//
//  BloodType.swift
//  CS342-A1
//
//  Created by Calvin Xu on 1/12/25.
//

/// A type representing human blood types with their Rh factors.
enum BloodType: String, Codable, CaseIterable {
    /// Type A positive blood (A+)
    case aPositive = "A+"

    /// Type A negative blood (A-)
    case aNegative = "A-"

    /// Type B positive blood (B+)
    case bPositive = "B+"

    /// Type B negative blood (B-)
    case bNegative = "B-"

    /// Type O positive blood (O+)
    case oPositive = "O+"

    /// Type O negative blood (O-)
    case oNegative = "O-"

    /// Type AB positive blood (AB+)
    case abPositive = "AB+"

    /// Type AB negative blood (AB-)
    case abNegative = "AB-"

    /// A list of blood types that can safely donate blood to this blood type.
    var compatibleBloodTypes: [BloodType] {
        switch self {
        case .abPositive:
            // AB+ can receive from all blood types
            return BloodType.allCases
        case .abNegative:
            // AB- can receive from all negative blood types
            return [.oNegative, .bNegative, .aNegative, .abNegative]
        case .aPositive:
            // A+ can receive from A+, A-, O+, O-
            return [.oNegative, .oPositive, .aNegative, .aPositive]
        case .aNegative:
            // A- can receive from A-, O-
            return [.oNegative, .aNegative]
        case .bPositive:
            // B+ can receive from B+, B-, O+, O-
            return [.oNegative, .oPositive, .bNegative, .bPositive]
        case .bNegative:
            // B- can receive from B-, O-
            return [.oNegative, .bNegative]
        case .oPositive:
            // O+ can receive from O+, O-
            return [.oNegative, .oPositive]
        case .oNegative:
            // O- can only receive from O-
            return [.oNegative]
        }
    }
}
