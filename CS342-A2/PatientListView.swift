import SwiftUI

struct PatientListView: View {
    @Environment(PatientStore.self) private var store
    @State private var searchText = ""
    @State private var showingAddPatient = false

    private var filteredPatients: [Patient] {
        searchText.isEmpty
            ? Array(store.patients)
            : Array(store.patients).filter {
                $0.fullNameAndAge.lowercased().contains(searchText.lowercased())
            }
    }

    var body: some View {
        List(filteredPatients, id: \.medicalRecordNumber) { patient in
            VStack(alignment: .leading, spacing: 4) {
                Text(patient.fullNameAndAge)
                    .font(.headline)

                Text("MRN: \(patient.medicalRecordNumber.uuidString)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
        .navigationTitle("Patients")
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
            .environment(PatientStore.sample)
    }
}
