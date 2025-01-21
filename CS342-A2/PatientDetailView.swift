import SwiftUI

struct PatientDetailView: View {
    @ObservedObject var patient: Patient
    @State private var showingPrescribeSheet = false

    var body: some View {
        List {
            // Basic Information Section
            Section(
                content: {
                    LabeledContent("Name", value: "\(patient.firstName) \(patient.lastName)")
                        .textSelection(.enabled)
                        .accessibilityIdentifier("patient.detail.name")

                    LabeledContent("Date of Birth", value: patient.dateOfBirthString)
                        .textSelection(.enabled)
                        .accessibilityIdentifier("patient.detail.dob")

                    LabeledContent(
                        "Height",
                        value: String(format: "%.1f cm", Double(patient.height_mm) / 10)
                    )
                    .textSelection(.enabled)
                    .accessibilityIdentifier("patient.detail.height")

                    LabeledContent(
                        "Weight",
                        value: String(format: "%.2f kg", Double(patient.weight_g) / 1000)
                    )
                    .textSelection(.enabled)
                    .accessibilityIdentifier("patient.detail.weight")
                },
                header: {
                    Text("Patient Information")
                        .accessibilityIdentifier("patient.detail.section.info")
                })

            // Blood Type Section
            Section("Blood Type") {
                if let bloodType = patient.bloodType {
                    LabeledContent("Type", value: bloodType.rawValue)
                        .textSelection(.enabled)

                    if !patient.compatibleBloodTypes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Can receive from")

                            ScrollView(.horizontal, showsIndicators: true) {
                                LazyHGrid(rows: [GridItem(.flexible())], spacing: 4) {
                                    ForEach(patient.compatibleBloodTypes, id: \.self) { type in
                                        NavigationLink(value: type) {
                                            Text(type.rawValue)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 4)
                                                .foregroundStyle(.blue)
                                                .background(Color.secondary.opacity(0.2))
                                                .cornerRadius(8)
                                        }
                                        .buttonStyle(.plain)
                                        .accessibilityIdentifier("blood.type.\(type.rawValue)")
                                        .accessibilityLabel("Filter by blood type \(type.rawValue)")
                                    }
                                }
                            }
                        }
                    }
                } else {
                    Text("Not specified")
                        .foregroundStyle(.secondary)
                }
            }

            // Medications Section
            Section(
                content: {
                    if patient.currentMedications.isEmpty {
                        ContentUnavailableView(
                            "No Active Medications",
                            systemImage: "pills",
                            description: Text("Prescribe medications using the button below")
                        )
                    } else {
                        ForEach(patient.currentMedications, id: \.id) { medication in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(medication.name)
                                    .font(.headline)

                                Text(
                                    "\(medication.dosage.description) \(medication.route.rawValue) \(medication.dosageDescription) for \(medication.duration) days"
                                )
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                                Text("\(medication.daysRemaining) days remaining")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    patient.removeMedication(medication)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                },
                header: {
                    HStack {
                        Text("Current Medications")
                        Spacer()
                        Button {
                            showingPrescribeSheet = true
                        } label: {
                            Label("Prescribe", systemImage: "plus")
                                .labelStyle(.iconOnly)
                                .accessibilityIdentifier("patient.detail.prescribe")
                        }
                    }
                })

            LabeledContent("Medical Record Number") {
                Text(patient.medicalRecordNumber.uuidString)
                    .textSelection(.enabled)
            }
        }
        .navigationTitle(patient.fullNameAndAge)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: BloodType.self) { bloodType in
            PatientListView(bloodTypeFilter: bloodType)
        }
        .sheet(isPresented: $showingPrescribeSheet) {
            PrescribeMedicationView(patient: patient)
        }
    }
}

#Preview {
    NavigationStack {
        PatientDetailView(patient: Patient.samples[0])
    }
}
