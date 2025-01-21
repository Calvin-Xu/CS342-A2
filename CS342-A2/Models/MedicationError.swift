/// Errors that can occur when working with medications.
enum MedicationError: Error, CustomStringConvertible, Equatable {
    /// Thrown when attempting to prescribe a medication that the patient is already taking.
    case duplicateMedication(String)

    /// A human-readable description of the error.
    var description: String {
        switch self {
        case .duplicateMedication(let name):
            return "Medication \(name) already prescribed and active"
        }
    }
}
