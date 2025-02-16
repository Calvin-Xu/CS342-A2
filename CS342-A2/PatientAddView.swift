import SwiftUI

/// A view for adding new patients to the system.
///
/// This view presents a form where medical professionals can:
/// - Enter patient's personal information (name, date of birth)
/// - Input physical measurements (height, weight)
/// - Optionally specify blood type
///
/// The view includes validation for:
/// - Required fields (name, height, weight)
/// - Valid height range (0-300 cm)
/// - Valid weight range (0-700 kg)
/// - Future dates not allowed for date of birth
struct PatientAddView: View {
    @Environment(\.dismiss) private var dismiss
    let store: PatientStore  // Pass the store directly since we're just adding to it

    /// Maximum allowed height in centimeters.
    /// Source: https://en.wikipedia.org/wiki/List_of_tallest_people
    let MAX_HEIGHT = 300

    /// Maximum allowed weight in kilograms.
    /// Source: https://en.wikipedia.org/wiki/List_of_heaviest_people
    let MAX_WEIGHT = 700

    /// Required fields
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var dateOfBirth = Date.now
    @State private var height_cm = ""  // in cm, will convert to mm
    @State private var weight_kg = ""  // in kg, will convert to g

    /// Optional field
    @State private var bloodType: BloodType?

    /// Validation state
    @State private var showingError = false
    @State private var errorMessage = ""

    /// Computed validation properties
    private var isHeightValid: Bool {
        guard let heightValue = Double(height_cm) else { return false }
        return heightValue > 0 && Int(heightValue) < MAX_HEIGHT
    }

    private var isWeightValid: Bool {
        guard let weightValue = Double(weight_kg) else { return false }
        return weightValue > 0 && Int(weightValue) < MAX_WEIGHT
    }

    private var isFormValid: Bool {
        !firstName.isEmpty && !lastName.isEmpty && dateOfBirth <= .now && isHeightValid
            && isWeightValid
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("First Name", text: $firstName)
                        .textContentType(.givenName)
                        .accessibilityIdentifier("patient.add.firstName")

                    TextField("Last Name", text: $lastName)
                        .textContentType(.familyName)
                        .accessibilityIdentifier("patient.add.lastName")

                    TextField("Height (cm)", text: $height_cm)
                        .keyboardType(.decimalPad)
                        .accessibilityIdentifier("patient.add.height")
                    if !height_cm.isEmpty && !isHeightValid {
                        Text("Height must be between 0 and 300 cm")
                            .foregroundStyle(.red)
                            .font(.caption)
                            .accessibilityIdentifier("patient.add.height.error")
                    }

                    TextField("Weight (kg)", text: $weight_kg)
                        .keyboardType(.decimalPad)
                        .accessibilityIdentifier("patient.add.weight")
                    if !weight_kg.isEmpty && !isWeightValid {
                        Text("Weight must be between 0 and 700 kg")
                            .foregroundStyle(.red)
                            .font(.caption)
                            .accessibilityIdentifier("patient.add.weight.error")
                    }
                }

                Section("Date of Birth") {
                    DatePicker(
                        "Date of Birth",
                        selection: $dateOfBirth,
                        in: ...Date.now,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.wheel)
                    .accessibilityIdentifier("patient.add.dateOfBirth")
                }

                Section("Optional") {
                    Picker("Blood Type", selection: $bloodType) {
                        Text("Unknown").tag(nil as BloodType?)
                            .accessibilityIdentifier("patient.add.bloodType.unknown")
                        ForEach(BloodType.allCases, id: \.self) { bloodType in
                            Text(bloodType.rawValue)
                                .tag(bloodType as BloodType?)
                                .accessibilityIdentifier(
                                    "patient.add.bloodType.\(bloodType.rawValue)")
                        }
                    }
                    .pickerStyle(.menu)
                    .accessibilityIdentifier("patient.add.bloodType")
                }
            }
            .navigationTitle("Add Patient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .accessibilityIdentifier("patient.add.cancel")
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePatient()
                    }
                    .disabled(!isFormValid)
                    .accessibilityIdentifier("patient.add.save")
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    /// Attempts to save the new patient to the store.
    ///
    /// This function:
    /// 1. Validates all required fields
    /// 2. Converts height from cm to mm
    /// 3. Converts weight from kg to g
    /// 4. Creates and adds the new patient to the store
    ///
    /// - Throws: `PatientError.futureDateOfBirth` if the date of birth is in the future
    private func savePatient() {
        guard isFormValid,
            let heightValue = Double(height_cm),
            let weightValue = Double(weight_kg)
        else { return }

        do {
            let patient = try Patient(
                firstName: firstName.trimmingCharacters(in: .whitespaces),
                lastName: lastName.trimmingCharacters(in: .whitespaces),
                dateOfBirth: dateOfBirth,
                height: Int(heightValue * 10),  // cm to mm
                weight: Int(weightValue * 1000),  // kg to g
                bloodType: bloodType
            )
            store.add(patient)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}

#Preview {
    PatientAddView(store: PatientStore.sample)
}
