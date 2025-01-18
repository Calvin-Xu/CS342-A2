//
//  Patient.swift
//  CS342-A1
//
//  Created by Calvin Xu on 1/12/25.
//

// A Patient type that includes at least the following properties:
// Medical record number (a unique identifier which should be auto generated when creating a patient)
// First name
// Last name
// Date of birth
// Height
// Weight
// Blood type (which might not be known at the time of creating a patient)
// A list of all Medications the patient is currently taking or has taken in the past
// A proper initializer utilizing Swift features such as default values.
//
// And the following methods:
//
// A method that returns the patient’s full name and age in years as a string in the format “Last name, First name (Age in years)”, as it might be displayed in a list.
// A method that returns a list of Medications the Patient is currently taking, ordered by date prescribed, excluding any completed medications.
// A method to prescribe a new Medication to a Patient, while avoiding duplicating medications the patient is currently taking. If a duplicate is prescribed, the method should throw an appropriate errorLinks to an external site..
// Bonus: Implement a method to determine which donor blood types a Patient can receive a blood transfusion from

import Foundation

/// A type representing a medical patient with their personal and medical information.
struct Patient {
    // Instance Properties
    /// A unique identifier for the patient's medical record.
    let medicalRecordNumber: UUID

    /// The patient's first name.
    var firstName: String

    /// The patient's last name.
    var lastName: String

    /// The patient's date of birth.
    var dateOfBirth: Date

    /// The patient's height in millimeters.
    var height: Int

    /// The patient's weight in grams.
    var weight: Int

    /// The patient's blood type, if known.
    var bloodType: BloodType?

    /// A list of all medications the patient is currently taking or has taken.
    private(set) var medications: [Medication]

    // Computed Instance Properties
    /// The patient's full name and age formatted as "Last name, First name (Age)".
    var fullNameAndAge: String {
        let ageInYears =
            Calendar.current.dateComponents([.year], from: dateOfBirth, to: .now).year ?? 0
        return "\(lastName), \(firstName) (\(ageInYears))"
    }

    /// A list of medications the patient is currently taking, sorted by prescription date.
    var currentMedications: [Medication] {
        medications.filter { $0.isActive }.sorted { $0.datePrescribed < $1.datePrescribed }
    }

    /// A list of blood types that are compatible for transfusion to this patient.
    var compatibleBloodTypes: [BloodType] {
        bloodType?.compatibleBloodTypes ?? []
    }

    /// The patient's date of birth formatted as "YYYY-MM-DD".
    var dateOfBirthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: dateOfBirth)
    }

    /// Creates a new patient with the specified information.
    /// - Parameters:
    ///   - firstName: The patient's first name
    ///   - lastName: The patient's last name
    ///   - dateOfBirth: The patient's date of birth
    ///   - height: The patient's height in millimeters
    ///   - weight: The patient's weight in grams
    ///   - bloodType: The patient's blood type, if known
    /// - Throws: `PatientError.futureDateOfBirth` if the date of birth is in the future
    init(
        firstName: String, lastName: String, dateOfBirth: Date, height: Int, weight: Int,
        bloodType: BloodType? = nil
    ) throws {
        guard dateOfBirth <= .now else {
            throw PatientError.futureDateOfBirth
        }

        self.medicalRecordNumber = UUID()
        self.firstName = firstName
        self.lastName = lastName
        self.dateOfBirth = dateOfBirth
        self.height = height
        self.weight = weight
        self.bloodType = bloodType
        self.medications = []
    }

    /// Prescribes a new medication to the patient.
    /// - Parameter medication: The medication to prescribe
    /// - Throws: `MedicationError.duplicateMedication` if the patient is already taking this medication
    mutating func prescribe(medication: Medication) throws {
        if medications.contains(where: { $0.name == medication.name && $0.isActive }) {
            throw MedicationError.duplicateMedication(medication.name)
        }
        medications.append(medication)
    }

    /// Checks if this patient can receive blood from a donor.
    /// - Parameter donor: The potential blood donor
    /// - Returns: Whether the donor's blood type is compatible with this patient
    /// - Throws: `PatientError.invalidBloodTypeForTransfusion` if the donor's blood type is unknown
    func canReceiveBlood(from donor: Patient) throws -> Bool {
        guard let donorBloodType = donor.bloodType, bloodType != nil else {
            throw PatientError.invalidBloodTypeForTransfusion
        }
        return compatibleBloodTypes.contains(donorBloodType)
    }
}

// Extensions
extension Patient: Codable, Equatable {
    static func == (lhs: Patient, rhs: Patient) -> Bool {
        lhs.medicalRecordNumber == rhs.medicalRecordNumber
    }
}

extension Patient: CustomStringConvertible {
    var description: String {
        """
        Patient: \(fullNameAndAge)
        MRN: \(medicalRecordNumber)
        Date of Birth: \(dateOfBirthString)
        Blood Type: \(bloodType?.rawValue ?? "Unknown")
        Height: \(Double(height) / 10) cm
        Weight: \(Double(weight) / 1000) kg
        Active Medications:
        \(currentMedications.map { "\($0.description) (\($0.daysRemaining) days remaining)" }.joined(separator: "\n"))
        """
    }
}
