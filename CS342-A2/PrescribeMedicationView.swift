import SwiftUI

struct PrescribeMedicationView: View {
    @ObservedObject var patient: Patient

    @Environment(\.dismiss) private var dismiss

    // Form fields
    @State private var medicationName = ""
    @State private var doseValue = ""
    @State private var selectedDoseUnit: Dosage.DosageUnit = .milligrams
    @State private var route: MedicationRoute = .oral
    @State private var frequency = 1
    @State private var duration = 15.0

    // Alert State
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Medication Details") {
                    TextField("Name", text: $medicationName)
                        .textInputAutocapitalization(.words)

                    HStack {
                        TextField("Dose", text: $doseValue)
                            .keyboardType(.numberPad)
                        Picker("Unit", selection: $selectedDoseUnit) {
                            ForEach(
                                [
                                    Dosage.DosageUnit.milligrams,
                                    Dosage.DosageUnit.grams,
                                    Dosage.DosageUnit.micrograms,
                                ], id: \.self
                            ) {
                                Text($0.rawValue)
                            }
                        }
                    }
                    .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                    // https://stackoverflow.com/questions/74845212/how-do-we-control-the-automatic-dividers-in-swiftui-forms
                    

                    Picker("Route", selection: $route) {
                        ForEach(MedicationRoute.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }

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
                        Stepper("Times per day: \(frequency)", value: $frequency, in: 1...100)
                            .labelsHidden()
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
                            Stepper("Duration: \(frequency)", value: $duration, in: 1...100)
                                .labelsHidden()
                        }
                        Slider(value: $duration, in: 1...30, step: 1)
                    }
                }
            }
            .navigationTitle("Prescribe Medication")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveMedication()
                    }
                    .disabled(medicationName.isEmpty || doseValue.isEmpty)
                }
            }
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

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
