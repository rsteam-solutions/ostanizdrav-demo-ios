////
// 🦠 Corona-Warn-App
//

import Foundation

protocol TraceWarningMatching {
	
	func matchAndStore(package: SAPDownloadedPackage)
	
}

final class TraceWarningMatcher: TraceWarningMatching {

	// MARK: - Init
	
	init(
		eventStore: EventStoringProviding
	) {
		self.eventStore = eventStore
	}
	
	// MARK: - Overrides
	
	// MARK: - Protocol TraceWarningMatching
	
	func matchAndStore(package: SAPDownloadedPackage) {
		Log.info("[TraceWarningMatching] Start matching TraceTimeIntervalWarnings against Checkins. ", log: .checkin)

		guard let warningPackage = try? SAP_Internal_Pt_TraceWarningPackage(serializedData: package.bin) else {
			Log.error("[TraceWarningMatching] Failed to decode SAPDownloadedPackage", log: .checkin)
			return
		}
		matchAndStore(package: warningPackage)
	}

	// MARK: - Internal

	func matchAndStore(package: SAP_Internal_Pt_TraceWarningPackage) {
		for warning in package.timeIntervalWarnings {

			// Filter checkins with same GUID hash.
			var checkins: [Checkin] = eventStore.checkinsPublisher.value.filter {
				$0.traceLocationGUIDHash == warning.locationGuidHash
			}

			// Filter checkins where the warning overlaps the timeframe.
			checkins = checkins.filter {
				calculateOverlap(checkin: $0, warning: warning) > 0
			}

			Log.info("[TraceWarningMatching] Found \(checkins.count) number of matches. ", log: .checkin)

			// Persist checkins and warning as matches.
			for checkin in checkins {
				let match = TraceTimeIntervalMatch(
					id: 0, // createTraceTimeIntervalMatch will ignore this id. The id is generated by the database.
					checkinId: checkin.id,
					traceWarningPackageId: Int(package.intervalNumber),
					traceLocationGUID: checkin.traceLocationGUID,
					transmissionRiskLevel: Int(warning.transmissionRiskLevel),
					startIntervalNumber: Int(warning.startIntervalNumber),
					endIntervalNumber: Int(warning.startIntervalNumber + warning.period)
				)

				Log.info("[TraceWarningMatching] Persist match with checkinId: \(checkin.id) and traceWarningPackageId: \(package.intervalNumber). ", log: .checkin)
				eventStore.createTraceTimeIntervalMatch(match)
			}
		}
	}

	// Algorithm from: https://github.com/corona-warn-app/cwa-app-tech-spec/blob/proposal/event-registration-mvp/sample-code/presence-tracing/pt-calculate-overlap.js

	func calculateOverlap(checkin: Checkin, warning: SAP_Internal_Pt_TraceTimeIntervalWarning) -> Int {

		func toTimeInterval(_ intervalNumber: UInt32) -> TimeInterval {
			TimeInterval(intervalNumber * 600)
		}

		let endIntervalNumber = warning.startIntervalNumber + warning.period

		let warningStartTimestamp = toTimeInterval(warning.startIntervalNumber)
		let warningEndTimestamp = toTimeInterval(endIntervalNumber)

		let overlapStartTimestamp = max(checkin.checkinStartDate.timeIntervalSince1970, warningStartTimestamp)
		let overlapEndTimestamp = min(checkin.checkinEndDate.timeIntervalSince1970, warningEndTimestamp)
		let overlapInSeconds = overlapEndTimestamp - overlapStartTimestamp

		if overlapInSeconds < 0 {
			return 0
		} else {
			return Int(round(overlapInSeconds / 60))
		}
	}

	// MARK: - Private
	
	private let eventStore: EventStoringProviding
}
