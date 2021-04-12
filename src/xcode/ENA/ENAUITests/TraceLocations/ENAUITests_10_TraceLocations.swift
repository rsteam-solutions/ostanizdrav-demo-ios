////
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITests_10_TraceLocations: XCTestCase {
	
	// MARK: - Setup.
	
	override func setUpWithError() throws {
		continueAfterFailure = false
		app = XCUIApplication()
		setupSnapshot(app)
		app.setDefaults()
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-setCurrentOnboardingVersion", "YES"])
		app.launchArguments.append(contentsOf: ["-userNeedsToBeInformedAboutHowRiskDetectionWorks", "NO"])
	}
	
	// MARK: - Attributes.
	
	var app: XCUIApplication!
	
	// MARK: - Test cases.
	
	func test_WHEN_navigate_to_TraceLocations_for_the_first_time_THEN_infoscreen_is_displayed() throws {
		// GIVEN
		app.launchArguments.append(contentsOf: ["-TraceLocationsInfoScreenShown", "NO"])
		
		// WHEN
		app.launch()
		// Swipe up until it is visible
		
		if let button = UITestHelper.scrollTo(identifier: AccessibilityIdentifiers.Home.traceLocationsCardButton, element: app, app: app) {
			button.tap()
		} else {
			XCTFail("Can't find element \(AccessibilityIdentifiers.Home.traceLocationsCardButton)")
		}
		
		// THEN
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.TraceLocation.dataPrivacyTitle].waitForExistence(timeout: .short))
		XCTAssertTrue(app.images[AccessibilityIdentifiers.TraceLocation.imageDescription].exists)
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].exists)
	}
	
	func test_WHEN_navigate_to_TraceLocations_for_the_second_time_THEN_no_infoscreen_is_displayed() throws {
		// GIVEN
		app.launchArguments.append(contentsOf: ["-TraceLocationsInfoScreenShown", "YES"])
		
		// WHEN
		app.launch()
		if let button = UITestHelper.scrollTo(identifier: AccessibilityIdentifiers.Home.traceLocationsCardButton, element: app, app: app) {
			button.tap()
		} else {
			XCTFail("Can't find element \(AccessibilityIdentifiers.Home.traceLocationsCardButton)")
		}
		
		// THEN
		XCTAssertFalse(app.cells[AccessibilityIdentifiers.TraceLocation.dataPrivacyTitle].waitForExistence(timeout: .short))
		XCTAssertFalse(app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].exists)
	}
	
	func test_WHEN_QRCode_is_created_THEN_list_contains_traceLocation() throws {
		// GIVEN
		app.launchArguments.append(contentsOf: ["-TraceLocationsInfoScreenShown", "YES"])
		
		// WHEN
		app.launch()
		if let button = UITestHelper.scrollTo(identifier: AccessibilityIdentifiers.Home.traceLocationsCardButton, element: app, app: app) {
			button.tap()
		} else {
			XCTFail("Can't find element \(AccessibilityIdentifiers.Home.traceLocationsCardButton)")
		}
		
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.addButtonTitle)].waitForExistence(timeout: .short))
		
		let event = "Ausser Atem"
		let location = "Cinema Paradiso"
		createTraceLocation(event: event, location: location)
		
		// THEN
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.title)].waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.selfCheckinButtonTitle)].exists)
		XCTAssertTrue(app.staticTexts[event].exists)
		XCTAssertTrue(app.staticTexts[location].exists)
		
		removeTraceLocation(event: event)
		
		XCTAssertFalse(app.staticTexts[event].exists)
		XCTAssertFalse(app.staticTexts[location].exists)
	}
	
	func test_WHEN_two_QRCodes_are_created_THEN_list_displays_two_traceLocations() throws {
		// GIVEN
		app.launchArguments.append(contentsOf: ["-TraceLocationsInfoScreenShown", "YES"])
		
		// WHEN
		app.launch()
		if let button = UITestHelper.scrollTo(identifier: AccessibilityIdentifiers.Home.traceLocationsCardButton, element: app, app: app) {
			button.tap()
		} else {
			XCTFail("Can't find element \(AccessibilityIdentifiers.Home.traceLocationsCardButton)")
		}
		
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.addButtonTitle)].waitForExistence(timeout: .short))
		
		let event1 = "Daily Scrum"
		let location1 = "Office"
		createTraceLocation(event: event1, location: location1)
		
		let event2 = "Sprint Planning"
		let location2 = "Walldorf"
		createTraceLocation(event: event2, location: location2)
		
		// THEN
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.title)].waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.selfCheckinButtonTitle)].exists)
		XCTAssertTrue(app.staticTexts[event1].exists)
		XCTAssertTrue(app.staticTexts[location1].exists)
		XCTAssertTrue(app.staticTexts[event2].exists)
		XCTAssertTrue(app.staticTexts[location2].exists)
		
		// clean up
		removeAllTraceLocationsAtOnce()
		
		XCTAssertFalse(app.staticTexts[event1].exists)
		XCTAssertFalse(app.staticTexts[event2].exists)
	}

	func test_WHEN_list_contains_traceLocations_THEN_delete_all_entries_via_menu_function() throws {
		// GIVEN
		app.launchArguments.append(contentsOf: ["-TraceLocationsInfoScreenShown", "YES"])
		
		// WHEN
		app.launch()
		if let button = UITestHelper.scrollTo(identifier: AccessibilityIdentifiers.Home.traceLocationsCardButton, element: app, app: app) {
			button.tap()
		} else {
			XCTFail("Can't find element \(AccessibilityIdentifiers.Home.traceLocationsCardButton)")
		}
		
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.addButtonTitle)].waitForExistence(timeout: .short))
		
		let event1 = "Retrospektive"
		let location1 = "Office"
		createTraceLocation(event: event1, location: location1)
		
		let event2 = "Refinement"
		let location2 = "Walldorf"
		createTraceLocation(event: event2, location: location2)
		
		// THEN
		XCTAssertTrue(app.cells.count >= 3) // assumption: at least 3 cells
		
		// tap the "more" button
		app.navigationBars.buttons[AccessibilityIdentifiers.TraceLocation.Overview.menueButton].tap()
		
		// verify the buttons
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.ActionSheet.editTitle)].waitForExistence(timeout: .short))
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.ActionSheet.infoTitle)].exists)
		
		// tap "Edit" button
		app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.ActionSheet.editTitle)].tap()

		// button "Alle entfernen"
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].waitForExistence(timeout: .short))
		app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].tap()

		// Alert: tap "Löschen"
		XCTAssertTrue(app.alerts.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.DeleteOneAlert.confirmButtonTitle)].waitForExistence(timeout: .short))
		app.alerts.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.DeleteOneAlert.confirmButtonTitle)].tap()
		
		XCTAssertTrue(app.cells.count == 1) // assumption: only one cell remains
		
	}
	
	func test_WHEN_tapCreateQRCode_THEN_traceLocation_input_screen_is_displayed() throws {
		// GIVEN
		app.launchArguments.append(contentsOf: ["-TraceLocationsInfoScreenShown", "YES"])
		
		// WHEN
		app.launch()
		if let button = UITestHelper.scrollTo(identifier: AccessibilityIdentifiers.Home.traceLocationsCardButton, element: app, app: app) {
			button.tap()
		} else {
			XCTFail("Can't find element \(AccessibilityIdentifiers.Home.traceLocationsCardButton)")
		}
		
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.addButtonTitle)].waitForExistence(timeout: .short))
		
		// tap button "QR Code erstellen"
		app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.addButtonTitle)].tap()
		
		// THEN
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.permanent.subtitle.workplace)].waitForExistence(timeout: .short))
		app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.permanent.subtitle.workplace)].tap()
		
		XCTAssertTrue(app.textFields[AccessibilityIdentifiers.TraceLocation.Configuration.descriptionPlaceholder].exists)
		XCTAssertTrue(app.textFields[AccessibilityIdentifiers.TraceLocation.Configuration.addressPlaceholder].exists)
		
		XCTAssertFalse(app.staticTexts[AccessibilityIdentifiers.TraceLocation.Configuration.temporaryDefaultLengthTitleLabel].exists)
		XCTAssertFalse(app.staticTexts[AccessibilityIdentifiers.TraceLocation.Configuration.temporaryDefaultLengthFootnoteLabel].exists)
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.TraceLocation.Configuration.permanentDefaultLengthTitleLabel].exists)
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.TraceLocation.Configuration.permanentDefaultLengthFootnoteLabel].exists)
		
	}
	
	func test_WHEN_traceLocation_is_tapped_THEN_details_of_traceLocation_are_displayed() throws {
		// GIVEN
		app.launchArguments.append(contentsOf: ["-TraceLocationsInfoScreenShown", "YES"])
		
		// WHEN
		app.launch()
		if let button = UITestHelper.scrollTo(identifier: AccessibilityIdentifiers.Home.traceLocationsCardButton, element: app, app: app) {
			button.tap()
		} else {
			XCTFail("Can't find element \(AccessibilityIdentifiers.Home.traceLocationsCardButton)")
		}
		
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.addButtonTitle)].waitForExistence(timeout: .short))
		
		let event = "At least we can build something"
		let location = "Kino"
		createTraceLocation(event: event, location: location)
		
		XCTAssertTrue(app.staticTexts[event].waitForExistence(timeout: .short))
		
		// the QR code cells start at index = 1
		var query = app.cells
		let n = query.count
		XCTAssertTrue(n > 1)
		// tap the cell to display the details
		query.element(boundBy: 1).tap()

		// THEN
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.AccessibilityLabel.close].waitForExistence(timeout: .short)) // identifier defined in xib
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].exists)
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.General.secondaryFooterButton].exists)
		
		// query for the event title and event location
		query = app.cells.staticTexts
		
		let titleLabel = query.element(matching: .staticText, identifier: AccessibilityIdentifiers.TraceLocation.Details.titleLabel)
		XCTAssertNotNil(titleLabel)
		XCTAssertTrue(titleLabel.label == event)
		
		let locationLabel = query.element(matching: .staticText, identifier: AccessibilityIdentifiers.TraceLocation.Details.locationLabel)
		XCTAssertNotNil(locationLabel)
		XCTAssertTrue(locationLabel.label == location)
		
		// close view
		app.buttons[AccessibilityIdentifiers.AccessibilityLabel.close].tap()
		// clean up
		removeAllTraceLocationsAtOnce()
	}
	
	func test_WHEN_traceLocation_exists_THEN_checkin_and_checkout() throws {
		// GIVEN
		app.launchArguments.append(contentsOf: ["-TraceLocationsInfoScreenShown", "YES"])
		app.launchArguments.append(contentsOf: ["-checkinInfoScreenShown", "YES"]) // checkinInfoScreenShown
		
		// WHEN
		app.launch()
		if let button = UITestHelper.scrollTo(identifier: AccessibilityIdentifiers.Home.traceLocationsCardButton, element: app, app: app) {
			button.tap()
		} else {
			XCTFail("Can't find element \(AccessibilityIdentifiers.Home.traceLocationsCardButton)")
		}
		
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.addButtonTitle)].waitForExistence(timeout: .short))
		
		let event = "Mittagessen"
		let location = "Kantine"
		createTraceLocation(event: event, location: location)
		XCTAssertTrue(app.staticTexts[event].waitForExistence(timeout: .short))
		
		// check in
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.TraceLocation.Configuration.eventTableViewCellButton].exists)
		app.buttons[AccessibilityIdentifiers.TraceLocation.Configuration.eventTableViewCellButton].tap()
		
		// THEN
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.TraceLocation.Details.checkInButton].exists)
		app.buttons[AccessibilityIdentifiers.TraceLocation.Details.checkInButton].tap()
		
		removeTraceLocation(event: event)
		
		// switch to "My Checkins" and checkout of the event
		app.tabBars.buttons[AccessibilityIdentifiers.Tabbar.checkin].tap()
		myCheckins_checkout()
	}
	
	func test_screenshots_of_traceLocation_print_flow() throws {
		app.launch()
		if let button = UITestHelper.scrollTo(identifier: AccessibilityIdentifiers.Home.traceLocationsCardButton, element: app, app: app) {
			button.tap()
		} else {
			XCTFail("Can't find element \(AccessibilityIdentifiers.Home.traceLocationsCardButton)")
		}
		
		let event = "Team Meeting"
		let location = "Office"
		createTraceLocation(event: event, location: location)

		snapshot("tracelocation_overview")
		
		// navigate to detail view for second item
		app.tables[AccessibilityIdentifiers.TraceLocation.Overview.tableView].cells.element(boundBy: 1).tap()
		
		// check if the print version button exists
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].waitForExistence(timeout: .short))

		snapshot("tracelocation_detail_view")
		
		// navigate to trace location print version view
		app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].tap()
		
		// wait for the pdf view to be loaded
		let delayExpectation = XCTestExpectation()
		delayExpectation.isInverted = true
		wait(for: [delayExpectation], timeout: .short)
		
		snapshot("tracelocation_pdf_view")

		// navigate back
		let query = app.navigationBars.buttons
		let n = query.count
		XCTAssertTrue(n > 0)
		for i in 0...(n - 1) {
			let label = query.element(boundBy: i).label
			if label == AccessibilityLabels.localized(AppStrings.Common.general_BackButtonTitle) {
				query.element(boundBy: i).tap()
				break
			}
		}
		
		// tap the close button
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.AccessibilityLabel.close].waitForExistence(timeout: .short))
		app.buttons[AccessibilityIdentifiers.AccessibilityLabel.close].tap()
		
		// clean up
		removeAllTraceLocationsAtOnce()
	}
	
	// MARK: - Internal
	
	func myCheckins_checkout() {

		let initialNumberOfCells = app.cells.count
		
		// iterate over all event cells and search for the checkout button
		let query = app.cells.buttons
		let n = query.count
		XCTAssertTrue(n > 1)
		var numberOfCheckouts = 0
		for i in 0...(n - 1) {
			if query.element(boundBy: i).identifier == AccessibilityIdentifiers.TraceLocation.Configuration.eventTableViewCellButton {
				numberOfCheckouts = numberOfCheckouts.inc()
			}
		}
		XCTAssertTrue( numberOfCheckouts == 1 ) // assumption: one cell has a checkout button
		
		// tap checkout button
		XCTAssertTrue(query.element(boundBy: 1).identifier == AccessibilityIdentifiers.TraceLocation.Configuration.eventTableViewCellButton)
		_ = query.element(boundBy: 1).waitForExistence(timeout: .short)
		query.element(boundBy: 1).tap()
		
		app.swipeUp()
		app.swipeDown()
		
		// tap the event, verify the detail screen
		
		XCTAssertTrue( initialNumberOfCells == app.cells.count ) // assumption: number of cells has not changed
		query.element(boundBy: 1).tap()
		
		let staticTexts = app.cells.staticTexts
		XCTAssertTrue(staticTexts.element(matching: .staticText, identifier: AccessibilityIdentifiers.Checkin.Details.typeLabel).exists)
		XCTAssertTrue(staticTexts.element(matching: .staticText, identifier: AccessibilityIdentifiers.Checkin.Details.traceLocationTypeLabel).exists)
		XCTAssertTrue(staticTexts.element(matching: .staticText, identifier: AccessibilityIdentifiers.Checkin.Details.traceLocationDescriptionLabel).exists)
		XCTAssertTrue(staticTexts.element(matching: .staticText, identifier: AccessibilityIdentifiers.Checkin.Details.traceLocationAddressLabel).exists)
		
		// tap "Speichern" to go back to overview
		let buttons = app.buttons
		XCTAssertTrue(buttons.element(matching: .button, identifier: AccessibilityIdentifiers.General.primaryFooterButton).exists)
		buttons.element(matching: .button, identifier: AccessibilityIdentifiers.General.primaryFooterButton).tap()

		// tap the "more" button
		app.navigationBars.buttons[AccessibilityIdentifiers.Checkin.Overview.menueButton].tap()
		
		// verify the buttons
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.Checkins.Overview.ActionSheet.editTitle)].waitForExistence(timeout: .short))
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.Checkins.Overview.ActionSheet.infoTitle)].exists)
		
		// tap "Edit" button
		app.buttons[AccessibilityLabels.localized(AppStrings.Checkins.Overview.ActionSheet.editTitle)].tap()

		// button "Alle entfernen"
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].waitForExistence(timeout: .short))
		app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].tap()

		// Alert: tap "Entfernen"
		XCTAssertTrue(app.alerts.buttons[AccessibilityLabels.localized(AppStrings.Checkins.Overview.DeleteAllAlert.confirmButtonTitle)].waitForExistence(timeout: .short))
		app.alerts.buttons[AccessibilityLabels.localized(AppStrings.Checkins.Overview.DeleteOneAlert.confirmButtonTitle)].tap()
		
		XCTAssertTrue(app.cells.count == 1) // assumption: only one cell remains
	}
	
	func createTraceLocation(event: String, location: String) {
		// add trace location
		app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.addButtonTitle)].tap()
		
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.permanent.subtitle.workplace)].waitForExistence(timeout: .short))
		app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.permanent.subtitle.workplace)].tap()
		
		let descriptionInputField = app.textFields[AccessibilityIdentifiers.TraceLocation.Configuration.descriptionPlaceholder]
		let locationInputField = app.textFields[AccessibilityIdentifiers.TraceLocation.Configuration.addressPlaceholder]
		descriptionInputField.tap()
		descriptionInputField.typeText(event)
		locationInputField.tap()
		locationInputField.typeText(location)
		
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].tap()
	}
	
	func removeTraceLocation(event: String) {
		app.staticTexts[event].swipeLeft()
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.DeleteOneAlert.confirmButtonTitle)].waitForExistence(timeout: .short))
		
		// tap "Löschen"
		app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.DeleteOneAlert.confirmButtonTitle)].tap()
		// Alert: tap "Löschen"
		app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.DeleteOneAlert.confirmButtonTitle)].tap()
	}
	
	func removeAllTraceLocationsAtOnce() {
		app.navigationBars.buttons.element(boundBy: 1).tap()

		let editButton = app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.ActionSheet.editTitle)]
		XCTAssertTrue(editButton.waitForExistence(timeout: .medium))
		editButton.tap()

		// tap "Alle entfernen"
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].waitForExistence(timeout: .medium))
		app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].tap()

		// Alert: tap "Löschen"
		XCTAssertTrue(app.alerts.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.DeleteAllAlert.confirmButtonTitle)].waitForExistence(timeout: .short))
		app.alerts.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.DeleteAllAlert.confirmButtonTitle)].tap()

		return // all QR codes have been deleted
	}
	
}
