////
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITests_08_UpdateOS: XCTestCase {

	var app: XCUIApplication!

	// MARK: - Setup.

	override func setUpWithError() throws {
		continueAfterFailure = false
		app = XCUIApplication()
		setupSnapshot(app)
		app.setDefaults()
		app.setLaunchArgument(LaunchArguments.infoScreen.showUpdateOS, to: true)
	}
	
	// MARK: - Screenshots

	func test_screenshot_UpdateOS() {
		app.launch()
		
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.UpdateOSScreen.text] .waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.UpdateOSScreen.title] .waitForExistence(timeout: .short))
		XCTAssertTrue(app.images[AccessibilityIdentifiers.UpdateOSScreen.logo] .waitForExistence(timeout: .short))
		XCTAssertTrue(app.images[AccessibilityIdentifiers.UpdateOSScreen.mainImage] .waitForExistence(timeout: .short))

		snapshot("UpdateOS")
	}

}
