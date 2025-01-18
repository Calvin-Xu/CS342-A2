//
//  Medication.swift
//  CS342-A1
//
//  Created by Calvin Xu on 1/12/25.
//

// A Medication type that represents a medication a doctor has prescribed to a patient, which includes at least following properties with appropriate data types:
// Date prescribed
// Name (e.g. “Aspirin”)
// Dose (e.g. 25 mg)
// Route (e.g. by mouth, subcutaneously, inhaled)
// Frequency (number of times per day the medication is to be taken)
// Duration (number of days the medication should be taken)
//
// Here are some examples of medications a patient might be prescribed:
//
// Metoprolol 25 mg by mouth once daily for 90 days
// Aspirin 81 mg by mouth once daily for 90 days
// Losartan 12.5 mg by mouth once daily for 90 days

import Foundation

struct Medication: Codable, Equatable {
    let name: String
    let dose: Double
    let route: String
    let frequency: Int
    let duration: Int
    let datePrescribed: Date

    var isActive: Bool {
        guard
            let endDate = Calendar.current.date(byAdding: .day, value: duration, to: datePrescribed)
        else {
            return false
        }
        return Date() < endDate
    }
}

enum MedicationError: Error, CustomStringConvertible, Equatable {
    case duplicateMedication(String)

    var description: String {
        switch self {
        case .duplicateMedication(let name):
            return "Medication \(name) already prescribed and active"
        }
    }
}

// additional functionality
extension Medication: CustomStringConvertible {
    var description: String {
        return "\(name) \(dose) mg \(route) \(dosageDescription) for \(duration) days"
    }
}

extension Medication {
    var endDate: Date {
        return Calendar.current.date(byAdding: .day, value: duration, to: datePrescribed)
            ?? datePrescribed  // not sure if this is the best way if such an error occurs
    }

    var daysRemaining: Int {
        guard isActive else {
            return 0
        }
        return Calendar.current.dateComponents([.day], from: Date(), to: endDate).day ?? 0
    }

    var dosageDescription: String {
        switch frequency {
        case 1:
            return "once daily"
        case 2:
            return "twice daily"
        default:
            return "\(frequency) times daily"
        }
    }
}
