////
// 🦠 Corona-Warn-App
//

import XCTest
import ExposureNotification

// swiftlint:disable:next type_body_length
class ENAUITests_07_ContactJournal: XCTestCase {

	// MARK: - Overrides

	override func setUpWithError() throws {
		continueAfterFailure = false

		app = XCUIApplication()
		app.setDefaults()
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.onboarding.isOnboarded, YES])
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.onboarding.setCurrentOnboardingVersion, YES])
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.infoScreen.userNeedsToBeInformedAboutHowRiskDetectionWorks, NO])
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.contactJournal.journalRemoveAllPersons, YES])
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.contactJournal.journalRemoveAllLocations, YES])
	}

	// MARK: - Internal

	var app: XCUIApplication!

	// MARK: - Test cases.

	func testOpenInformationScreenViaSheet() throws {
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.infoScreen.diaryInfoScreenShown, YES])

		openInformationSheet()

		app.sheets.firstMatch.buttons.element(boundBy: 0).waitAndTap()

		// Check whether we have entered the info screen.
		XCTAssertTrue(app.images["AppStrings.ContactDiaryInformation.imageDescription"].waitForExistence(timeout: .medium))
	}

	func testOpenExportViaSheet() throws {
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.infoScreen.diaryInfoScreenShown, YES])

		openInformationSheet()

		app.sheets.firstMatch.buttons.element(boundBy: 1).waitAndTap()

		// Check whether we have entered the share sheet.
		XCTAssertTrue(app.otherElements["ActivityListView"].waitForExistence(timeout: .medium))
	}

	func testDeleteAllPersons() throws {
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.infoScreen.diaryInfoScreenShown, YES])

		openEditPersonViaSheet()

		XCTAssertEqual(app.navigationBars.element(boundBy: 0).identifier, app.localized("ContactDiary_EditEntries_ContactPersons_Title"))

		app.buttons[app.localized("ContactDiary_EditEntries_ContactPersons_DeleteAllButtonTitle")].waitAndTap()

		XCTAssertEqual(app.alerts.firstMatch.label, app.localized("ContactDiary_EditEntries_ContactPersons_AlertTitle"))
		app.alerts.firstMatch.buttons[app.localized("ContactDiary_EditEntries_ContactPersons_AlertConfirmButtonTitle")].waitAndTap()

		XCTAssertEqual(app.tables[AccessibilityIdentifiers.ContactDiaryInformation.EditEntries.tableView].cells.count, 0)
	}

	func testDeleteOnePersonAndEditOnePerson() throws {
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.infoScreen.diaryInfoScreenShown, YES])

		openEditPersonViaSheet()

		XCTAssertEqual(app.navigationBars.element(boundBy: 0).identifier, app.localized("ContactDiary_EditEntries_ContactPersons_Title"))

		let personsTableView = app.tables[AccessibilityIdentifiers.ContactDiaryInformation.EditEntries.tableView]
		XCTAssertEqual(personsTableView.cells.count, 2)

		// tap the delete button :-)
		personsTableView.cells.element(boundBy: 1).buttons.element(boundBy: 0).waitAndTap()
		// wait for delete confirmation button trailing in the cell
		personsTableView.cells.element(boundBy: 1).buttons.element(boundBy: 2).waitAndTap()

		XCTAssertEqual(app.alerts.firstMatch.label, app.localized("ContactDiary_EditEntries_ContactPerson_AlertTitle"))
		app.alerts.firstMatch.buttons[app.localized("ContactDiary_EditEntries_ContactPerson_AlertConfirmButtonTitle")].waitAndTap()

		XCTAssertEqual(personsTableView.cells.count, 1)

		// select person to edit
		let originalPerson = personsTableView.cells.firstMatch.staticTexts.firstMatch.label
		personsTableView.cells.firstMatch.waitAndTap()

		XCTAssertEqual(app.navigationBars.element(boundBy: 1).identifier, app.localized("ContactDiary_AddEditEntry_PersonTitle"))

		let textField = app.textFields.firstMatch
		textField.waitAndTap()
		textField.typeText("-Müller")

		app.buttons[app.localized("ContactDiary_AddEditEntry_PrimaryButton_Title")].waitAndTap()

		XCTAssertNotEqual(originalPerson, personsTableView.cells.firstMatch.staticTexts.firstMatch.label)
		XCTAssertEqual(originalPerson + "-Müller", personsTableView.cells.firstMatch.staticTexts.firstMatch.label)
	}

	func testDeleteOneLocationAndEditOneLocation() throws {
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.infoScreen.diaryInfoScreenShown, YES])

		openEditLocationsViaSheet()

		XCTAssertEqual(app.navigationBars.element(boundBy: 0).identifier, app.localized("ContactDiary_EditEntries_Locations_Title"))

		let locationsTableView = app.tables[AccessibilityIdentifiers.ContactDiaryInformation.EditEntries.tableView]
		XCTAssertEqual(locationsTableView.cells.count, 2)

		// tap the delete button :-)
		locationsTableView.cells.element(boundBy: 1).buttons.element(boundBy: 0).waitAndTap()
		// wait for delete confirmation button trailing in the cell
		locationsTableView.cells.element(boundBy: 1).buttons.element(boundBy: 2).waitAndTap()

		XCTAssertEqual(app.alerts.firstMatch.label, app.localized("ContactDiary_EditEntries_Location_AlertTitle"))
		app.alerts.firstMatch.buttons[app.localized("ContactDiary_EditEntries_Location_AlertConfirmButtonTitle")].waitAndTap()

		XCTAssertEqual(locationsTableView.cells.count, 1)

		// select location to edit
		let originalLocation = locationsTableView.cells.firstMatch.staticTexts.firstMatch.label
		locationsTableView.cells.firstMatch.waitAndTap()

		XCTAssertEqual(app.navigationBars.element(boundBy: 1).identifier, app.localized("ContactDiary_AddEditEntry_LocationTitle"))
		let textField = app.textFields.firstMatch
		textField.waitAndTap()
		textField.typeText(" Innenstadt")

		XCTAssertTrue(textField.buttons.firstMatch.waitForExistence(timeout: .medium))
		// tap the clear button inside textfield to clear input
		textField.buttons.firstMatch.waitAndTap()
		textField.typeText("Supermarkt Innenstadt")

		app.buttons[app.localized("ContactDiary_AddEditEntry_PrimaryButton_Title")].waitAndTap()

		XCTAssertNotEqual(originalLocation, locationsTableView.cells.firstMatch.staticTexts.firstMatch.label)
		XCTAssertEqual("Supermarkt Innenstadt", locationsTableView.cells.firstMatch.staticTexts.firstMatch.label)
	}

	func testAddPersonToDate() throws {
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.infoScreen.diaryInfoScreenShown, YES])

		navigateToJournalOverview()

		// check count for overview: day cell 15 days plus 1 description cell
		XCTAssertEqual(app.descendants(matching: .table).firstMatch.cells.count, 15 + 1)

		// select 3th cell
		app.descendants(matching: .table).firstMatch.cells.element(boundBy: 3).waitAndTap()

		let dayTableView = app.tables[AccessibilityIdentifiers.ContactDiary.dayTableView]

		// check count for day entries: 1 add entry cell
		XCTAssertEqual(dayTableView.cells.count, 1)

		addPersonToDayEntry("Max Mustermann", phoneNumber: "12345678", eMail: "max@mustermann.de")

		// check count for day entries: 1 add entry cell + 1 person added
		XCTAssertEqual(dayTableView.cells.count, 2)

		addPersonToDayEntry("Erika Musterfrau", phoneNumber: "12345678", eMail: "erika@musterfrau.de")

		// check count for day entries: 1 add entry cell + 2 persons added
		XCTAssertEqual(dayTableView.cells.count, 3)
	}

	func testAddLocationToDate() throws {
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.infoScreen.diaryInfoScreenShown, YES])

		navigateToJournalOverview()

		// check count for overview: day cell 15 days plus 1 description cell
		XCTAssertEqual(app.descendants(matching: .table).firstMatch.cells.count, 15 + 1)

		// select 3rd cell
		app.descendants(matching: .table).firstMatch.cells.element(boundBy: 3).waitAndTap()

		XCTAssertTrue(app.segmentedControls.firstMatch.waitForExistence(timeout: .medium))
		app.segmentedControls.firstMatch.buttons[app.localized("ContactDiary_Day_LocationsSegment")].waitAndTap()

		let dayTableView = app.tables[AccessibilityIdentifiers.ContactDiary.dayTableView]

		// check count for day entries: 1 add entry cell
		XCTAssertEqual(dayTableView.firstMatch.cells.count, 1)

		addLocationToDayEntry("Bäckerei", phoneNumber: "12345678", eMail: "bäcker@meinestadt.de")

		// check count for day entries: 1 add entry cell + 1 location added
		XCTAssertEqual(dayTableView.cells.count, 2)

		addLocationToDayEntry("Supermarkt", phoneNumber: "12345678", eMail: "super@markt.de")

		// check count for day entries: 1 add entry cell + 2 locations added
		XCTAssertEqual(dayTableView.cells.count, 3)
	}

	func testDetailsSelectionOfPersonEncounter() {
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.infoScreen.diaryInfoScreenShown, YES])

		navigateToJournalOverview()

		// Select 3rd cell.

		app.descendants(matching: .table).firstMatch.cells.element(boundBy: 3).waitAndTap()

		// Add person.

		addPersonToDayEntry("Max Mustermann")

		// Select details of encounter.

		let maskSituationButton = app.segmentedControls[AccessibilityIdentifiers.ContactDiaryInformation.Day.maskSituationSegmentedControl].firstMatch.buttons.element(boundBy: 1)
		maskSituationButton.waitAndTap()

		let settingButton = app.segmentedControls[AccessibilityIdentifiers.ContactDiaryInformation.Day.settingSegmentedControl].firstMatch.buttons.element(boundBy: 1)
		settingButton.waitAndTap()

		// Enter note

		app.textFields[AccessibilityIdentifiers.ContactDiaryInformation.Day.notesTextField].firstMatch.waitAndTap()
		app.textFields[AccessibilityIdentifiers.ContactDiaryInformation.Day.notesTextField].firstMatch.typeText("Some note!")

		// Navigate back.

		app.navigationBars.firstMatch.buttons.element(boundBy: 0).waitAndTap()

		// Check if the label for the settings exists on the overview.

		XCTAssertTrue(app.staticTexts[app.localized("ContactDiary_Day_Encounter_WithoutMask") + ", " + app.localized("ContactDiary_Day_Encounter_Inside")].exists)
		XCTAssertTrue(app.staticTexts["Some note!"].exists)
	}

	func testDetailsSelectionOfLocationVisit() {
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.infoScreen.diaryInfoScreenShown, YES])

		navigateToJournalOverview()

		// Select 3rd cell.

		app.descendants(matching: .table).firstMatch.cells.element(boundBy: 3).waitAndTap()

		// Navigate to locatin section.

		XCTAssertTrue(app.segmentedControls.firstMatch.waitForExistence(timeout: .medium))
		app.segmentedControls.firstMatch.buttons[app.localized("ContactDiary_Day_LocationsSegment")].waitAndTap()

		// Add location.

		addLocationToDayEntry("Pizzabude")

		// Select duration.

		app.otherElements["Hours"].firstMatch.waitAndTap()
		app.keys["0"].waitAndTap()
		app.keys["4"].waitAndTap()
		app.keys["2"].waitAndTap()
		// Close keyboard.
		app.waitAndTap()

		// Wait for closing.

		let textField = app.textFields[AccessibilityIdentifiers.ContactDiaryInformation.Day.notesTextField].firstMatch
		let exists = NSPredicate(format: "exists == 1")
		expectation(for: exists, evaluatedWith: textField, handler: nil)
		waitForExpectations(timeout: .medium, handler: nil)

		// Enter note

		app.textFields[AccessibilityIdentifiers.ContactDiaryInformation.Day.notesTextField].firstMatch.waitAndTap()
		app.textFields[AccessibilityIdentifiers.ContactDiaryInformation.Day.notesTextField].firstMatch.typeText("Some note!")

		// Navigate back.

		app.navigationBars.firstMatch.buttons.element(boundBy: 0).waitAndTap()

		// Check if the label for the settings exists on the overview.

		XCTAssertTrue(app.staticTexts["00:42 " + app.localized("ContactDiary_Overview_LocationVisit_Abbreviation_Hours")].exists)
		XCTAssertTrue(app.staticTexts["Some note!"].exists)
	}

	func testNavigateToPersonEncounterDayInfo() {
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.infoScreen.diaryInfoScreenShown, YES])

		navigateToJournalOverview()

		// Select 3rd cell.
		app.descendants(matching: .table).firstMatch.cells.element(boundBy: 3).waitAndTap()

		addPersonToDayEntry("Max Mustermann")

		// Tap info button.
		app.buttons[AccessibilityIdentifiers.ContactDiaryInformation.Day.notesInfoButton].waitAndTap()

		// Wait for info screen.
		XCTAssertTrue(app.navigationBars[app.localized("Contact_Journal_Notes_Description_Title")].waitForExistence(timeout: .medium))
	}

	func testNavigateToLocationDayInfo() {
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.infoScreen.diaryInfoScreenShown, YES])

		navigateToJournalOverview()

		// Select 3rd cell.
		app.descendants(matching: .table).firstMatch.cells.element(boundBy: 3).waitAndTap()

		// Navigate to locatin section.
		XCTAssertTrue(app.segmentedControls.firstMatch.waitForExistence(timeout: .medium))
		app.segmentedControls.firstMatch.buttons[app.localized("ContactDiary_Day_LocationsSegment")].waitAndTap()

		addLocationToDayEntry("Pizzabude")

		// Tap info button.
		app.buttons[AccessibilityIdentifiers.ContactDiaryInformation.Day.notesInfoButton].waitAndTap()

		// Wait for info screen.
		XCTAssertTrue(app.navigationBars[app.localized("Contact_Journal_Notes_Description_Title")].waitForExistence(timeout: .medium))
	}

	func testNavigationToInformationVC() throws {
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.infoScreen.traceLocationsInfoScreenShown, NO])

		navigateToJournalOverview()

		// Check whether we have entered the info screen.
		XCTAssertTrue(app.images["AppStrings.ContactDiaryInformation.imageDescription"].waitForExistence(timeout: .medium))

		app.swipeUp(velocity: .fast)
		app.swipeUp(velocity: .fast)

		let privacyCell = try XCTUnwrap(app.cells["AppStrings.ContactDiaryInformation.dataPrivacyTitle"].firstMatch, "Privacy Cell not found")
		privacyCell.waitAndTap()

		XCTAssertTrue(app.images["AppStrings.AppInformation.privacyImageDescription"].waitForExistence(timeout: .medium))
	}

	func testCloseInformationVC() throws {
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.infoScreen.traceLocationsInfoScreenShown, NO])

		navigateToJournalOverview()

		// Check whether we have entered the info screen.
		XCTAssertTrue(app.images["AppStrings.ContactDiaryInformation.imageDescription"].waitForExistence(timeout: .medium))

		// Select diary button
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].waitAndTap()

		XCTAssertEqual(app.navigationBars.firstMatch.identifier, app.localized("ContactDiary_Overview_Title"))
	}

	/// Tests: ENF Risk High, Checkin Risk None
	func testOverviewScenario1() throws {
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.infoScreen.diaryInfoScreenShown, YES])
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.risk.riskLevel, "low"])

		navigateToJournalOverview()

        // check if overview is visible
        XCTAssertEqual(app.navigationBars.firstMatch.identifier, app.localized("ContactDiary_Overview_Title"))

		// first cell should have the text for high risk, but none about checkin
		let overviewCellWithEncounterRisk = app.descendants(matching: .table).firstMatch.cells.element(boundBy: 1)
		let highRiskCell = overviewCellWithEncounterRisk.staticTexts[AccessibilityIdentifiers.ContactDiaryInformation.Overview.riskLevelLow]
		XCTAssertTrue(highRiskCell.isHittable)
		let checkinCell = overviewCellWithEncounterRisk.staticTexts[AccessibilityIdentifiers.ContactDiaryInformation.Overview.checkinRiskLevelLow]
		XCTAssertFalse(checkinCell.isHittable)
		
		let overviewCellEmpty = app.descendants(matching: .table).firstMatch.cells.element(boundBy: 4)
		let highRiskCellEmpty = overviewCellEmpty.staticTexts[AccessibilityIdentifiers.ContactDiaryInformation.Overview.riskLevelHigh]
		XCTAssertFalse(highRiskCellEmpty.isHittable)
		let checkinCellEmpty = overviewCellEmpty.staticTexts[AccessibilityIdentifiers.ContactDiaryInformation.Overview.checkinRiskLevelHigh]
		XCTAssertFalse(checkinCellEmpty.isHittable)
	}
	
	/// Tests: ENF Risk High, Checkin Risk High
	func testOverviewScenario2() throws {
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.infoScreen.diaryInfoScreenShown, YES])
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.risk.riskLevel, "high"])
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.risk.checkinRiskLevel, "high"])
		
		navigateToJournalOverview()

		// check if overview is visible
		XCTAssertEqual(app.navigationBars.firstMatch.identifier, app.localized("ContactDiary_Overview_Title"))

		// first cell should have the text for high risk, but none about checkin
		let overviewCellWithEncounterRisk = app.descendants(matching: .table).firstMatch.cells.element(boundBy: 1)
		let highRiskCell = overviewCellWithEncounterRisk.staticTexts[AccessibilityIdentifiers.ContactDiaryInformation.Overview.riskLevelHigh]
		XCTAssertTrue(highRiskCell.isHittable)
		let checkinCell = overviewCellWithEncounterRisk.staticTexts[AccessibilityIdentifiers.ContactDiaryInformation.Overview.checkinRiskLevelHigh]
		XCTAssertTrue(checkinCell.isHittable)
		
		let overviewCellEmpty = app.descendants(matching: .table).firstMatch.cells.element(boundBy: 4)
		let highRiskCellEmpty = overviewCellEmpty.staticTexts[AccessibilityIdentifiers.ContactDiaryInformation.Overview.riskLevelHigh]
		XCTAssertFalse(highRiskCellEmpty.isHittable)
		let checkinCellEmpty = overviewCellEmpty.staticTexts[AccessibilityIdentifiers.ContactDiaryInformation.Overview.checkinRiskLevelHigh]
		XCTAssertFalse(checkinCellEmpty.isHittable)
	}
	
	/// Tests: ENF Risk None, Checkin Risk High
	func testOverviewScenario3() throws {
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.infoScreen.diaryInfoScreenShown, YES])
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.risk.checkinRiskLevel, "low"])

		navigateToJournalOverview()

		// check if overview is visible
		XCTAssertEqual(app.navigationBars.firstMatch.identifier, app.localized("ContactDiary_Overview_Title"))

		// first cell should have the text for high risk, but none about checkin
		let overviewCellWithEncounterRisk = app.descendants(matching: .table).firstMatch.cells.element(boundBy: 1)
		let highRiskCell = overviewCellWithEncounterRisk.staticTexts[AccessibilityIdentifiers.ContactDiaryInformation.Overview.riskLevelHigh]
		XCTAssertFalse(highRiskCell.isHittable)
		let checkinCell = overviewCellWithEncounterRisk.staticTexts[AccessibilityIdentifiers.ContactDiaryInformation.Overview.checkinRiskLevelLow]
		XCTAssertTrue(checkinCell.isHittable)
		
		let overviewCellEmpty = app.descendants(matching: .table).firstMatch.cells.element(boundBy: 4)
		let highRiskCellEmpty = overviewCellEmpty.staticTexts[AccessibilityIdentifiers.ContactDiaryInformation.Overview.riskLevelHigh]
		XCTAssertFalse(highRiskCellEmpty.isHittable)
		let checkinCellEmpty = overviewCellEmpty.staticTexts[AccessibilityIdentifiers.ContactDiaryInformation.Overview.checkinRiskLevelHigh]
		XCTAssertFalse(checkinCellEmpty.isHittable)
	}
	
	// MARK: - Screenshots
	
	func test_screenshot_Overview() throws {
		var screenshotCounter = 0
		// setting up launch arguments
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.infoScreen.diaryInfoScreenShown, YES])
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.risk.riskLevel, "high"])
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.risk.checkinRiskLevel, "high"])
		
		// navigate to desired screen
		navigateToJournalOverview()
		
		// take screenshot from overview cell with high encounter risk and high checkin risk
		snapshot("contact_journal_overview_high_risks_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}
	
	func test_screenshot_TwoPersonsOneLocationAndMessages() throws {
		var screenshotCounter = 0
		// setting up launch arguments
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.infoScreen.diaryInfoScreenShown, YES])
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.risk.riskLevel, "high"])
		
		// navigate to desired screen
		navigateToJournalOverview()
		
		// select first cell
		app.cells.element(boundBy: 1).waitAndTap()
		
		// add a person
		addPersonToDayEntry("Andrea")
		
		// switch to places
		app.segmentedControls.firstMatch.buttons[app.localized("ContactDiary_Day_LocationsSegment")].waitAndTap()
		
		// add a location
		addLocationToDayEntry("Physiotherapie")
		
		// go back
		app.navigationBars.firstMatch.buttons.element(boundBy: 0).waitAndTap()
		
		// select fourth cell
		app.cells.element(boundBy: 4).waitAndTap()
		
		// add a person
		addPersonToDayEntry("Michael")
		
		// go back
		app.navigationBars.firstMatch.buttons.element(boundBy: 0).waitAndTap()
		
		app.swipeDown()
		// take screenshot
		snapshot("contact_journal_listing1_\(String(format: "%04d", (screenshotCounter.inc() )))")
		
		app.swipeUp()
		// take screenshot
		snapshot("contact_journal_listing1_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}

	func test_screenshot_AddTwoPersonsAndOneLocationToDate() throws {
		var screenshotCounter = 0
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.infoScreen.diaryInfoScreenShown, YES])
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.risk.riskLevel, "high"])

		navigateToJournalOverview()

		// check count for overview: day cell 15 days plus 1 description cell
		XCTAssertEqual(app.descendants(matching: .table).firstMatch.cells.count, 15 + 1)

		// select 3th cell
		app.descendants(matching: .table).firstMatch.cells.element(boundBy: 3).waitAndTap()

		let dayTableView = app.tables[AccessibilityIdentifiers.ContactDiary.dayTableView]

		// check count for day entries: 1 add entry cell
		XCTAssertEqual(dayTableView.cells.count, 1)

		addPersonToDayEntry("Max Mustermann")
		addPersonToDayEntry("Erika Musterfrau")

		// check count for day entries: 1 add entry cell + 2 persons added
		XCTAssertEqual(dayTableView.cells.count, 3)

		// deselect Erika Musterfrau - 1 because new persons get entered on top
		// dayTableView.cells.firstMatch element(boundBy: 1).staticTexts["Erika Musterfrau"].waitAndTap()

		XCTAssertTrue(app.segmentedControls.firstMatch.waitForExistence(timeout: .medium))
		app.segmentedControls.firstMatch.buttons[app.localized("ContactDiary_Day_LocationsSegment")].waitAndTap()

		// check count for day entries: 1 add entry cell
		XCTAssertEqual(dayTableView.cells.count, 1)

		addLocationToDayEntry("Bäckerei")

		// check count for day entries: 1 add entry cell + 1 location added
		XCTAssertEqual(dayTableView.cells.count, 2)

		app.navigationBars.firstMatch.buttons.element(boundBy: 0).waitAndTap()
		snapshot("contact_journal_listing2_\(String(format: "%04d", (screenshotCounter.inc() )))")

		// check count for overview: day cell 15 days plus 1 description cell
		XCTAssertEqual(app.descendants(matching: .table).firstMatch.cells.count, 15 + 1)

		XCTAssertTrue(app.descendants(matching: .table).firstMatch.cells.element(boundBy: 3).waitForExistence(timeout: .medium))
		let dayCell = app.descendants(matching: .table).firstMatch.cells.element(boundBy: 3)

		XCTAssertTrue(dayCell.staticTexts["Max Mustermann"].exists)
		XCTAssertTrue(dayCell.staticTexts["Bäckerei"].exists)
		// XCTAssertFalse(dayCell.staticTexts["Erika Musterfrau"].exists)
	}

	func test_screenshot_ContactJournalInformation() throws {
		var screenshotCounter = 0
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.infoScreen.traceLocationsInfoScreenShown, NO])

		// navigate to desired screen
		navigateToJournalOverview()

		// take screenshot
		snapshot("contact_journal_information_screen_\(String(format: "%04d", (screenshotCounter.inc() )))")

		// Check whether we have entered the info screen.
		XCTAssertTrue(app.images["AppStrings.ContactDiaryInformation.imageDescription"].waitForExistence(timeout: .medium))

		app.swipeUp(velocity: .fast)
		// take screenshot
		snapshot("contact_journal_information_screen_\(String(format: "%04d", (screenshotCounter.inc() )))")

		app.swipeUp(velocity: .fast)
		// take screenshot
		snapshot("contact_journal_information_screen_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}

	func test_screenshot_AddTwoPersonsTwoLocations() throws {
		// setting up launch arguments
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.infoScreen.diaryInfoScreenShown, YES])
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.risk.riskLevel, "high"])

		// navigate to desired screen
		navigateToJournalOverview()

		// select first cell
		app.cells.element(boundBy: 1).waitAndTap()

		// add persons
		addPersonToDayEntry("Erika Musterfrau")
		addPersonToDayEntry("Max Mustermann")
		// take screenshot
		snapshot("contact_journal_listing_add_persons")

		// switch to places
		app.segmentedControls.firstMatch.buttons[app.localized("ContactDiary_Day_LocationsSegment")].waitAndTap()

		// add locations
		addLocationToDayEntry("Sportzentrum")
		addLocationToDayEntry("Büro")
		// take screenshot
		snapshot("contact_journal_listing_add_locations")

		// go back
		app.navigationBars.firstMatch.buttons.element(boundBy: 0).waitAndTap()
	}

	func test_screenshot_EditPersonScreen() throws {
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.infoScreen.diaryInfoScreenShown, YES])

		// open sheet to edit persons
		openEditPersonViaSheet()

		// take screenshot
		snapshot("contact_journal_listing_edit_persons")
	}

	func test_screenshot_EditLocationScreen() throws {
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.infoScreen.diaryInfoScreenShown, YES])

		// open sheet to edit locations
		openEditLocationsViaSheet()

		// take screenshot
		snapshot("contact_journal_listing_edit_locations")
	}
	
	// MARK: - Private

	private func navigateToJournalOverview() {
		launch()
		app.buttons[AccessibilityIdentifiers.Tabbar.diary].waitAndTap()
	}

	private func addPersonToDayEntry(_ personName: String, phoneNumber: String = "", eMail: String = "") {
		app.descendants(matching: .table).firstMatch.cells.firstMatch.waitAndTap()
		XCTAssertEqual(app.navigationBars.element(boundBy: 0).identifier, app.localized("ContactDiary_AddEditEntry_PersonTitle"))

		let table = app.tables.firstMatch
		
		table.cells.textFields[AccessibilityIdentifiers.ContactDiaryInformation.EditEntries.nameTextField].waitAndTap()
		table.cells.textFields[AccessibilityIdentifiers.ContactDiaryInformation.EditEntries.nameTextField].typeText(personName)
		table.cells.textFields[AccessibilityIdentifiers.ContactDiaryInformation.EditEntries.phoneNumberTextField].waitAndTap()
		table.cells.textFields[AccessibilityIdentifiers.ContactDiaryInformation.EditEntries.phoneNumberTextField].typeText(phoneNumber)
		table.cells.textFields[AccessibilityIdentifiers.ContactDiaryInformation.EditEntries.eMailTextField].waitAndTap()
		table.cells.textFields[AccessibilityIdentifiers.ContactDiaryInformation.EditEntries.eMailTextField].typeText(eMail)

		app.buttons[app.localized("ContactDiary_AddEditEntry_PrimaryButton_Title")].waitAndTap()
	}

	private func addLocationToDayEntry(_ locationName: String, phoneNumber: String = "", eMail: String = "") {
		let addCell = app.descendants(matching: .table).firstMatch.cells.firstMatch
		addCell.waitAndTap()

		XCTAssertEqual(app.navigationBars.element(boundBy: 0).identifier, app.localized("ContactDiary_AddEditEntry_LocationTitle"))

		let table = app.tables.firstMatch

		XCTAssertTrue(table.cells.textFields[AccessibilityIdentifiers.ContactDiaryInformation.EditEntries.nameTextField].waitForExistence(timeout: .extraLong))

		table.cells.textFields[AccessibilityIdentifiers.ContactDiaryInformation.EditEntries.nameTextField].waitAndTap()
		table.cells.textFields[AccessibilityIdentifiers.ContactDiaryInformation.EditEntries.nameTextField].typeText(locationName)
		table.cells.textFields[AccessibilityIdentifiers.ContactDiaryInformation.EditEntries.phoneNumberTextField].waitAndTap()
		table.cells.textFields[AccessibilityIdentifiers.ContactDiaryInformation.EditEntries.phoneNumberTextField].typeText(phoneNumber)
		table.cells.textFields[AccessibilityIdentifiers.ContactDiaryInformation.EditEntries.eMailTextField].waitAndTap()
		table.cells.textFields[AccessibilityIdentifiers.ContactDiaryInformation.EditEntries.eMailTextField].typeText(eMail)

		app.buttons[app.localized("ContactDiary_AddEditEntry_PrimaryButton_Title")].waitAndTap()
	}

	private func prepareDataInOverview() {
		navigateToJournalOverview()

		// select 3rd cell
		app.descendants(matching: .table).firstMatch.cells.element(boundBy: 3).waitAndTap()

		addPersonToDayEntry("Max Mustermann")
		addPersonToDayEntry("Erika Musterfrau")
		app.segmentedControls.firstMatch.buttons[app.localized("ContactDiary_Day_LocationsSegment")].waitAndTap()
		addLocationToDayEntry("Bäckerei")
		addLocationToDayEntry("Supermarkt")

		app.navigationBars.firstMatch.buttons.element(boundBy: 0).waitAndTap()
	}

	private func openInformationSheet() {
		prepareDataInOverview()

		app.navigationBars.firstMatch.buttons.element(boundBy: 0).waitAndTap()

		XCTAssertTrue(app.sheets.firstMatch.waitForExistence(timeout: .medium))
	}

	private func openEditPersonViaSheet() {
		openInformationSheet()

		app.sheets.firstMatch.buttons.element(boundBy: 2).waitAndTap()
	}

	private func openEditLocationsViaSheet() {
		openInformationSheet()

		app.sheets.firstMatch.buttons.element(boundBy: 3).waitAndTap()
	}

	private func launch() {
		app.launch()
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: .long))
	}

	/// we will search for the given identifier inside a scrollable element
	/// scroll and collect all visible elements until the collection doen't change
	private func search(_ identifier: String, element: XCUIElement) -> XCUIElement? {
		var allElementsFound = false
		var lastLoopSeenElements: [String] = []
		var retryCount = 0

		while !allElementsFound, retryCount < 10 /* max retries is arbitrary but required to prevent infinite loops */ {
			/** search for a possible button */
			guard !element.buttons[identifier].exists else {
				return element.buttons[identifier]
			}

			/** search for a possible cell */
			guard !element.cells[identifier].exists else {
				return element.cells[identifier]
			}

			let allElements = element.cells.allElementsBoundByIndex.map { $0.identifier } + element.buttons.allElementsBoundByIndex.map { $0.identifier }
			allElementsFound = allElements == lastLoopSeenElements
			lastLoopSeenElements = allElements

			app.swipeUp()
			retryCount += 1
		}
		return nil
	}
	// swiftlint:disable:next file_length
}
