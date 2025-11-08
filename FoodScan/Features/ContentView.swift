import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var scannedCode: String?
    @State private var product: Product?
    @State private var isScanning = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let product = product {
                    VStack {
                        AsyncImage(url: URL(string: product.imageURL ?? "")) { image in
                            image.resizable().scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(height: 200)

                        Text(product.name ?? "Produs necunoscut")
                            .font(.title3)
                            .bold()
                            .padding(.top, 8)
                        
                        if let nutriments = product.nutriments {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Valori per 100g:")
                                    .font(.headline)
                                    .padding(.top, 10)

                                NutrientRow(label: "Energie", value: nutriments.energyKcal100g, unit: "kcal")
                                NutrientRow(label: "Grăsimi", value: nutriments.fat100g, unit: "g")
                                NutrientRow(label: "Grăsimi saturate", value: nutriments.saturatedFat100g, unit: "g")
                                NutrientRow(label: "Carbohidrați", value: nutriments.carbohydrates100g, unit: "g")
                                NutrientRow(label: "Zahăr", value: nutriments.sugars100g, unit: "g")
                                NutrientRow(label: "Fibre", value: nutriments.fiber100g, unit: "g")
                                NutrientRow(label: "Proteine", value: nutriments.proteins100g, unit: "g")
                                NutrientRow(label: "Sare", value: nutriments.salt100g, unit: "g")
                            }
                            .padding()
                        }
                    }
                } else {
                    Text("Scanează un cod de bare pentru a căuta un produs.")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                }

                if let code = scannedCode {
                    Text("Cod scanat: \(code)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Button(isScanning ? "Oprește scanarea" : "Scanează codul de bare") {
                    isScanning.toggle()
                }
                .buttonStyle(.borderedProminent)
                .padding()

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding()
                }

                Spacer()
            }
            .sheet(isPresented: $isScanning) {
                BarcodeScannerView(scannedCode: $scannedCode, isScanning: $isScanning)
                    .ignoresSafeArea()
            }
            .task(id: scannedCode) {
                if let code = scannedCode {
                    await fetchProduct(for: code)
                }
            }
            .navigationTitle("Scan & Identify")
        }
    }

    func fetchProduct(for barcode: String) async {
        guard let url = URL(string: "https://world.openfoodfacts.org/api/v2/product/\(barcode).json") else {
            errorMessage = "URL invalid"
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(OpenFoodFactsResponse.self, from: data)
            if decoded.status == 1 {
                product = decoded.product
                errorMessage = nil
            } else {
                product = nil
                errorMessage = "Produsul nu a fost găsit."
            }
        } catch {
            product = nil
            errorMessage = "Eroare la descărcarea datelor: \(error.localizedDescription)"
        }
    }
}

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

struct OpenFoodFactsResponse: Codable {
    let status: Int
    let product: Product?
}

struct Product: Codable {
    let code: String?
    let productName: String?
    let imageURL: String?
    let nutriments: Nutriments?

    enum CodingKeys: String, CodingKey {
        case code
        case productName = "product_name"
        case imageURL = "image_url"
        case nutriments
    }

    var name: String? { productName }
}

struct Nutriments: Codable {
    let energyKcal100g: Double?
    let fat100g: Double?
    let saturatedFat100g: Double?
    let carbohydrates100g: Double?
    let sugars100g: Double?
    let fiber100g: Double?
    let proteins100g: Double?
    let salt100g: Double?

    enum CodingKeys: String, CodingKey {
        case energyKcal100g = "energy-kcal_100g"
        case fat100g = "fat_100g"
        case saturatedFat100g = "saturated-fat_100g"
        case carbohydrates100g = "carbohydrates_100g"
        case sugars100g = "sugars_100g"
        case fiber100g = "fiber_100g"
        case proteins100g = "proteins_100g"
        case salt100g = "salt_100g"
    }
}
