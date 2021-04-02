////
// 🦠 Corona-Warn-App
//

import Foundation

enum CoronaTest {

	case pcr(PCRTest)
	case antigen(AntigenTest)

	var registrationToken: String {
		switch self {
		case .pcr(let pcrTest):
			return pcrTest.registrationToken
		case .antigen(let antigenTest):
			return antigenTest.registrationToken
		}
	}

	var testResult: TestResult? {
		switch self {
		case .pcr(let pcrTest):
			return pcrTest.testResult
		case .antigen(let antigenTest):
			return antigenTest.testResult
		}
	}

	var submissionConsentGiven: Bool {
		switch self {
		case .pcr(let pcrTest):
			return pcrTest.submissionConsentGiven
		case .antigen(let antigenTest):
			return antigenTest.submissionConsentGiven
		}
	}

	var submissionTAN: String? {
		switch self {
		case .pcr(let pcrTest):
			return pcrTest.submissionTAN
		case .antigen(let antigenTest):
			return antigenTest.submissionTAN
		}
	}

	var keysSubmitted: Bool {
		switch self {
		case .pcr(let pcrTest):
			return pcrTest.keysSubmitted
		case .antigen(let antigenTest):
			return antigenTest.keysSubmitted
		}
	}

	var journalEntryCreated: Bool {
		switch self {
		case .pcr(let pcrTest):
			return pcrTest.journalEntryCreated
		case .antigen(let antigenTest):
			return antigenTest.journalEntryCreated
		}
	}

}

struct PCRTest: Codable, Equatable {

	let registrationToken: String
	let testRegistrationDate: Date?

	let testResult: TestResult?
	let submissionConsentGiven: Bool

	// Can only be used once to submit, cached here in case submission fails
	let submissionTAN: String?
	let keysSubmitted: Bool

	let journalEntryCreated: Bool

}

struct AntigenTest: Codable, Equatable {

	let registrationToken: String
	let testedPerson: TestedPerson

	// The date of when the consent was provided by the tested person at the Point of Care.
	let pointOfCareConsentTimestamp: Date

	let testResult: TestResult?
	let submissionConsentGiven: Bool

	// Can only be used once to submit, cached here in case submission fails
	let submissionTAN: String?
	let keysSubmitted: Bool

	let journalEntryCreated: Bool

}

struct TestedPerson: Codable, Equatable {

	let name: String?
	let birthday: String?

}
