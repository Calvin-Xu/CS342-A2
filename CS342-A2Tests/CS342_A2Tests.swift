//
//  CS342_A2Tests.swift
//  CS342-A2Tests
//
//  Created by Calvin Xu on 1/12/25.
//

import Foundation
import Testing

@testable import CS342_A2

struct CS342_A2Tests {
    // Initialize with height in mm (1800mm = 180cm) and weight in g (70000g = 70kg)
    var patient = try! Patient(
        firstName: "John", lastName: "Doe", dateOfBirth: Date(timeIntervalSince1970: 948_186_691),  // Sat, 18 Jan 2000 09:11:31 GMT
        height: 1800, weight: 70000, bloodType: .abPositive
    )

    @Test func testPatientInitialization() async throws {
        #expect(patient.firstName == "John")
        #expect(patient.lastName == "Doe")
        #expect(patient.height_mm == 1800)  // 180cm in mm
        #expect(patient.weight_g == 70000)  // 70kg in g
        #expect(patient.bloodType == .abPositive)
        #expect(patient.medications.isEmpty)
        #expect(patient.medicalRecordNumber.uuidString != "")
        #expect(patient.description.contains("AB+"))
        #expect(patient.description.contains("180.0 cm"))  // Converted from mm in description
        #expect(patient.description.contains("70.0 kg"))  // Converted from g in description
        #expect(patient.dateOfBirthString == "2000-01-18")
    }

