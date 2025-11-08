import SwiftUI

struct NutrientRow: View {
    let label: String
    let value: Double?
    let unit: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value != nil ? String(format: "%.1f %@", value!, unit) : "-")
                .foregroundColor(.secondary)
        }
        .font(.subheadline)
    }
}
