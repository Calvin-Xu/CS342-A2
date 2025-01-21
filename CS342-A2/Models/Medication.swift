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

/// A type representing a medication prescribed to a patient.
struct Medication {
    /// The unique identifier for the medication.
    var id: UUID

    /// The name of the medication (e.g., "Aspirin").
    let name: String

    /// The dosage of the medication.
    let dosage: Dosage

    /// The route of administration.
    let route: MedicationRoute

    /// The number of times per day the medication should be taken.
    let frequency: Int

    /// The number of days the medication should be taken.
    let duration: Int

    /// The date when the medication was prescribed.
    let datePrescribed: Date

    /// Whether the medication is currently active based on the prescription duration.
    var isActive: Bool {
        guard
            let endDate = Calendar.current.date(byAdding: .day, value: duration, to: datePrescribed)
        else { return false }
        return .now < endDate
    }

    /// The date when the medication course ends.
    var endDate: Date {
        Calendar.current.date(byAdding: .day, value: duration, to: datePrescribed) ?? datePrescribed
    }

    /// The number of days remaining in the medication course.
    var daysRemaining: Int {
        guard isActive else { return 0 }
        return Calendar.current.dateComponents([.day], from: .now, to: endDate).day ?? 0
    }

    /// A human-readable description of the dosage frequency.
    var dosageDescription: String {
        switch frequency {
        case 1: return "once daily"
        case 2: return "twice daily"
        default: return "\(frequency) times daily"
        }
    }

    /// Initialize a new medication with the given properties.
    init(
        name: String, dosage: Dosage, route: MedicationRoute, frequency: Int,
        duration: Int, datePrescribed: Date
    ) {
        self.id = UUID()
        self.name = name
        self.dosage = dosage
        self.route = route
        self.frequency = frequency
        self.duration = duration
        self.datePrescribed = datePrescribed
    }
}

// Extensions
extension Medication: Codable, Equatable, Hashable {}

extension Medication: CustomStringConvertible {
    var description: String {
        "\(name) \(dosage.description) \(route.rawValue) \(dosageDescription) for \(duration) days"
    }
}
