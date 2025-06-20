import UIKit

extension UIButton {
	
	private static let allStates: [UIControl.State] = [.normal, .selected, .highlighted, .disabled]
	
	func setTitle(_ title: String?) {
		UIButton.allStates.forEach { setTitle(title, for: $0) }
	}
	
	func setTitleWithOutAnimation(title: String?) {
		UIView.setAnimationsEnabled(false)
		setTitle(title)
		layoutIfNeeded()
		UIView.setAnimationsEnabled(true)
	}
	
	
	func setTitleColor(_ color: UIColor?) {
		UIButton.allStates.forEach { setTitleColor(color, for: $0) }
	}
	
	func setImage(_ image: UIImage?) {
		UIButton.allStates.forEach { setImage(image, for: $0) }
	}
	
	func setButtonEnabled(_ enabled: Bool) {
		isEnabled = enabled
		backgroundColor = enabled ? backgroundColor?.withAlphaComponent(1) : backgroundColor?.withAlphaComponent(0.5)
	}
	
}
