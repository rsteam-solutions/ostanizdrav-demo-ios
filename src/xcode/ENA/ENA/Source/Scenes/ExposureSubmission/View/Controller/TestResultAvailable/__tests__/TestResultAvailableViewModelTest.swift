//
// 🦠 Corona-Warn-App
//

import XCTest
import Combine
@testable import ENA

class TestResultAvailableViewModelTest: XCTestCase {
	
	func testGIVEN_ViewModel_WHEN_PrimaryButtonClosureCalled_THEN_ExpectationFulfill() {
		// GIVEN
		let expectationFulFill = expectation(description: "primary button code execute")
		let expectationNotFulFill = expectation(description: "consent cell code excecute")
		expectationNotFulFill.isInverted = true
		
		let viewModel = TestResultAvailableViewModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			didTapConsentCell: { _ in
				expectationNotFulFill.fulfill()
			},
			didTapPrimaryFooterButton: { _ in
				expectationFulFill.fulfill()
			},
			presentDismissAlert: {}
		)
		
		// WHEN
		viewModel.didTapPrimaryFooterButton({ _ in })
		
		// THEN
		waitForExpectations(timeout: .medium)
	}
	
	func testGIVEN_ViewModel_WHEN_getDynamicTableViewModel_THEN_SectionsAndCellMatchExpectation() {
		// GIVEN
		let exposureSubmissionService = MockExposureSubmissionService()
		let expectationNotFulFill = expectation(description: "consent cell code excecute")
		expectationNotFulFill.isInverted = true
		var bindings: Set<AnyCancellable> = []

		let viewModel = TestResultAvailableViewModel(
			exposureSubmissionService: exposureSubmissionService,
			didTapConsentCell: { _ in
				expectationNotFulFill.fulfill()
			},
			didTapPrimaryFooterButton: { _ in
				expectationNotFulFill.fulfill()
			},
			presentDismissAlert: {}
		)
		
		// WHEN
		var resultDynamicTableViewModel: DynamicTableViewModel?
		
		viewModel.$dynamicTableViewModel.sink { dynamicTableViewModel in
			resultDynamicTableViewModel = dynamicTableViewModel
		}.store(in: &bindings)

		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertEqual(3, resultDynamicTableViewModel?.numberOfSection)
		XCTAssertEqual(0, resultDynamicTableViewModel?.numberOfRows(section: 0))
		XCTAssertEqual(1, resultDynamicTableViewModel?.numberOfRows(section: 1))
		XCTAssertEqual(2, resultDynamicTableViewModel?.numberOfRows(section: 2))
	}
	
	func testGIVEN_ViewModel_WHEN_GetIconCellActionTigger_THEN_ExpectationFulfill() {
		// GIVEN
		let exposureSubmissionService = MockExposureSubmissionService()
		let expectationFulFill = expectation(description: "primary button code execute")
		let expectationNotFulFill = expectation(description: "consent cell code excecute")
		expectationNotFulFill.isInverted = true
		var bindings: Set<AnyCancellable> = []

		let viewModel = TestResultAvailableViewModel(
			exposureSubmissionService: exposureSubmissionService,
			didTapConsentCell: { _ in
				expectationFulFill.fulfill()
			},
			didTapPrimaryFooterButton: { _ in
				expectationNotFulFill.fulfill()
			},
			presentDismissAlert: {}
		)
		
		var resultDynamicTableViewModel: DynamicTableViewModel?
		let waitForCombineExpectation = expectation(description: "dynamic tableview mode did load")
		viewModel.$dynamicTableViewModel.sink { dynamicTableViewModel in
			resultDynamicTableViewModel = dynamicTableViewModel
			waitForCombineExpectation.fulfill()
		}.store(in: &bindings)
	
		wait(for: [waitForCombineExpectation], timeout: .medium)
		let iconCell = resultDynamicTableViewModel?.cell(at: IndexPath(row: 0, section: 1))
		
		// WHEN
		switch iconCell?.action {
		case .execute(block: let block):
			block( UIViewController(), nil )
		default:
			XCTFail("unknown action type")
		}
		
		// THEN
		wait(for: [expectationFulFill, expectationNotFulFill], timeout: .medium)
	}
}
