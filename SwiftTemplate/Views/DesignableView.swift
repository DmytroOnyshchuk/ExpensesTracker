import UIKit

@IBDesignable final class DesignableView: UIView {
	
	@IBInspectable var borderColor: UIColor = .clear {
		didSet { setNeedsLayout() }
	}
	
	@IBInspectable var borderWidth: CGFloat = 0 {
		didSet { setNeedsLayout() }
	}
	
    @IBInspectable var roundCornerRadius: Bool = false {
        didSet { setNeedsLayout() }
    }
    
	@IBInspectable var cornerRadius: CGFloat = 0 {
		didSet { setNeedsLayout() }
	}
	
	@IBInspectable var shadowRadius: CGFloat = 0 {
		didSet { setNeedsLayout() }
	}
	
	@IBInspectable var shadowOpacity: CGFloat = 0 {
		didSet { setNeedsLayout() }
	}
	
	@IBInspectable var shadowOffset: CGSize = CGSize(width: 0, height: 0) {
		didSet { setNeedsLayout() }
	}
	
	@IBInspectable var shadowColor: UIColor = .black {
		didSet { setNeedsLayout() }
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		layer.shadowColor = shadowColor.cgColor
		layer.shadowRadius = shadowRadius
		layer.shadowOffset = shadowOffset
		layer.shadowOpacity = Float(shadowOpacity)
		
		layer.borderColor = borderColor.cgColor
		layer.borderWidth = borderWidth
		
		layer.cornerRadius = roundCornerRadius ? bounds.height / 2.0 : cornerRadius
	}
	
}

@IBDesignable class DesignableButton: UIButton {
	
	@IBInspectable var borderColor: UIColor = .clear {
		didSet { setNeedsLayout() }
	}
	
	@IBInspectable var borderWidth: CGFloat = 0 {
		didSet { setNeedsLayout() }
	}
	
	@IBInspectable var cornerRadius: CGFloat = 0 {
		didSet { setNeedsLayout() }
	}
	
    @IBInspectable var roundCornerRadius: Bool = false {
        didSet { setNeedsLayout() }
    }
    
	@IBInspectable var shadowRadius: CGFloat = 0 {
		didSet { setNeedsLayout() }
	}
	
	@IBInspectable var shadowOpacity: CGFloat = 0 {
		didSet { setNeedsLayout() }
	}
	
	@IBInspectable var shadowOffset: CGSize = CGSize(width: 0, height: 0) {
		didSet { setNeedsLayout() }
	}
	
	@IBInspectable var shadowColor: UIColor = .black {
		didSet { setNeedsLayout() }
	}
	
	@IBInspectable var areaExtension: CGFloat = 0
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		layer.shadowColor = shadowColor.cgColor
		layer.shadowRadius = shadowRadius
		layer.shadowOffset = shadowOffset
		layer.shadowOpacity = Float(shadowOpacity)
		
		layer.borderColor = borderColor.cgColor
		layer.borderWidth = borderWidth
		
		layer.cornerRadius = roundCornerRadius ? bounds.height / 2.0 : cornerRadius
	}
	
	override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
		let newArea = CGRect(x: bounds.origin.x - areaExtension, y: bounds.origin.y - areaExtension, width: bounds.size.width + areaExtension * 2, height: bounds.size.height + areaExtension * 2
		)
		return newArea.contains(point)
	}
	
	private lazy var activityIndicator: UIActivityIndicatorView = {
		let activityIndicator = UIActivityIndicatorView()
		activityIndicator.hidesWhenStopped = false
		activityIndicator.color = titleColor(for: .normal)
		activityIndicator.translatesAutoresizingMaskIntoConstraints = false
		return activityIndicator
	}()
	
	private func saveButtonContentHidden(_ isHidden: Bool) {
		titleLabel?.alpha = isHidden ? 0 : 1
		imageView?.alpha = isHidden ? 0 : 1
	}
	
	override var isUserInteractionEnabled: Bool {
		didSet { saveButtonContentHidden(!isUserInteractionEnabled) }
	}
	
	func startLoading() {
		if isUserInteractionEnabled { isUserInteractionEnabled = false }
		if activityIndicator.superview == nil {
			addSubview(activityIndicator)
			NSLayoutConstraint.activate([
				activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
				activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)
			])
		}
		if !activityIndicator.isAnimating { activityIndicator.startAnimating() }
	}
	
	func stopLoading() {
		activityIndicator.stopAnimating()
		activityIndicator.removeFromSuperview()
		isUserInteractionEnabled = true
	}
	
}

