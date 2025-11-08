import XCTest
@testable import FoodScan

final class FoodScanTests: XCTestCase {
    var contentViewModel: ContentViewModel!
    var testSession: URLSession!

    override func setUpWithError() throws {
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
       
        testSession = URLSession(configuration: config)
        
        contentViewModel = ContentViewModel(urlSession: testSession)
        
        // Clear any old test data
        URLProtocolMock.mockResponseData.removeAll()
        URLProtocolMock.mockError = nil
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFetchProduct_WhenValidBarcode_ReturnsProduct() async throws {
        // Arrange
        let barcode = "5941132022421"
        let sessionURL = URL(string: "https://world.openfoodfacts.org/api/v2/product/\(barcode).json")!
        let mockedResponse = """
            {
              "status": 1,
              "product": {
                "code": "5941132022421",
                "product_name": "mix pentru Gustare de ovaz cu ciocolata",
                "image_url": "https://images.openfoodfacts.org/images/products/594/113/202/2421/front_ro.10.400.jpg",
                "nutriments": {
                  "energy-kcal_100g": 113,
                  "fat_100g": 2.9,
                  "saturated-fat_100g": 1.2,
                  "carbohydrates_100g": 17,
                  "sugars_100g": 5.4,
                  "fiber_100g": 2.3,
                  "proteins_100g": 3.6,
                  "salt_100g": 0.19
                }
              }
            }
            """
        
        URLProtocolMock.mockResponseData = [ sessionURL : mockedResponse.data(using: .utf8)!]
        
        // Act
        await contentViewModel.fetchProduct(for: barcode)
        
        // Assert
        let code = await contentViewModel.product?.code
        let productName = await contentViewModel.product?.productName
        let imageURL = await contentViewModel.product?.imageURL
        let errorMessage = await contentViewModel.errorMessage
        let energyKcal100g = await contentViewModel.product?.nutriments?.energyKcal100g
        let fat100g = await contentViewModel.product?.nutriments?.fat100g
        let saturatedFat100g = await contentViewModel.product?.nutriments?.saturatedFat100g
        let carbohydrates100g = await contentViewModel.product?.nutriments?.carbohydrates100g
        let sugars100g = await contentViewModel.product?.nutriments?.sugars100g
        let fiber100g = await contentViewModel.product?.nutriments?.fiber100g
        let proteins100g = await contentViewModel.product?.nutriments?.proteins100g
        let salt100g = await contentViewModel.product?.nutriments?.salt100g
        
        XCTAssertEqual(code, "5941132022421")
        XCTAssertEqual(productName, "mix pentru Gustare de ovaz cu ciocolata")
        XCTAssertEqual(imageURL, "https://images.openfoodfacts.org/images/products/594/113/202/2421/front_ro.10.400.jpg")
        XCTAssertEqual(energyKcal100g, 113.0)
        XCTAssertEqual(fat100g, 2.9)
        XCTAssertEqual(saturatedFat100g, 1.2)
        XCTAssertEqual(carbohydrates100g, 17)
        XCTAssertEqual(sugars100g, 5.4)
        XCTAssertEqual(fiber100g, 2.3)
        XCTAssertEqual(proteins100g, 3.6)
        XCTAssertEqual(salt100g, 0.19)
        XCTAssertNil(errorMessage)
        
    }
    
    func testFetchProduct_WhenInvalidBarcode_SetsErrorMessage() async {
        let barcode = "0000000000000"
        let sessionURL = URL(string: "https://world.openfoodfacts.org/api/v2/product/\(barcode).json")!
        
        let mockedResponse = """
            {
            "code":"0000000000000",
            "status":0,
            "status_verbose":"product not found"
            }
            """
        
        URLProtocolMock.mockResponseData = [ sessionURL : mockedResponse.data(using: .utf8)!]
        
        // Act
        await contentViewModel.fetchProduct(for: barcode)
        
        let product = await contentViewModel.product
        let errorMessage = await contentViewModel.errorMessage
        
        XCTAssertNil(product)
        XCTAssertEqual(errorMessage, "Produsul nu a fost găsit.")
    }
    
    func testFetchProduct_WhenNetworkError_SetsErrorMessage() async {
        let barcode = "3086123408067"
        let sessionURL = URL(string: "https://world.openfoodfacts.org/api/v2/product/\(barcode).json")!
        
        URLProtocolMock.mockError = NSError(
            domain: NSURLErrorDomain,
            code: NSURLErrorNotConnectedToInternet,
            userInfo: [NSLocalizedDescriptionKey: "No internet connection"]
        )
        
        // Act
        await contentViewModel.fetchProduct(for: barcode)
        
        let product = await contentViewModel.product
        let errorMessage = await contentViewModel.errorMessage
        
        XCTAssertNil(product)
        XCTAssertNotNil(errorMessage)
        XCTAssertTrue(errorMessage?.contains("Eroare") ?? false)
    }
    
    func testFetchProduct_WhenInvalidJSON_SetsErrorMessage() async {
        let barcode = "0000000000000"
        let sessionURL = URL(string: "https://world.openfoodfacts.org/api/v2/product/\(barcode).json")!
        
        let mockedResponse = "This is not valid JSON!"
        
        URLProtocolMock.mockResponseData = [ sessionURL : mockedResponse.data(using: .utf8)!]
        
        // Act
        await contentViewModel.fetchProduct(for: barcode)
        
        let product = await contentViewModel.product
        let errorMessage = await contentViewModel.errorMessage
        
        XCTAssertNil(product)
        XCTAssertNotNil(errorMessage)
        XCTAssertTrue(errorMessage?.contains("Eroare") ?? false)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
