//
//  CS342_A1Tests.swift
//  CS342-A1Tests
//
//  Created by Calvin Xu on 1/12/25.
//

import Foundation
import Testing

@testable import CS342_A2

struct CS342_A1Tests {
    var patient = Patient(
        firstName: "John", lastName: "Doe", dateOfBirth: "1990-01-01", height: 180, weight: 70,
        bloodType: .ABPositive)

    @Test func testPatientInitialization() async throws {
        #expect(patient.firstName == "John")
        #expect(patient.lastName == "Doe")
        #expect(patient.height == 180)
        #expect(patient.weight == 70)
        #expect(patient.bloodType == .ABPositive)
        #expect(patient.medications.isEmpty)
        #expect(patient.medicalRecordNumber.uuidString != "")
        #expect(patient.description.contains("AB+"))
        #expect(patient.description.contains("180.0 cm"))
        #expect(patient.description.contains("70.0 kg"))
    }

    @Test func testPatientFullNameAndAge() async throws {
        #expect(patient.fullNameAndAge().contains("Doe, John"))
        #expect(
            patient.fullNameAndAge().contains("(35)")
                || patient.fullNameAndAge().contains(
                    String(
                        Calendar.current.dateComponents(
                            [.year], from: patient.dateOfBirth, to: Date()
                        ).year ?? 0))
        )
    }

    @Test func testPatientBloodType() async throws {
        let patient2 = Patient(
            firstName: "Jane", lastName: "Doe", dateOfBirth: "1990-01-01", height: 180, weight: 70,
            bloodType: .ONegative)
        #expect(patient2.bloodType == .ONegative)
        #expect(patient2.description.contains("O-"))
        #expect(patient2.bloodType != patient.bloodType)
        #expect(!patient2.compatibleBloodTypes().contains(patient.bloodType!))
        #expect(patient.compatibleBloodTypes().contains(patient2.bloodType!))
        #expect(patient.canReceiveBlood(from: patient2))
        #expect(!patient2.canReceiveBlood(from: patient))
    }

    @Test func testMedicationInitialization() async throws {
        let dateNow = Date()
        let medication1 = Medication(
            name: "Medication 1", dose: 20, route: "by mouth", frequency: 1, duration: 10,
            datePrescribed: dateNow)

        #expect(medication1.name == "Medication 1")
        #expect(medication1.dose == 20)
        #expect(medication1.route == "by mouth")
        #expect(medication1.frequency == 1)
        #expect(medication1.duration == 10)
        #expect(medication1.datePrescribed == dateNow)
    }

    @Test mutating func testPatientPrescribeMedication() async throws {
        let medication1 = Medication(
            name: "Medication 1", dose: 20, route: "by mouth", frequency: 1, duration: 10,
            datePrescribed: Date())
        try patient.prescribe(medication: medication1)
        #expect(patient.medications.count == 1)
        #expect(patient.medications[0].name == "Medication 1")
        #expect(patient.medications[0] == medication1)
        #expect(
            patient.medications[0].description
                == "Medication 1 20.0 mg by mouth once daily for 10 days")
        #expect(patient.medications[0].daysRemaining == 9)
        #expect(
            patient.description.contains(
                "Medication 1 20.0 mg by mouth once daily for 10 days (9 days remaining)"))
    }

    @Test mutating func testPatientPrescribeDuplicateMedication() async throws {
        let medication1 = Medication(
            name: "Medication 1", dose: 20, route: "by mouth", frequency: 1, duration: 10,
            datePrescribed: Date())
        try patient.prescribe(medication: medication1)
        #expect(patient.medications.count == 1)
        #expect(patient.medications[0].name == "Medication 1")
        #expect(patient.medications[0] == medication1)
        #expect(throws: MedicationError.duplicateMedication("Medication 1")) {
            try patient.prescribe(medication: medication1)
        }
    }

    @Test mutating func testPatientCurrentMedications() async throws {
        let medication1 = Medication(
            name: "Medication 1", dose: 20, route: "by mouth", frequency: 1, duration: 10,
            datePrescribed: Date())
        let medication2 = Medication(
            name: "Medication 2", dose: 20, route: "by mouth", frequency: 1, duration: 10,
            datePrescribed: Calendar.current.date(byAdding: .day, value: -100, to: Date())!)
        let medication3 = Medication(
            name: "Medication 3", dose: 20, route: "inhaled", frequency: 2, duration: 200,
            datePrescribed: Calendar.current.date(byAdding: .day, value: -100, to: Date())!)
        try patient.prescribe(medication: medication1)
        try patient.prescribe(medication: medication2)
        try patient.prescribe(medication: medication3)
        #expect(patient.currentMedications().count == 2)
        #expect(patient.currentMedications().contains(medication1))
        #expect(!patient.currentMedications().contains(medication2))
        #expect(patient.currentMedications().contains(medication3))
        #expect(patient.currentMedications()[0] == medication3)
        #expect(patient.currentMedications()[1] == medication1)
    }

    // Claude-3.5-sonnet
    // "please help me add additional cases to testPatientCompatibleBloodTypes using this chart ..."
    @Test func testPatientCompatibleBloodTypes() async throws {
        // AB+ (universal recipient)
        var patient = Patient(
            firstName: "Test", lastName: "Patient", dateOfBirth: "1990-01-01", height: 170,
            weight: 70, bloodType: .ABPositive)
        var compatibleTypes = patient.compatibleBloodTypes()
        #expect(compatibleTypes.count == 8)
        #expect(compatibleTypes == BloodType.allCases)

        // O- (universal donor)
        patient = Patient(
            firstName: "Test", lastName: "Patient", dateOfBirth: "1990-01-01", height: 170,
            weight: 70, bloodType: .ONegative)
        compatibleTypes = patient.compatibleBloodTypes()
        #expect(compatibleTypes.count == 1)
        #expect(compatibleTypes.contains(.ONegative))

        // O+
        patient = Patient(
            firstName: "Test", lastName: "Patient", dateOfBirth: "1990-01-01", height: 170,
            weight: 70, bloodType: .OPositive)
        compatibleTypes = patient.compatibleBloodTypes()
        #expect(compatibleTypes.count == 2)
        #expect(compatibleTypes.contains(.ONegative))
        #expect(compatibleTypes.contains(.OPositive))

        // A+
        patient = Patient(
            firstName: "Test", lastName: "Patient", dateOfBirth: "1990-01-01", height: 170,
            weight: 70, bloodType: .APositive)
        compatibleTypes = patient.compatibleBloodTypes()
        #expect(compatibleTypes.count == 4)
        #expect(compatibleTypes.contains(.APositive))
        #expect(compatibleTypes.contains(.ANegative))
        #expect(compatibleTypes.contains(.OPositive))
        #expect(compatibleTypes.contains(.ONegative))

        // B-
        patient = Patient(
            firstName: "Test", lastName: "Patient", dateOfBirth: "1990-01-01", height: 170,
            weight: 70, bloodType: .BNegative)
        compatibleTypes = patient.compatibleBloodTypes()
        #expect(compatibleTypes.count == 2)
        #expect(compatibleTypes.contains(.BNegative))
        #expect(compatibleTypes.contains(.ONegative))

        // fuzz that all blood types are compatible with themselves
        for bloodType in BloodType.allCases {
            patient = Patient(
                firstName: "Test", lastName: "Patient", dateOfBirth: "1990-01-01", height: 170,
                weight: 70, bloodType: bloodType)
            compatibleTypes = patient.compatibleBloodTypes()
            #expect(compatibleTypes.contains(bloodType))
        }
    }
}
