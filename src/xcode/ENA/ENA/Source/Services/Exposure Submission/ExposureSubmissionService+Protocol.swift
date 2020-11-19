//
// 🦠 Corona-Warn-App
//

import Foundation

protocol ExposureSubmissionService: class {

	typealias ExposureSubmissionHandler = (_ error: ExposureSubmissionError?) -> Void
	typealias RegistrationHandler = (Result<String, ExposureSubmissionError>) -> Void
	typealias TestResultHandler = (Result<TestResult, ExposureSubmissionError>) -> Void
	typealias TANHandler = (Result<String, ExposureSubmissionError>) -> Void

	var devicePairingConsentAcceptTimestamp: Int64? { get }
	var devicePairingSuccessfulTimestamp: Int64? { get }
	
	/// Indicates wether the user allowed to submit test results automatically to the federation gateway or not. Defaults to `false`.
	// (kga) Re-think implementation after reactive implementation
	//	var isSubmissionConsentGiven: Bool { get set }
	
	var isSubmissionConsentGivenPublisher: Published<Bool>.Publisher { get }
	
	func setSubmissionConsentGiven(consentGiven: Bool)
	
	func submitExposure(
		symptomsOnset: SymptomsOnset,
		visitedCountries: [Country],
		completionHandler: @escaping ExposureSubmissionHandler
	)

	func getRegistrationToken(
		forKey deviceRegistrationKey: DeviceRegistrationKey,
		completion completeWith: @escaping RegistrationHandler
	)
	func getTestResult(_ completeWith: @escaping TestResultHandler)

	/// Fetches test results for a given device key.
	///
	/// - Parameters:
	///   - deviceRegistrationKey: the device key to fetch the test results for
	///   - useStoredRegistration: flag to show if a separate registration is needed (`false`) or an existing registration token is used (`true`)
	///   - completion: a `TestResultHandler`
	func getTestResult(forKey deviceRegistrationKey: DeviceRegistrationKey, useStoredRegistration: Bool, completion: @escaping TestResultHandler)
	func hasRegistrationToken() -> Bool
	func deleteTest()
	func preconditions() -> ExposureManagerState
	func acceptPairing()
	func fakeRequest(completionHandler: ExposureSubmissionHandler?)
	

}
