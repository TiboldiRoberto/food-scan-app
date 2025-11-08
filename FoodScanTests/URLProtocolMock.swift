import Foundation

class URLProtocolMock: URLProtocol {
    
    static var mockResponseData = [URL: Data]()
    static var mockError: Error?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let error = URLProtocolMock.mockError {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        
        // Check if we have data for this URL
        if let url = request.url,
           let data = URLProtocolMock.mockResponseData[url] {
            
            // Create a fake HTTP response
            let response = HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            
            // Send response and data
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
        // Clean up if needed
    }
}
