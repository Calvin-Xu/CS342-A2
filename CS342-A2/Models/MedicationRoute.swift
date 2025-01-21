enum MedicationRoute: String, Codable, CaseIterable {
    case oral = "by mouth"
    case subcutaneous = "subcutaneously"
    case intramuscular = "intramuscularly"
    case intravenous = "intravenously"
    case inhaled = "inhaled"
    case topical = "topically"
}
