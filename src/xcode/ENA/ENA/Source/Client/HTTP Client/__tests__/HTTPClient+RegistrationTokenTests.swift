//
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest

final class HTTPClientRegistrationTokenTests: CWATestCase {
	private let expectationsTimeout: TimeInterval = 2

	func testGetRegistrationToken_TeleTANSuccess() throws {
		let expectedToken = "SomeToken"
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: try JSONEncoder().encode(GetRegistrationTokenResponse(registrationToken: expectedToken))
		)

		let successExpectation = expectation(
			description: "Expect that we got a completion"
		)

		HTTPClient.makeWith(mock: stack).getRegistrationToken(forKey: "1234567890", withType: "TELETAN") { result in
			defer { successExpectation.fulfill() }
			switch result {
			case .success(let token):
				XCTAssertEqual(token, expectedToken)
			case .failure:
				XCTFail("Encountered Error when receiving registration token!")
			}
		}
		waitForExpectations(timeout: expectationsTimeout)
	}

	func testGetRegistrationToken_GUIDSuccess() throws {
		let expectedToken = "SomeToken"
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: try JSONEncoder().encode(GetRegistrationTokenResponse(registrationToken: expectedToken))
		)

		let successExpectation = expectation(
			description: "Expect that we got a completion"
		)

		HTTPClient.makeWith(mock: stack).getRegistrationToken(forKey: "1234567890", withType: "GUID") { result in
			defer { successExpectation.fulfill() }
			switch result {
			case .success(let token):
				XCTAssertEqual(token, expectedToken)
			case .failure:
				XCTFail("Encountered Error when receiving registration token!")
			}
		}
		waitForExpectations(timeout: expectationsTimeout)
	}
		
	func testGIVEN_Client_WHEN_GetRegistrationTokenIsCalledWithBirthdate_THEN_TokenIsReturned() throws {
		// GIVEN
		let expectedToken = "SomeToken"
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: try JSONEncoder().encode(GetRegistrationTokenResponse(registrationToken: expectedToken))
		)
		
		let expectation = self.expectation(
			description: "Expect that we got a completion"
		)
		
		var responseToken: String?
		
		// WHEN
		HTTPClient.makeWith(mock: stack).getRegistrationToken(
			forKey: "1234567890",
			withType: "GUID",
			dateOfBirthKey: "x987654321"
		) { result in
			switch result {
			case .success(let token):
				responseToken = token
			case .failure:
				XCTFail("Test should not fail.")
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: expectationsTimeout)
		
		// THEN
		XCTAssertEqual(responseToken ?? "FAIL", expectedToken)
	}
	
	func testGetRegistrationToken_TANAlreadyUsed() throws {
		let stack = MockNetworkStack(
			httpStatus: 400,
			responseData: Data()
		)

		let successExpectation = expectation(
			description: "Test should success with token returned"
		)

		HTTPClient.makeWith(mock: stack).getRegistrationToken(forKey: "1234567890", withType: "TELETAN") { result in
			defer { successExpectation.fulfill() }
			switch result {
			case .success:
				XCTFail("Backend returned 400 - the request should have failed!")
			case .failure(let error):
				switch error {
				case .teleTanAlreadyUsed:
					break
				default:
					XCTFail("The error was not .teleTanAlreadyUsed!")
				}
			}
		}
		waitForExpectations(timeout: expectationsTimeout)
	}

	func testGetRegistrationToken_GUIDAlreadyUsed() throws {
		let stack = MockNetworkStack(
			httpStatus: 400,
			responseData: Data()
		)

		let successExpectation = expectation(
			description: "Expect that we got a completion"
		)

		HTTPClient.makeWith(mock: stack).getRegistrationToken(forKey: "1234567890", withType: "GUID") { result in
			defer { successExpectation.fulfill() }
			switch result {
			case .success:
				XCTFail("Backend returned 400 - the request should have failed!")
			case .failure(let error):
				switch error {
				case .qrAlreadyUsed:
					break
				default:
					XCTFail("The error was not .qrAlreadyUsed!")
				}
			}
		}
		waitForExpectations(timeout: expectationsTimeout)
	}
	
	func testGIVEN_Client_WHEN_GetRegistrationTokenIsCalledWithMalformedBirthdate_THEN_TokenIsReturned() throws {
		// GIVEN
		let expectedToken = "SomeToken"
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: try JSONEncoder().encode(GetRegistrationTokenResponse(registrationToken: expectedToken))
		)
		
		let expectation = self.expectation(
			description: "Test should not success due to malformed birthdateHash"
		)
		
		var responseError: URLSession.Response.Failure?
		
		// WHEN
		HTTPClient.makeWith(mock: stack).getRegistrationToken(
			forKey: "1234567890",
			withType: "GUID",
			dateOfBirthKey: "987654321"
		) { result in
			switch result {
			case .success:
				XCTFail("Test should not success")
			case let .failure(error):
				responseError = error
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: expectationsTimeout)
		
		// THEN
		XCTAssertEqual(responseError ?? URLSession.Response.Failure.serverError(999), URLSession.Response.Failure.malformedRequest)
	}

	func testGetRegistrationToken_MalformedResponse() throws {
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: Data(bytes: [0xA, 0xB] as [UInt8], count: 2)
		)

		let successExpectation = expectation(
			description: "Expect that we got a completion"
		)

		HTTPClient.makeWith(mock: stack).getRegistrationToken(forKey: "1234567890", withType: "GUID") { result in
			defer { successExpectation.fulfill() }
			switch result {
			case .success:
				XCTFail("Backend returned random bytes - the request should have failed!")
			case .failure(let error):
				switch error {
				case .invalidResponse:
					break
				default:
					XCTFail("The error was not .invalidResponse!")
				}
			}
		}
		waitForExpectations(timeout: expectationsTimeout)
	}

	func testGetRegistrationToken_MalformedJSONResponse() throws {
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: """
			{ "NotregistrationToken":"Hello" }
			""".data(using: .utf8)
		)

		let successExpectation = expectation(
			description: "Expect that we got a completion"
		)

		HTTPClient.makeWith(mock: stack).getRegistrationToken(forKey: "1234567890", withType: "GUID") { result in
			defer { successExpectation.fulfill() }
			switch result {
			case .success:
				XCTFail("Backend returned 400 - the request should have failed!")
			case .failure(let error):
				switch error {
				case .invalidResponse:
					break
				default:
					XCTFail("The error was not .invalidResponse!")
				}
			}
		}
		waitForExpectations(timeout: expectationsTimeout)
	}

	func testGetRegistrationToken_VerifyPOSTBodyContent() throws {
		let expectedToken = "SomeToken"
		let key = "1234567890"
		let type = "GUID"

		let sendPostExpectation = expectation(
			description: "Expect that the client sends a POST request"
		)
		let verifyPostBodyContent: MockUrlSession.URLRequestObserver = { request in
			defer { sendPostExpectation.fulfill() }

			guard let content = try? JSONDecoder().decode([String: String].self, from: request.httpBody ?? Data()) else {
				XCTFail("POST body was empty, expected key & key type as JSON!")
				return
			}

			guard content["key"] == key else {
				XCTFail("POST JSON body did not have key value, or it was incorrect!")
				return
			}

			guard content["keyType"] == type else {
				XCTFail("POST JSON body did not have keyType value, or it was incorrect!")
				return
			}
		}
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: try JSONEncoder().encode(GetRegistrationTokenResponse(registrationToken: expectedToken)),
			requestObserver: verifyPostBodyContent
		)

		HTTPClient.makeWith(mock: stack).getRegistrationToken(forKey: key, withType: type) { _ in }
		waitForExpectations(timeout: expectationsTimeout)
	}
}
