/// A type representing a medication dosage with a value and unit.
struct Dosage {
    /// Units of measurement for medication dosages.
    enum DosageUnit: String, Codable {
        /// Grams (g)
        case grams = "g"
        /// Milligrams (mg)
        case milligrams = "mg"
        /// Micrograms (mcg)
        case micrograms = "mcg"
    }

    /// The numeric value of the dosage.
    let value: Int

    /// The unit of measurement for the dosage.
    let unit: DosageUnit

    /// A string representation of the dosage (e.g., "25mg").
    var description: String {
        "\(value)\(unit.rawValue)"
    }
}

// Extensions
extension Dosage: Codable, Equatable, Hashable {}
