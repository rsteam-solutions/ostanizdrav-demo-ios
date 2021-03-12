////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

final class FooterViewModel {

	// MARK: - Init
	
	init(
		primaryButtonName: String? = nil,
		secondaryButtonName: String? = nil,
		isPrimaryButtonEnabled: Bool = true,
		isSecondaryButtonEnabled: Bool = true,
		isPrimaryButtonHidden: Bool = false,
		isSecondaryButtonHidden: Bool = false
	) {
		self.primaryButtonName = primaryButtonName
		self.secondaryButtonName = secondaryButtonName
		self.isPrimaryButtonEnabled = isPrimaryButtonEnabled
		self.isSecondaryButtonEnabled = isSecondaryButtonEnabled
		self.isPrimaryButtonHidden = isPrimaryButtonHidden
		self.isSecondaryButtonHidden = isSecondaryButtonHidden
		self.height = 0.0
	}

	// MARK: - Internal

	let buttonHeight: CGFloat = 50.0
	let spacer: CGFloat = 8.0
	let topBottomInset: CGFloat = 16.0
	let leftRightInset: CGFloat = 16.0

	@OpenCombine.Published private(set) var height: CGFloat = 0.0

	private(set) var isPrimaryButtonHidden: Bool
	private(set) var isSecondaryButtonHidden: Bool

	var primaryButtonName: String?
	var secondaryButtonName: String?

	var isPrimaryButtonEnabled: Bool
	var isSecondaryButtonEnabled: Bool

	func update( isPrimaryButtonHidden: Bool? = nil, isSecondaryButtonHidden: Bool? = nil) {
		self.isPrimaryButtonHidden = isPrimaryButtonHidden ?? self.isPrimaryButtonHidden
		self.isSecondaryButtonHidden = isSecondaryButtonHidden ?? self.isSecondaryButtonHidden
		updateHeight()
	}

	// MARK: - Private

	private func updateHeight() {
		let height: CGFloat
		switch (isPrimaryButtonHidden, isSecondaryButtonHidden) {
		case(false, false):
			height = buttonHeight * 2 + spacer + topBottomInset * 2
		case(true, false), (false, true):
			height = buttonHeight + spacer + topBottomInset * 2
		case(true, true):
			height = 0.0
		}
		self.height = height
	}

}
