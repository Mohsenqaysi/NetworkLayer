import XCTest
@testable import NetworkLayer

final class NetworkLayerTests: XCTestCase {
    
    func test_GivenRequest_WhenGenerateURLRequest_ThenExpectedPath() throws {
        let request = givenEmployeesAPIRequest
        let urlRequest: URLRequest = try XCTUnwrap(request.generateURLRequest())
        let url: URL! = urlRequest.url
        let urlComponents: URLComponents! = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let expectedPath = "/sq-mobile-interview/employees.json"


        
        XCTAssertNotNil(urlComponents)
        XCTAssertEqual(urlComponents.path, expectedPath)
    }
}

extension NetworkLayerTests {
    var givenEmployeesAPIRequest: EmployeesAPIRequest {
        return EmployeesAPIRequest()
    }
}
