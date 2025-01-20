import SwiftUI

@Observable class PatientStore {
    /// The list of all patients in the system
    private(set) var patients: Set<Patient>

    /// Initialize patient store with a list of patients
    init(patients: [Patient] = []) {
        self.patients = Set(patients)
    }

    /// Add a new patient to the store
    /// - Parameter patient: The patient to add
    func add(_ patient: Patient) {
        patients.insert(patient)
    }

    /// Remove a patient from the store
    /// - Parameter patient: The patient to remove
    func remove(_ patient: Patient) {
        patients.remove(patient)
    }
}

// MARK: - Preview Helpers
extension PatientStore {
    /// A sample store for previews and testing
    static var sample: PatientStore {
        PatientStore(patients: Patient.samples)
    }
}
