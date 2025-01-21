import XCTest

@testable import CS342_A2

final class PatientListViewTests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UIInterfaceOrientation", "Portrait"]
        app.launch()
    }

    func testPatientListBasicElements() throws {
        // Check navigation title
        XCTAssertTrue(app.navigationBars["Patients"].exists)

        // Check search field exists
        XCTAssertTrue(app.searchFields["Search patients"].exists)

        // Check add patient button exists
        XCTAssertTrue(app.buttons["Add Patient"].exists)
    }

    func testPatientSearch() throws {
        XCTAssertTrue(app.staticTexts["Doe, John (37)"].exists)
        XCTAssertTrue(app.staticTexts["Smith, Jane (31)"].exists)
        XCTAssertTrue(app.staticTexts["Anderson, Robert (25)"].exists)

        let searchField = app.searchFields["Search patients"]
        searchField.tap()
        searchField.typeText("John")

        // Should show John Doe and hide other patients
        XCTAssertTrue(app.staticTexts["Doe, John (37)"].exists)
        XCTAssertFalse(app.staticTexts["Smith, Jane (31)"].exists)
        XCTAssertFalse(app.staticTexts["Anderson, Robert (25)"].exists)

        // Clear search
        searchField.tap()
        searchField.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 4))

        // Should show all patients again
        XCTAssertTrue(app.staticTexts["Doe, John (37)"].exists)
        XCTAssertTrue(app.staticTexts["Smith, Jane (31)"].exists)
        XCTAssertTrue(app.staticTexts["Anderson, Robert (25)"].exists)
    }

    func testPatientNavigation() throws {
        // Tap on a patient
        app.staticTexts["Doe, John (37)"].tap()

        // Should navigate to detail view
        XCTAssertTrue(app.navigationBars["Doe, John (37)"].exists)

        // Check if basic information is displayed
        XCTAssertTrue(
            app.staticTexts["patient.detail.section.info"].exists,
            "Patient Information section header should exist")
        XCTAssertTrue(
            app.staticTexts["patient.detail.name"].exists, "Patient name should be visible")
        XCTAssertTrue(
            app.staticTexts["patient.detail.dob"].exists, "Date of birth should be visible")
        XCTAssertTrue(app.staticTexts["patient.detail.height"].exists, "Height should be visible")
        XCTAssertTrue(app.staticTexts["patient.detail.weight"].exists, "Weight should be visible")

        // Go back
        app.navigationBars.buttons.element(boundBy: 0).tap()

        // Should be back at patient list
        XCTAssertTrue(app.navigationBars["Patients"].exists)
    }

    func testBloodTypeFiltering() throws {
        // Navigate to a patient with blood type
        app.staticTexts["Doe, John (37)"].tap()

        // Tap on a compatible blood type
        let bloodTypeButton = app.buttons["blood.type.O+"]
        XCTAssertTrue(bloodTypeButton.exists, "Blood type button should exist")
        bloodTypeButton.tap()

        // Should show filtered list
        XCTAssertTrue(app.navigationBars["Blood Type O+"].exists)

        // Should display Anderson, Robert (25)
        XCTAssertTrue(app.staticTexts["Anderson, Robert (25)"].exists)

        // Go back
        app.navigationBars.buttons.element(boundBy: 0).tap()

        // Should be back at patient detail
        XCTAssertTrue(app.navigationBars["Doe, John (37)"].exists)
    }

    func testDeletePatient() throws {
        // Get initial patient count
        let initialCount = app.cells.count

        // Swipe to delete first patient
        let firstPatient = app.cells.element(boundBy: 0)
        firstPatient.swipeLeft()
        app.buttons["Delete"].tap()

        // Verify patient count decreased
        XCTAssertEqual(app.cells.count, initialCount - 1)
    }

    func testAddPatient() throws {
        // Tap the add patient button
        app.buttons["add.patient.button"].tap()

        // Fill in the form
        app.textFields["patient.add.firstName"].tap()
        app.textFields["patient.add.firstName"].typeText("Steve")

        app.textFields["patient.add.lastName"].tap()
        app.textFields["patient.add.lastName"].typeText("Brown")

        // Set date of birth to Jan 10, 2000
        let datePicker = app.datePickers["patient.add.dateOfBirth"]
        datePicker.tap()
        datePicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "January")
        datePicker.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "10")
        datePicker.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: "2000")

        app.textFields["patient.add.height"].tap()
        app.textFields["patient.add.height"].typeText("170")

        app.textFields["patient.add.weight"].tap()
        app.textFields["patient.add.weight"].typeText("65")

        // Select blood type using menu
        // not working
        // let bloodTypePicker = app.pickers["patient.add.bloodType"]
        // bloodTypePicker.tap()
        // bloodTypePicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "O+")

        // Save the patient
        app.buttons["patient.add.save"].tap()

        let expectation = XCTestExpectation(description: "Wait for patient list to update")
        XCTWaiter().wait(for: [expectation], timeout: 1.0)

        // Verify the new patient appears in the list with correct age
        XCTAssertTrue(app.staticTexts["Brown, Steve (25)"].exists)
    }

    func testAddPatientValidation() throws {
        // Tap the add patient button
        app.buttons["add.patient.button"].tap()

        // Try invalid height
        app.textFields["patient.add.height"].tap()
        app.textFields["patient.add.height"].typeText("400")
        XCTAssertTrue(app.staticTexts["patient.add.height.error"].exists)

        // Try invalid weight
        app.textFields["patient.add.weight"].tap()
        app.textFields["patient.add.weight"].typeText("800")
        XCTAssertTrue(app.staticTexts["patient.add.weight.error"].exists)

        // Verify save button is disabled
        XCTAssertFalse(app.buttons["patient.add.save"].isEnabled)

        // Cancel and verify we're back at the list
        app.buttons["patient.add.cancel"].tap()
        XCTAssertTrue(app.navigationBars["Patients"].exists)
    }

    func testPrescribeMedication() throws {
        // Navigate to a patient
        app.staticTexts["Doe, John (37)"].tap()

        // Open prescribe medication sheet
        app.buttons["patient.detail.prescribe"].tap()

        // Fill in medication details
        app.textFields["medication.name"].tap()
        app.textFields["medication.name"].typeText("Ibuprofen")

        app.textFields["medication.dose"].tap()
        app.textFields["medication.dose"].typeText("400")

        //        // Select unit (mg)
        //        app.buttons["Unit"].tap()
        //        app.buttons["milligrams"].tap()
        //
        //        // Select route
        //        app.buttons["Route"].tap()
        //        app.buttons["oral"].tap()

        // Set frequency (3 times per day)
        app.textFields["medication.frequency"].tap()
        app.textFields["medication.frequency"].typeText("3")

        // Set duration (7 days)
        app.textFields["medication.duration"].tap()
        app.textFields["medication.duration"].typeText("7")

        // Save medication
        app.buttons["medication.save"].tap()

        // Verify medication appears in the list
        XCTAssertTrue(app.staticTexts["Ibuprofen"].exists)
        XCTAssertTrue(app.staticTexts["400mg by mouth 31 times daily for 715 days"].exists)
    }

    func testPrescribeMedicationValidation() throws {
        // Navigate to a patient
        app.staticTexts["Doe, John (37)"].tap()

        // Open prescribe medication sheet
        app.buttons["patient.detail.prescribe"].tap()

        // Verify save button is disabled initially
        XCTAssertFalse(app.buttons["medication.save"].isEnabled)

        // Fill in only name
        app.textFields["medication.name"].tap()
        app.textFields["medication.name"].typeText("Test Med")

        // Save should still be disabled without dose
        XCTAssertFalse(app.buttons["medication.save"].isEnabled)

        // Fill in only dose
        app.textFields["medication.name"].tap()
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: 8)
        app.textFields["medication.name"].typeText(deleteString)

        app.textFields["medication.dose"].tap()
        app.textFields["medication.dose"].typeText("100")

        // Save should still be disabled without name
        XCTAssertFalse(app.buttons["medication.save"].isEnabled)

        // Cancel and verify we're back at patient detail
        app.buttons["medication.cancel"].tap()
        XCTAssertTrue(app.navigationBars["Doe, John (37)"].exists)
    }

    func testPrescribeDuplicateMedication() throws {
        // Navigate to a patient
        app.staticTexts["Doe, John (37)"].tap()

        // Prescribe first medication
        app.buttons["patient.detail.prescribe"].tap()
        app.textFields["medication.name"].tap()
        app.textFields["medication.name"].typeText("Aspirin")
        app.textFields["medication.dose"].tap()
        app.textFields["medication.dose"].typeText("100")
        app.buttons["medication.save"].tap()

        // Try to prescribe the same medication again
        app.buttons["patient.detail.prescribe"].tap()
        app.textFields["medication.name"].tap()
        app.textFields["medication.name"].typeText("Aspirin")
        app.textFields["medication.dose"].tap()
        app.textFields["medication.dose"].typeText("100")
        app.buttons["medication.save"].tap()

        // Verify error alert appears
        XCTAssertTrue(app.alerts["Error"].exists)
        XCTAssertTrue(app.staticTexts["This medication is already prescribed."].exists)

        // Dismiss alert and cancel
        app.buttons["OK"].tap()
        app.buttons["medication.cancel"].tap()
    }
}
