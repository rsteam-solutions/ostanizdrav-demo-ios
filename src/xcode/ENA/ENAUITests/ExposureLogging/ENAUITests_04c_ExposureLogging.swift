//
// 🦠 Corona-Warn-App
//

import XCTest
import ExposureNotification

class ENAUITests_04c_ExposureLogging: CWATestCase {
	
	var app: XCUIApplication!

    override func setUpWithError() throws {
		try super.setUpWithError()
		continueAfterFailure = false
		app = XCUIApplication()
		setupSnapshot(app)
		app.setDefaults()
		app.setLaunchArgument(LaunchArguments.onboarding.isOnboarded, to: false)
		app.setLaunchArgument(LaunchArguments.onboarding.setCurrentOnboardingVersion, to: true)
	}

	// MARK: - Screenshots

	func test_screenshot_exposureLogging() throws {
		var screenshotCounter = 0
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		app.setLaunchArgument(LaunchArguments.onboarding.isOnboarded, to: true)
		app.setLaunchArgument(LaunchArguments.common.ENStatus, to: ENStatus.active.stringValue)
		app.launch()

		// only run if home screen is present
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: 5.0))
		
		app.cells["AppStrings.Home.activateCardOnTitle"].waitAndTap()
		snapshot("exposureloggingscreen_\(String(format: "%04d", (screenshotCounter.inc() )))")
		
		app.swipeUp()
		snapshot("exposureloggingscreen_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}

	func test_screenshot_exposureLoggingOff() throws {
		var screenshotCounter = 0
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		app.setLaunchArgument(LaunchArguments.onboarding.isOnboarded, to: true)
		app.setLaunchArgument(LaunchArguments.common.ENStatus, to: ENStatus.unknown.stringValue)
		app.launch()

		// only run if home screen is present
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: 5.0))

		app.cells["AppStrings.Home.activateCardOffTitle"].waitAndTap()
		snapshot("exposureloggingscreen_\(String(format: "%04d", (screenshotCounter.inc() )))")

		app.swipeUp()
		snapshot("exposureloggingscreen_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}
}
