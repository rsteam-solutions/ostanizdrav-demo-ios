//
// 🦠 Corona-Warn-App
//

import Foundation

struct Risk: Equatable {

	struct Details: Equatable {
		var mostRecentDateWithRiskLevel: Date?
		var numberOfDaysWithRiskLevel: Int
		var calculationDate: Date?
		var minimumDistinctEncountersWithCurrentRiskLevel: Int?
	}

	let level: RiskLevel
	let details: Details
	let riskLevelHasChanged: Bool
}

extension Risk {
	init(
		enfRiskCalculationResult: ENFRiskCalculationResult,
		previousENFRiskCalculationResult: ENFRiskCalculationResult? = nil,
		checkinCalculationResult: CheckinRiskCalculationResult,
		previousCheckinCalculationResult: CheckinRiskCalculationResult? = nil
	) {
		Log.info("[Risk] Merging risks from ENF and checkin. Create Risk.", log: .riskDetection)

		let riskLevelHasChanged = previousENFRiskCalculationResult?.riskLevel != nil &&
			enfRiskCalculationResult.riskLevel != previousENFRiskCalculationResult?.riskLevel ||
			previousCheckinCalculationResult?.riskLevel != nil &&
			checkinCalculationResult.riskLevel != previousCheckinCalculationResult?.riskLevel

		Log.debug("[Risk] riskLevelHasChanged: \(riskLevelHasChanged)", log: .riskDetection)

		let tracingRiskLevelPerDate = enfRiskCalculationResult.riskLevelPerDate
		let checkinRiskLevelPerDate = checkinCalculationResult.riskLevelPerDate

		Log.debug("[Risk] tracingRiskLevelPerDate: \(tracingRiskLevelPerDate)", log: .riskDetection)
		Log.debug("[Risk] checkinRiskLevelPerDate: \(checkinRiskLevelPerDate)", log: .riskDetection)

		// Merge the results from both risk calculation. For each date, the higher risk level is used.
		let mergedRiskLevelPerDate = tracingRiskLevelPerDate.merging(checkinRiskLevelPerDate) { lhs, rhs -> RiskLevel in
			max(lhs, rhs)
		}

		Log.debug("[Risk] mergedRiskLevelPerDate: \(mergedRiskLevelPerDate)", log: .riskDetection)

		// The Total Risk Level is High if there is least one Date with Risk Level per Date calculated as High; it is Low otherwise.
		var totalRiskLevel: RiskLevel = .low
		if mergedRiskLevelPerDate.contains(where: {
			$0.value == .high
		}) {
			totalRiskLevel = .high
		}

		Log.debug("[Risk] totalRiskLevel: \(totalRiskLevel)", log: .riskDetection)

		// 1. Filter for the desired risk.
		// 2. Select the maximum by date (the most currrent).
		let mostRecentDateWithRiskLevel = mergedRiskLevelPerDate.filter {
			$1 == totalRiskLevel
		}.max(by: {
			$0.key < $1.key
		})?.key

		Log.debug("[Risk] mostRecentDateWithRiskLevel: \(String(describing: mostRecentDateWithRiskLevel))", log: .riskDetection)

		let numberOfDaysWithRiskLevel = mergedRiskLevelPerDate.filter {
			$1 == totalRiskLevel
		}.count

		Log.debug("[Risk] numberOfDaysWithRiskLevel: \(numberOfDaysWithRiskLevel)", log: .riskDetection)

		let calculationDate = max(enfRiskCalculationResult.calculationDate, checkinCalculationResult.calculationDate)

		let details = Details(
			mostRecentDateWithRiskLevel: mostRecentDateWithRiskLevel,
			numberOfDaysWithRiskLevel: numberOfDaysWithRiskLevel,
			calculationDate: calculationDate,
			minimumDistinctEncountersWithCurrentRiskLevel: enfRiskCalculationResult.minimumDistinctEncountersWithCurrentRiskLevel
		)

		self.init(
			level: totalRiskLevel,
			details: details,
			riskLevelHasChanged: riskLevelHasChanged
		)
	}
}

#if DEBUG
extension Risk {
	static let numberOfDaysWithRiskLevel = (UserDefaults.standard.string(forKey: "numberOfDaysWithRiskLevel") as NSString?)?.integerValue
	static let numberOfDaysWithRiskLevelDefaultValue: Int = UserDefaults.standard.string(forKey: "riskLevel") == "high" ? 1 : 0
	static let mocked = Risk(
		// UITests can set app.launchArguments "-riskLevel"
		level: UserDefaults.standard.string(forKey: "riskLevel") == "high" ? .high : .low,
		details: Risk.Details(
			mostRecentDateWithRiskLevel: Date(timeIntervalSinceNow: -24 * 3600),
			numberOfDaysWithRiskLevel: numberOfDaysWithRiskLevel ?? numberOfDaysWithRiskLevelDefaultValue,
			calculationDate: Date()),
		riskLevelHasChanged: true
	)

	static func mocked(
		level: RiskLevel = .low) -> Risk {
		Risk(
			level: level,
			details: Risk.Details(
				mostRecentDateWithRiskLevel: Date(timeIntervalSinceNow: -24 * 3600),
				numberOfDaysWithRiskLevel: numberOfDaysWithRiskLevel ?? numberOfDaysWithRiskLevelDefaultValue,
				calculationDate: Date()),
			riskLevelHasChanged: true
		)
	}
}
#endif
