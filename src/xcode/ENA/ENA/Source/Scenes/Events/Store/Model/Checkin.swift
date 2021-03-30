////
// 🦠 Corona-Warn-App
//

import Foundation

// This implementation is based on the following technical specification.
// For more details please see: https://github.com/corona-warn-app/cwa-app-tech-spec/blob/e87ef2851c91141573d5714fd24485219280543e/docs/spec/event-registration-client.md

struct Checkin: Equatable {

	let id: Int
	let traceLocationId: Data
	let traceLocationIdHash: Data
	let traceLocationVersion: Int
	let traceLocationType: TraceLocationType
	let traceLocationDescription: String
	let traceLocationAddress: String
	let traceLocationStartDate: Date?
	let traceLocationEndDate: Date?
	let traceLocationDefaultCheckInLengthInMinutes: Int?
	let cryptographicSeed: Data
	let cnPublicKey: Data
	let checkinStartDate: Date
	let checkinEndDate: Date
	let checkinCompleted: Bool
	let createJournalEntry: Bool

	var overlapInSeconds: Int = 0
}

extension Checkin {
	var roundedDurationIn15mSteps: Int {
		let checkinDurationInM = (checkinEndDate - checkinStartDate) / 60
		let roundedDuration = Int(round(checkinDurationInM / 15) * 15)
		return roundedDuration
	}
}

// MARK: - Submission handling

extension Checkin {

	/// a 10 minute interval
	private static let INTERVAL_LENGTH: TimeInterval = 600

	/// Extract and return the  trace location of the current checkin
	var traceLocation: SAP_Internal_Pt_TraceLocation {
		var loc = SAP_Internal_Pt_TraceLocation()
		loc.version = UInt32(traceLocationVersion)
		loc.description_p = traceLocationDescription
		loc.address = traceLocationAddress
		loc.startTimestamp = UInt64(traceLocationStartDate?.timeIntervalSince1970 ?? 0)
		loc.endTimestamp = UInt64(traceLocationEndDate?.timeIntervalSince1970 ?? 0)
		return loc
	}

	/// Converts a `Checkin` to the protobuf structure required for submission
	/// - Throws: `BinaryEncodingError` in case the conversion to a serialized signed location fails
	/// - Returns: The converted `SAP_Internal_Pt_CheckIn`
	func prepareForSubmission() throws -> SAP_Internal_Pt_CheckIn {
		var checkin = SAP_Internal_Pt_CheckIn()

		// 10 minute time interval; derived from the unix timestamps
		// see: https://github.com/corona-warn-app/cwa-app-tech-spec/blob/proposal/event-registration-mvp/docs/spec/event-registration-client.md#derive-10-minute-interval-from-timestamp
		checkin.startIntervalNumber = UInt32(checkinEndDate.timeIntervalSince1970 / Checkin.INTERVAL_LENGTH)
		checkin.endIntervalNumber = UInt32(checkinEndDate.timeIntervalSince1970 / Checkin.INTERVAL_LENGTH)
		assert(checkin.startIntervalNumber < checkin.endIntervalNumber)
		checkin.locationID = traceLocationId

		checkin.transmissionRiskLevel = 42 // TODO: currently calculated outside this function
		return checkin
	}

	/// Caculates the overlap of the current checkin with a `TraceTimeIntervalMatch`, if existing.
	///
	/// For details please refer to [the specification](https://github.com/corona-warn-app/cwa-app-tech-spec/blob/proposal/event-registration-mvp/docs/spec/event-registration-client.md#calculate-overlap-of-checkin-and-tracetimeintervalwarning).
	/// - Parameter matches: The list of `TraceTimeIntervalMatch` to compare to
	/// - Returns: The overlap in seconds; `0` if no match references to this checkin
	func calculateOverlap(with matches: [TraceTimeIntervalMatch]) -> Int {
		guard
			let match = matches.first(where: { $0.traceLocationId == traceLocationId })
		else { return 0 }
		
		let maxStart = max(checkinStartDate.timeIntervalSince1970, Double(match.startIntervalNumber) * Checkin.INTERVAL_LENGTH)
		let minEnd = max(checkinEndDate.timeIntervalSince1970, Double(match.endIntervalNumber) * Checkin.INTERVAL_LENGTH)
		return Int(minEnd - maxStart)
	}

	/// Calculate and apply overlap to current checkin
	/// - Parameter matches: The list of `TraceTimeIntervalMatch` to compare to
	mutating func updateOverlap(with matches: [TraceTimeIntervalMatch]) {
		overlapInSeconds = calculateOverlap(with: matches)
	}
}
