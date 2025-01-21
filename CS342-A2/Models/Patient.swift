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
// A method that returns the patient's full name and age in years as a string in the format "Last name, First name (Age in years)", as it might be displayed in a list.
// A method that returns a list of Medications the Patient is currently taking, ordered by date prescribed, excluding any completed medications.
// A method to prescribe a new Medication to a Patient, while avoiding duplicating medications the patient is currently taking. If a duplicate is prescribed, the method should throw an appropriate errorLinks to an external site..
// Bonus: Implement a method to determine which donor blood types a Patient can receive a blood transfusion from

/// A type representing a medical patient with their personal and medical information.
import Foundation

class Patient: ObservableObject {
    // MARK: - Properties

    /// A unique identifier for the patient's medical record.
    let medicalRecordNumber: UUID

    /// The patient's first name.
    @Published var firstName: String

    /// The patient's last name.
    @Published var lastName: String

    /// The patient's date of birth.
    @Published var dateOfBirth: Date

    /// The patient's height in millimeters.
    @Published var height_mm: Int

    /// The patient's weight in grams.
    @Published var weight_g: Int

    /// The patient's blood type, if known.
    @Published var bloodType: BloodType?

    /// A list of all medications the patient is currently taking or has taken.
    @Published private(set) var medications: [Medication]

    // Computed Properties
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

    /// A list of blood types that the patient can receive from.
    var compatibleBloodTypes: [BloodType] {
        bloodType?.compatibleBloodTypes ?? []
    }

    /// The patient's date of birth formatted as "YYYY-MM-DD".
    var dateOfBirthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: dateOfBirth)
    }

    // MARK: - Init

    init(
        firstName: String,
        lastName: String,
        dateOfBirth: Date,
        height: Int,
        weight: Int,
        bloodType: BloodType? = nil
    ) throws {
        guard dateOfBirth <= .now else {
            throw PatientError.futureDateOfBirth
        }
        self.medicalRecordNumber = UUID()
        self.firstName = firstName
        self.lastName = lastName
        self.dateOfBirth = dateOfBirth
        self.height_mm = height
        self.weight_g = weight
        self.bloodType = bloodType
        self.medications = []
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        medicalRecordNumber = try container.decode(UUID.self, forKey: .medicalRecordNumber)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        dateOfBirth = try container.decode(Date.self, forKey: .dateOfBirth)
        height_mm = try container.decode(Int.self, forKey: .height_mm)
        weight_g = try container.decode(Int.self, forKey: .weight_g)
        bloodType = try container.decodeIfPresent(BloodType.self, forKey: .bloodType)
        medications = try container.decode([Medication].self, forKey: .medications)
    }

    // MARK: - Methods

    /// Prescribes a new medication to the patient.
    /// - Parameter medication: The medication to prescribe
    /// - Throws: `MedicationError.duplicateMedication` if the patient is already taking this medication
    func prescribe(medication: Medication) throws {
        if medications.contains(where: { $0.name == medication.name && $0.isActive }) {
            throw MedicationError.duplicateMedication(medication.name)
        }
        medications.append(medication)
    }

    /// Removes a medication from the patient's list of medications.
    /// - Parameter medication: The medication to remove
    func removeMedication(_ medication: Medication) {
        medications.removeAll { $0.id == medication.id }
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

extension Patient: Codable, Hashable, Equatable {
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case medicalRecordNumber
        case firstName
        case lastName
        case dateOfBirth
        case height_mm
        case weight_g
        case bloodType
        case medications
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(medicalRecordNumber, forKey: .medicalRecordNumber)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(dateOfBirth, forKey: .dateOfBirth)
        try container.encode(height_mm, forKey: .height_mm)
        try container.encode(weight_g, forKey: .weight_g)
        try container.encode(bloodType, forKey: .bloodType)
        try container.encode(medications, forKey: .medications)
    }

    // MARK: - Equatable
    static func == (lhs: Patient, rhs: Patient) -> Bool {
        lhs.medicalRecordNumber == rhs.medicalRecordNumber
    }

    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(medicalRecordNumber)
    }
}

extension Patient: CustomStringConvertible {
    var description: String {
        """
        Patient: \(fullNameAndAge)
        MRN: \(medicalRecordNumber)
        Date of Birth: \(dateOfBirthString)
        Blood Type: \(bloodType?.rawValue ?? "Unknown")
        Height: \(Double(height_mm) / 10) cm
        Weight: \(Double(weight_g) / 1000) kg
        Active Medications:
        \(currentMedications.map { "\($0.description) (\($0.daysRemaining) days remaining)" }.joined(separator: "\n"))
        """
    }
}

extension Patient {
    /// Sample patients for previews and testing
    static var samples: [Patient] = {
        do {
            return try [
                Patient(
                    firstName: "John", lastName: "Doe",
                    dateOfBirth: Date(timeIntervalSince1970: 548_186_691),
                    height: 1800, weight: 70000, bloodType: .abPositive
                ),
                Patient(
                    firstName: "Jane", lastName: "Smith",
                    dateOfBirth: Date(timeIntervalSince1970: 748_186_691),
                    height: 1650, weight: 65000, bloodType: .bNegative
                ),
                Patient(
                    firstName: "Robert", lastName: "Anderson",
                    dateOfBirth: Date(timeIntervalSince1970: 948_186_691),
                    height: 1750, weight: 80000, bloodType: .oPositive
                ),
            ]
        } catch {
            print("Failed to create sample patients: \(error)")
            return []
        }
    }()
}
