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

struct Patient {
    let medicalRecordNumber: UUID
    var firstName: String
    var lastName: String
    var dateOfBirth: Date
    var height: Double  // cm
    var weight: Double  // kg
    var bloodType: BloodType?
    private(set) var medications: [Medication]

    init(
        firstName: String, lastName: String, dateOfBirth: Date, height: Double, weight: Double,
        bloodType: BloodType? = nil
    ) {
        self.medicalRecordNumber = UUID()
        self.firstName = firstName
        self.lastName = lastName
        self.dateOfBirth = dateOfBirth
        self.height = height
        self.weight = weight
        self.bloodType = bloodType
        self.medications = []
    }

    // dateOfBirth from date string
    init(
        firstName: String, lastName: String, dateOfBirth: String, height: Double, weight: Double,
        bloodType: BloodType? = nil, dateFormat: String = "yyyy-MM-dd"
    ) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        self.medicalRecordNumber = UUID()
        self.firstName = firstName
        self.lastName = lastName
        self.dateOfBirth = dateFormatter.date(from: dateOfBirth)!  // throw if invalid
        self.height = height
        self.weight = weight
        self.bloodType = bloodType
        self.medications = []
    }

    func fullNameAndAge() -> String {
        let ageInYears =
            Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
        return "\(lastName), \(firstName) (\(ageInYears))"
    }

    func currentMedications(ascending: Bool = true) -> [Medication] {
        medications.filter { $0.isActive }.sorted(
            by: ascending
                ? { $0.datePrescribed < $1.datePrescribed }
                : { $0.datePrescribed > $1.datePrescribed })
    }

    mutating func prescribe(medication: Medication) throws {
        if medications.contains(where: { $0.name == medication.name && $0.isActive }) {
            throw MedicationError.duplicateMedication(medication.name)
        }
        medications.append(medication)
    }

    func compatibleBloodTypes() -> [BloodType] {
        bloodType?.compatibleBloodTypes() ?? []
    }

    func canReceiveBlood(from donor: Patient) -> Bool {
        compatibleBloodTypes().contains(donor.bloodType!)
    }
}

// additional functionality
extension Patient {
    var dateOfBirthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: dateOfBirth)
    }
}

extension Patient: Codable, Equatable {
    static func == (lhs: Patient, rhs: Patient) -> Bool {
        lhs.medicalRecordNumber == rhs.medicalRecordNumber
    }
}

extension Patient: CustomStringConvertible {
    var description: String {
        """
        Patient: \(fullNameAndAge())
        MRN: \(medicalRecordNumber)
        Date of Birth: \(dateOfBirthString)
        Blood Type: \(bloodType?.rawValue ?? "Unknown")
        Height: \(height) cm
        Weight: \(weight) kg
        Active Medications:
        \(currentMedications().map { "\($0.description) (\($0.daysRemaining) days remaining)" }.joined(separator: "\n"))
        """
    }
}
