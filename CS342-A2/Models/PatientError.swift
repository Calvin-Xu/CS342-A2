/// Errors that can occur when working with patient data.
enum PatientError: Error, Equatable {
    /// Thrown when attempting to create a patient with a birth date in the future.
    case futureDateOfBirth
    /// Thrown when attempting to check blood type compatibility with an unknown donor blood type.
    case invalidBloodTypeForTransfusion
}
