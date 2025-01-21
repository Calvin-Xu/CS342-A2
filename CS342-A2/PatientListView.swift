import SwiftUI

/// A view that displays a list of patients with search and filtering capabilities.
///
/// This view provides:
/// - A searchable list of all patients
/// - Optional filtering by blood type
/// - Navigation to patient details
/// - Ability to add new patients
/// - Swipe-to-delete functionality
///
/// The list shows each patient's:
/// - Full name and age
/// - Medical record number (MRN)
struct PatientListView: View {
    /// The store containing all patients.
    @Environment(PatientStore.self) private var store

    /// The current search text entered by the user.
    @State private var searchText = ""

    /// Whether to show the add patient sheet.
    @State private var showingAddPatient = false

    /// Optional blood type to filter the patient list.
    ///
    /// When set, only patients with this blood type will be shown.
    /// When nil, all patients are shown.
    var bloodTypeFilter: BloodType? = nil

    /// The filtered list of patients based on search text and blood type filter.
    ///
    /// This computed property:
    /// 1. Applies the blood type filter if one is set
    /// 2. Applies the search text filter if any is entered
    /// 3. Returns the filtered array of patients
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

    /// The title to display in the navigation bar.
    ///
    /// Returns either:
    /// - "Blood Type X" when filtering by blood type
    /// - "Patients" when showing all patients
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
                        .accessibilityIdentifier("patient.name.\(patient.medicalRecordNumber)")

                    Text("MRN: \(patient.medicalRecordNumber.uuidString)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("patient.mrn.\(patient.medicalRecordNumber)")
                }
                .padding(.vertical, 4)
                .accessibilityIdentifier("patient.cell.\(patient.medicalRecordNumber)")
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        store.remove(patient)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .accessibilityIdentifier("patient.delete.\(patient.medicalRecordNumber)")
                }
            }
        }
        .accessibilityIdentifier("patient.list")
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
                .accessibilityIdentifier("add.patient.button")
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
