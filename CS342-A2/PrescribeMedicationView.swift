import SwiftUI

/// A view that allows prescribing medications to a patient.
///
/// This view presents a form where medical professionals can:
/// - Enter medication name and dosage
/// - Select route of administration
/// - Set frequency and duration of the prescription
/// - Save the prescription to the patient's record
///
/// The view validates input and prevents duplicate prescriptions for active medications.
struct PrescribeMedicationView: View {
    /// The patient receiving the prescription.
    var patient: Patient

    @Environment(\.dismiss) private var dismiss

    // MARK: - Form Fields

    /// The name of the medication being prescribed.
    @State private var medicationName = ""

    /// The numerical value of the medication dose.
    @State private var doseValue = ""

    /// The unit of measurement for the medication dose.
    @State private var selectedDoseUnit: Dosage.DosageUnit = .milligrams

    /// The route of administration for the medication.
    @State private var route: MedicationRoute = .oral

    /// The number of times per day the medication should be taken.
    @State private var frequency = 1

    /// The duration in days for which the medication should be taken.
    @State private var duration = 15.0

    // MARK: - Alert State

    /// Whether to show the error alert.
    @State private var showErrorAlert = false

    /// The error message to display in the alert.
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Medication Details") {
                    TextField("Name", text: $medicationName)
                        .textInputAutocapitalization(.words)
                        .accessibilityIdentifier("medication.name")

                    HStack {
                        TextField("Dose", text: $doseValue)
                            .keyboardType(.numberPad)
                            .accessibilityIdentifier("medication.dose")
                        Picker("Unit", selection: $selectedDoseUnit) {
                            ForEach(
                                [
                                    Dosage.DosageUnit.milligrams,
                                    Dosage.DosageUnit.grams,
                                    Dosage.DosageUnit.micrograms,
                                ], id: \.self
                            ) {
                                Text($0.rawValue)
                                    .accessibilityIdentifier("medication.unit.\($0.rawValue)")
                            }
                        }
                        .accessibilityIdentifier("medication.unit")
                    }
                    .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                    // https://stackoverflow.com/questions/74845212/how-do-we-control-the-automatic-dividers-in-swiftui-forms

                    Picker("Route", selection: $route) {
                        ForEach(MedicationRoute.allCases, id: \.self) {
                            Text($0.rawValue)
                                .accessibilityIdentifier("medication.route.\($0.rawValue)")
                        }
                    }
                    .accessibilityIdentifier("medication.route")

                    HStack {
                        Text("Times per day: ")
                            .fixedSize()
                        Spacer()
                        TextField(
                            "Times per day: ", value: $frequency, formatter: NumberFormatter()
                        )
                        .padding(.vertical, 4)
                        .keyboardType(.numberPad)
                        .foregroundStyle(.blue)
                        .backgroundStyle(.primary)
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(5)
                        .frame(width: 60)
                        .multilineTextAlignment(.center)
                        .padding(.trailing, 10)
                        .accessibilityIdentifier("medication.frequency")
                        Stepper("Times per day: \(frequency)", value: $frequency, in: 1...100)
                            .labelsHidden()
                            .accessibilityIdentifier("medication.frequency.stepper")
                    }

                    VStack(alignment: .leading) {
                        HStack {
                            Text("Duration (days): ")
                                .fixedSize()
                            Spacer()
                            TextField(
                                "Duration (days)", value: $duration, formatter: NumberFormatter()
                            )
                            .padding(.vertical, 4)
                            .keyboardType(.numberPad)
                            .foregroundStyle(.blue)
                            .backgroundStyle(.primary)
                            .background(Color.secondary.opacity(0.2))
                            .cornerRadius(5)
                            .frame(width: 60)
                            .multilineTextAlignment(.center)
                            .padding(.trailing, 10)
                            .accessibilityIdentifier("medication.duration")
                            Stepper("Duration: \(frequency)", value: $duration, in: 1...100)
                                .labelsHidden()
                                .accessibilityIdentifier("medication.duration.stepper")
                        }
                        Slider(value: $duration, in: 1...30, step: 1)
                            .accessibilityIdentifier("medication.duration.slider")
                    }
                }
            }
            .navigationTitle("Prescribe Medication")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .accessibilityIdentifier("medication.cancel")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveMedication()
                    }
                    .disabled(medicationName.isEmpty || doseValue.isEmpty)
                    .accessibilityIdentifier("medication.save")
                }
            }
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    /// Attempts to save the medication prescription to the patient's record.
    ///
    /// This function performs the following validations:
    /// - Checks for duplicate active medications
    /// - Validates the dose value is a valid integer
    ///
    /// - Throws: `MedicationError.duplicateMedication` if the patient is already taking this medication
    private func saveMedication() {
        // Duplicate check
        if patient.currentMedications.contains(where: {
            $0.name.lowercased() == medicationName.lowercased() && $0.isActive
        }) {
            errorMessage = "This medication is already prescribed."
            showErrorAlert = true
            return
        }

        // Validate dose
        guard let doseAsInt = Int(doseValue) else {
            errorMessage = "Please enter a valid dose (e.g. 25)."
            showErrorAlert = true
            return
        }

        // Create medication and prescribe
        let newMedication = Medication(
            name: medicationName,
            dosage: Dosage(value: doseAsInt, unit: selectedDoseUnit),
            route: route,
            frequency: frequency,
            duration: Int(duration),
            datePrescribed: Date()
        )

        do {
            try patient.prescribe(medication: newMedication)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }
}

#Preview {
    PrescribeMedicationView(patient: Patient.samples[0])
}
