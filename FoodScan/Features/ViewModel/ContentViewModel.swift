import Foundation

@Observable
class ContentViewModel {
    var urlSession: URLSession
    var scannedCode: String?
    var product: Product?
    var isScanning = false
    var errorMessage: String?
    
    init(urlSession: URLSession = .shared, scannedCode: String? = nil, product: Product? = nil, isScanning: Bool = false, errorMessage: String? = nil) {
        self.urlSession = urlSession
        self.scannedCode = scannedCode
        self.product = product
        self.isScanning = isScanning
        self.errorMessage = errorMessage
    }
    
    func fetchProduct(for barcode: String) async {
        guard let url = URL(string: "https://world.openfoodfacts.org/api/v2/product/\(barcode).json") else {
            errorMessage = "URL invalid"
            return
        }
        do {
            let (data, _) = try await urlSession.data(from: url)
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
