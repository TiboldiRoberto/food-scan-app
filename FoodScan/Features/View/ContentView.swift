import SwiftUI
import AVFoundation

struct ContentView: View {
    @State var contentViewModel: ContentViewModel = .init()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let product = contentViewModel.product {
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

                if let code = contentViewModel.scannedCode {
                    Text("Cod scanat: \(code)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Button(contentViewModel.isScanning ? "Oprește scanarea" : "Scanează codul de bare") {
                    contentViewModel.isScanning.toggle()
                }
                .buttonStyle(.borderedProminent)
                .padding()

                if let errorMessage = contentViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding()
                }

                Spacer()
            }
            .sheet(isPresented: $contentViewModel.isScanning) {
                BarcodeScannerView(scannedCode: $contentViewModel.scannedCode, isScanning: $contentViewModel.isScanning)
                    .ignoresSafeArea()
            }
            .task(id: contentViewModel.scannedCode) {
                if let code = contentViewModel.scannedCode {
                    await contentViewModel.fetchProduct(for: code)
                }
            }
            .navigationTitle("Scan & Identify")
        }
    }
}
