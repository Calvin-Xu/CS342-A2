import SwiftUI

struct PatientAddView: View {
    @Environment(\.dismiss) private var dismiss
    let store: PatientStore  // Pass the store directly since we're just adding to it

    let MAX_HEIGHT = 300  // https://en.wikipedia.org/wiki/List_of_tallest_people
    let MAX_WEIGHT = 700  // https://en.wikipedia.org/wiki/List_of_heaviest_people

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

                    TextField("Last Name", text: $lastName)
                        .textContentType(.familyName)

                    DatePicker(
                        "Date of Birth",
                        selection: $dateOfBirth,
                        in: ...Date.now,
                        displayedComponents: .date
                    )

                    TextField("Height (cm)", text: $height_cm)
                        .keyboardType(.decimalPad)
                    if !height_cm.isEmpty && !isHeightValid {
                        Text("Height must be between 0 and 300 cm")
                            .foregroundStyle(.red)
                            .font(.caption)
                    }

                    TextField("Weight (kg)", text: $weight_kg)
                        .keyboardType(.decimalPad)
                    if !weight_kg.isEmpty && !isWeightValid {
                        Text("Weight must be between 0 and 700 kg")
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }

                Section("Optional") {
                    Picker("Blood Type", selection: $bloodType) {
                        Text("Unknown").tag(nil as BloodType?)
                        ForEach(BloodType.allCases, id: \.self) { bloodType in
                            Text(bloodType.rawValue).tag(bloodType as BloodType?)
                        }
                    }
                }
            }
            .navigationTitle("Add Patient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePatient()
                    }
                    .disabled(!isFormValid)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
        }
    }

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
