# FoodScan App

A SwiftUI barcode scanner application that fetches nutritional information from OpenFoodFacts API, built as a learning project for network testing in iOS development.

## Purpose

This project was created to practice and learn:
* Testing networking code without making real API calls
* Using URLProtocol mocking for fast, repeatable tests
* Dependency injection with URLSession
* Testing async/await code with XCTest

## Features

Barcode scanner with:
* Real-time barcode detection (EAN-8, EAN-13, Code-128)
* Product name and image display
* Complete nutritional information per 100g
* Error handling for missing products and network failures
* Async/await for smooth user experience

## Architecture

The app uses MVVM architecture:
* **ContentView**: SwiftUI interface with scanner and product display
* **ContentViewModel**: Business logic, API calls, and state management
* **BarcodeScannerView**: AVFoundation camera wrapper
* **URLProtocolMock**: Network interceptor for testing

## Testing Approach

The test suite uses **URLProtocol subclassing** to intercept network requests, based on [Paul Hudson's testing approach](https://www.hackingwithswift.com/articles/153/how-to-test-ios-apps-using-xctest).

### Use Cases Tested
* Successful product fetch with complete data
* Product not found (API returns status: 0)
* Network errors (timeout, no connection)
* Invalid JSON response handling

### How It Works
```swift
// 1. Create a test URLSession with our mock protocol
let config = URLSessionConfiguration.ephemeral
config.protocolClasses = [URLProtocolMock.self]
let testSession = URLSession(configuration: config)

// 2. Inject it into the ViewModel
contentViewModel = ContentViewModel(urlSession: testSession)

// 3. Set up mock response data
URLProtocolMock.mockResponseData[url] = mockJSON.data(using: .utf8)!

// 4. Test runs instantly without real network calls!
await contentViewModel.fetchProduct(for: barcode)
```

### Test Organization

Tests follow the pattern:
```
test[Method]_[Scenario]_[ExpectedBehavior]
```

Examples:
* `testFetchProduct_WhenValidBarcode_ReturnsProduct()`
* `testFetchProduct_WhenProductNotFound_SetsErrorMessage()`
* `testFetchProduct_WhenNetworkError_SetsErrorMessage()`

## What I Learned

1. **URLProtocol Mocking**: Intercept network calls without changing production code
2. **Dependency Injection**: Making URLSession injectable enables testing
3. **FIRST Principles**: Fast, Isolated, Repeatable, Self-verifying, Timely tests
4. **Async Testing**: Using `async throws` in test methods with `await`
5. **Mock Data Management**: Creating minimal JSON responses for testing

## Running Tests

1. Open the project in Xcode
2. Press `Cmd + U` to run all tests
3. Or click individual test diamonds in the test navigator

## Technologies

* SwiftUI for UI
* AVFoundation for barcode scanning
* URLSession with async/await for networking
* XCTest with URLProtocol mocking for testing
* OpenFoodFacts API for product data

## Key Takeaways

Network testing doesn't require complex mocking frameworks:
* URLProtocol interception is built into iOS
* Production code stays clean (no test-only changes)
* Tests run instantly (no waiting for real APIs)
* Complete control over responses (success, errors, edge cases)
* Dependency injection makes code naturally testable

---

**API**: [OpenFoodFacts](https://world.openfoodfacts.org/)  
**Testing Guide**: [Hacking with Swift - Testing iOS Networking](https://www.hackingwithswift.com/articles/153/how-to-test-ios-apps-using-xctest)