    @Test func testPatientInitializationWithFutureDate() async {
        let futureDate = Date.now.addingTimeInterval(1_000_000)
        #expect(throws: PatientError.futureDateOfBirth) {
            _ = try Patient(
                firstName: "John", lastName: "Doe", dateOfBirth: futureDate,
                height: 1800, weight: 70000
            )
        }
    }

    @Test func testPatientFullNameAndAge() async throws {
        #expect(patient.fullNameAndAge.contains("Doe, John"))
        #expect(patient.fullNameAndAge.contains(String(25)))  // Age as of 2024
    }

    @Test func testPatientBloodType() async throws {
        let patient2 = try Patient(
            firstName: "Jane", lastName: "Doe",
            dateOfBirth: Date(timeIntervalSince1970: 631_152_000),
            height: 1800, weight: 70000, bloodType: .oNegative
        )
        #expect(patient2.bloodType == .oNegative)
        #expect(patient2.description.contains("O-"))
        #expect(patient2.bloodType != patient.bloodType)
        #expect(!patient2.compatibleBloodTypes.contains(patient.bloodType!))
        #expect(patient.compatibleBloodTypes.contains(patient2.bloodType!))
        #expect(try patient.canReceiveBlood(from: patient2))
        #expect(try !patient2.canReceiveBlood(from: patient))
    }

    @Test func testMedicationInitialization() async throws {
        let dateNow = Date.now
        let medication1 = Medication(
            name: "Aspirin",
            dosage: Dosage(value: 81, unit: .milligrams),
            route: .oral,
            frequency: 1,
            duration: 90,
            datePrescribed: dateNow
        )

        #expect(medication1.name == "Aspirin")
        #expect(medication1.dosage.value == 81)
        #expect(medication1.dosage.unit == .milligrams)
        #expect(medication1.route == .oral)
        #expect(medication1.frequency == 1)
        #expect(medication1.duration == 90)
        #expect(medication1.datePrescribed == dateNow)
        #expect(medication1.description == "Aspirin 81mg by mouth once daily for 90 days")
        #expect(medication1.daysRemaining >= 89)
        #expect(medication1.isActive)
        #expect(
            medication1.endDate == Calendar.current.date(byAdding: .day, value: 90, to: dateNow)!)
    }

    @Test mutating func testPatientPrescribeMedication() async throws {
        let medication1 = Medication(
            name: "Metoprolol",
            dosage: Dosage(value: 25, unit: .milligrams),
            route: .oral,
            frequency: 1,
            duration: 90,
            datePrescribed: .now
        )
        try patient.prescribe(medication: medication1)
        #expect(patient.medications.count == 1)
        #expect(patient.medications[0].name == "Metoprolol")
        #expect(patient.medications[0] == medication1)
        #expect(
            patient.medications[0].description
                == "Metoprolol 25mg by mouth once daily for 90 days")
        #expect(patient.medications[0].daysRemaining >= 89)  // Account for time passing during test
        #expect(patient.description.contains("Metoprolol 25mg by mouth once daily for 90 days"))
    }

    @Test mutating func testPatientPrescribeDuplicateMedication() async throws {
        let medication1 = Medication(
            name: "Losartan",
            dosage: Dosage(value: 25, unit: .milligrams),
            route: .oral,
            frequency: 1,
            duration: 90,
            datePrescribed: .now
        )
        try patient.prescribe(medication: medication1)
        #expect(patient.medications.count == 1)
        #expect(patient.medications[0].name == "Losartan")
        #expect(patient.medications[0] == medication1)
        #expect(throws: MedicationError.duplicateMedication("Losartan")) {
            try patient.prescribe(medication: medication1)
        }
    }

    @Test mutating func testPatientCurrentMedications() async throws {
        let medication1 = Medication(
            name: "Current Med",
            dosage: Dosage(value: 25, unit: .milligrams),
            route: .oral,
            frequency: 1,
            duration: 90,
            datePrescribed: .now
        )
        let medication2 = Medication(
            name: "Past Med",
            dosage: Dosage(value: 25, unit: .milligrams),
            route: .oral,
            frequency: 1,
            duration: 10,
            datePrescribed: .now.addingTimeInterval(-86400 * 20)  // 20 days ago
        )
        let medication3 = Medication(
            name: "Long Term Med",
            dosage: Dosage(value: 100, unit: .micrograms),
            route: .inhaled,
            frequency: 2,
            duration: 200,
            datePrescribed: .now.addingTimeInterval(-86400 * 100)  // 100 days ago
        )

        try patient.prescribe(medication: medication1)
        try patient.prescribe(medication: medication2)
        try patient.prescribe(medication: medication3)

        let currentMeds = patient.currentMedications
        #expect(currentMeds.count == 2)
        #expect(currentMeds.contains(medication1))
        #expect(!currentMeds.contains(medication2))
        #expect(currentMeds.contains(medication3))
        #expect(currentMeds[0] == medication3)  // Older prescription first
        #expect(currentMeds[1] == medication1)  // Newer prescription second
    }

    @Test func testBloodTypeCompatibility() async throws {
        // Test all blood type compatibility rules
        for recipientType in BloodType.allCases {
            let recipient = try Patient(
                firstName: "Test", lastName: "Patient",
                dateOfBirth: Date(timeIntervalSince1970: 631_152_000),
                height: 1800, weight: 70000, bloodType: recipientType
            )

            for donorType in BloodType.allCases {
                let donor = try Patient(
                    firstName: "Test", lastName: "Donor",
                    dateOfBirth: Date(timeIntervalSince1970: 631_152_000),
                    height: 1800, weight: 70000, bloodType: donorType
                )

                #expect(
                    try recipient.canReceiveBlood(from: donor)
                        == recipient.compatibleBloodTypes.contains(donorType))
            }
        }
    }

    @Test func testPatientEquality() async throws {
        let patient1 = try Patient(
            firstName: "John",
            lastName: "Doe",
            dateOfBirth: Date(timeIntervalSince1970: 948_186_691),
            height: 1800,
            weight: 70000
        )

        let patient2 = try Patient(
            firstName: "John",  // Same name but different MRN
            lastName: "Doe",
            dateOfBirth: Date(timeIntervalSince1970: 948_186_691),
            height: 1800,
            weight: 70000
        )

        #expect(patient1 != patient2)  // Different MRN
    }

    @Test func testBloodTransfusionErrors() async throws {
        let recipient = try Patient(
            firstName: "John",
            lastName: "Doe",
            dateOfBirth: Date(timeIntervalSince1970: 948_186_691),
            height: 1800,
            weight: 70000,
            bloodType: .abPositive
        )

        let donorWithoutBloodType = try Patient(
            firstName: "Jane",
            lastName: "Smith",
            dateOfBirth: Date(timeIntervalSince1970: 948_186_691),
            height: 1800,
            weight: 70000  // No blood type specified
        )

        #expect(throws: PatientError.invalidBloodTypeForTransfusion) {
            _ = try recipient.canReceiveBlood(from: donorWithoutBloodType)
        }

        // Test recipient without blood type
        let recipientWithoutBloodType = try Patient(
            firstName: "Bob",
            lastName: "Smith",
            dateOfBirth: Date(timeIntervalSince1970: 948_186_691),
            height: 1800,
            weight: 70000  // No blood type specified
        )

        let donor = try Patient(
            firstName: "Alice",
            lastName: "Jones",
            dateOfBirth: Date(timeIntervalSince1970: 948_186_691),
            height: 1800,
            weight: 70000,
            bloodType: .oNegative
        )

        #expect(recipientWithoutBloodType.compatibleBloodTypes.isEmpty)
        #expect(throws: PatientError.invalidBloodTypeForTransfusion) {
            _ = try recipientWithoutBloodType.canReceiveBlood(from: donor)
        }
    }

    @Test func testDosageDescription() async throws {
        let dosage1 = Dosage(value: 81, unit: .milligrams)
        #expect(dosage1.description == "81mg")

        let dosage2 = Dosage(value: 1, unit: .grams)
        #expect(dosage2.description == "1g")

        let dosage3 = Dosage(value: 100, unit: .micrograms)
        #expect(dosage3.description == "100mcg")
    }

    @Test func testMedicationEndDateAndDaysRemaining() async throws {
        let pastDate = Date.now.addingTimeInterval(-86400 * 10)  // 10 days ago
        let expiredMed = Medication(
            name: "Expired Med",
            dosage: Dosage(value: 25, unit: .milligrams),
            route: .oral,
            frequency: 1,
            duration: 5,  // 5 days duration, started 10 days ago
            datePrescribed: pastDate
        )

        #expect(!expiredMed.isActive)
        #expect(expiredMed.daysRemaining == 0)

        let futureMed = Medication(
            name: "Future Med",
            dosage: Dosage(value: 25, unit: .milligrams),
            route: .oral,
            frequency: 1,
            duration: 30,
            datePrescribed: .now
        )

        #expect(futureMed.isActive)
        #expect(futureMed.daysRemaining >= 29)  // Account for time passing during test
    }

    @Test func testMedicationFrequencyDescription() async throws {
        let med1 = Medication(
            name: "Once Daily",
            dosage: Dosage(value: 25, unit: .milligrams),
            route: .oral,
            frequency: 1,
            duration: 30,
            datePrescribed: .now
        )
        #expect(med1.dosageDescription == "once daily")

        let med2 = Medication(
            name: "Twice Daily",
            dosage: Dosage(value: 25, unit: .milligrams),
            route: .oral,
            frequency: 2,
            duration: 30,
            datePrescribed: .now
        )
        #expect(med2.dosageDescription == "twice daily")

        let med3 = Medication(
            name: "Three Times Daily",
            dosage: Dosage(value: 25, unit: .milligrams),
            route: .oral,
            frequency: 3,
            duration: 30,
            datePrescribed: .now
        )
        #expect(med3.dosageDescription == "3 times daily")
    }
}