protocol DesignableTextFieldDelegate: AnyObject {
	func textFieldDidPressedDelete(_ textField: UITextField)
}

@IBDesignable class DesignableTextField: UITextField {
	
	@IBInspectable var borderColor: UIColor = .clear {
		didSet { setNeedsLayout() }
	}
	
	@IBInspectable var borderWidth: CGFloat = 0 {
		didSet { setNeedsLayout() }
	}
	
	@IBInspectable var cornerRadius: CGFloat = 0 {
		didSet { setNeedsLayout() }
	}
    
    @IBInspectable var roundCornerRadius: Bool = false {
        didSet { setNeedsLayout() }
    }
    
	@IBInspectable var shadowRadius: CGFloat = 0 {
		didSet { setNeedsLayout() }
	}
	
	@IBInspectable var shadowOpacity: CGFloat = 0 {
		didSet { setNeedsLayout() }
	}
	
	@IBInspectable var shadowOffset: CGSize = CGSize(width: 0, height: 0) {
		didSet { setNeedsLayout() }
	}
	
	@IBInspectable var shadowColor: UIColor = .black {
		didSet { setNeedsLayout() }
	}
	
	@IBInspectable var contentPadding: CGFloat = 0
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		layer.shadowColor = shadowColor.cgColor
		layer.shadowRadius = shadowRadius
		layer.shadowOffset = shadowOffset
		layer.shadowOpacity = Float(shadowOpacity)
		
		layer.borderColor = borderColor.cgColor
		layer.borderWidth = borderWidth
        layer.cornerRadius = roundCornerRadius ? bounds.height / 2.0 : cornerRadius
        
		//		layer.masksToBounds = cornerRadius > 0
	}
	
	override open func textRect(forBounds bounds: CGRect) -> CGRect {
		return bounds.inset(by: .init(top: 0, left: contentPadding, bottom: 0, right: contentPadding))
	}
	
	override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
		return bounds.inset(by: .init(top: 0, left: contentPadding, bottom: 0, right: contentPadding))
	}
	
	override open func editingRect(forBounds bounds: CGRect) -> CGRect {
		return bounds.inset(by: .init(top: 0, left: contentPadding, bottom: 0, right: contentPadding))
	}
	
	weak var designableDelegate: DesignableTextFieldDelegate?
	
	override func deleteBackward() {
		designableDelegate?.textFieldDidPressedDelete(self)
		super.deleteBackward()
	}
	
}

@IBDesignable final class DesignableLabel: UILabel {
	
	@IBInspectable var borderColor: UIColor = .clear {
		didSet { setNeedsLayout() }
	}
	
	@IBInspectable var borderWidth: CGFloat = 0 {
		didSet { setNeedsLayout() }
	}
	
	@IBInspectable var cornerRadius: CGFloat = 0 {
		didSet { setNeedsLayout() }
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		layer.borderColor = borderColor.cgColor
		layer.borderWidth = borderWidth
		layer.cornerRadius = cornerRadius
	}
	
}

@IBDesignable final class DesignableImageView: UIImageView {
	
	@IBInspectable var roundCornerRadius: Bool = false {
		didSet { setNeedsLayout() }
	}
	
	@IBInspectable var cornerRadius: CGFloat = 0 {
		didSet { setNeedsLayout() }
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		layer.cornerRadius = roundCornerRadius ? bounds.height / 2.0 : cornerRadius
	}
	
}
