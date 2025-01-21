import SwiftUI

struct PatientListView: View {
    @Environment(PatientStore.self) private var store
    @State private var searchText = ""
    @State private var showingAddPatient = false
    var bloodTypeFilter: BloodType? = nil

    private var filteredPatients: [Patient] {
        let patients =
            bloodTypeFilter != nil
            ? store.patients.filter { $0.bloodType == bloodTypeFilter }
            : store.patients

        return searchText.isEmpty
            ? Array(patients)
            : Array(patients).filter {
                $0.fullNameAndAge.lowercased().contains(searchText.lowercased())
            }
    }

    var title: String {
        if let bloodType = bloodTypeFilter {
            return "Blood Type \(bloodType.rawValue)"
        }
        return "Patients"
    }

    var body: some View {
        List(filteredPatients, id: \.medicalRecordNumber) { patient in
            NavigationLink(value: patient) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(patient.fullNameAndAge)
                        .font(.headline)

                    Text("MRN: \(patient.medicalRecordNumber.uuidString)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        store.remove(patient)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .navigationTitle(title)
        .navigationDestination(for: Patient.self) { patient in
            PatientDetailView(patient: patient)
        }
        .searchable(text: $searchText, prompt: "Search patients")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddPatient = true
                } label: {
                    Label("Add Patient", systemImage: "person.badge.plus")
                }
            }
        }
        .sheet(isPresented: $showingAddPatient) {
            PatientAddView(store: store)
        }
    }
}

#Preview {
    NavigationStack {
        PatientListView()
            .environment(PatientStore(patients: Patient.samples))
    }
}
