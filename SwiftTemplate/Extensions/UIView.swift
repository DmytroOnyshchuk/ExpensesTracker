import Foundation
import UIKit

protocol Make {}

extension Make where Self: UIView {
	
	@discardableResult
	func make(_ completion: (Self) -> Void) -> Self {
		completion(self)
		return self
	}
	
}

extension UIView: Make {}

extension UIView {
    @discardableResult
    func fromNib<T : UIView>() -> T? {
        guard let view = Bundle.main.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as? T else {
            return nil
        }
        
        self.addSubview(view)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        return view
    }
    
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    func addTapGestureRecognizer(target: Any?, action: Selector?, numberOfTapsRequired: Int = 1) {
        isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: target, action: action)
        tapGesture.numberOfTapsRequired = numberOfTapsRequired
        addGestureRecognizer(tapGesture)
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: 0))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
    
    @discardableResult
    func addBorders(edges: UIRectEdge,
                    color: UIColor,
                    inset: CGFloat = 0.0,
                    thickness: CGFloat = 1.0) -> [UIView] {
        
        var borders = [UIView]()
        
        @discardableResult
        func addBorder(formats: String...) -> UIView {
            let border = UIView(frame: .zero)
            border.backgroundColor = color
            border.translatesAutoresizingMaskIntoConstraints = false
            addSubview(border)
            addConstraints(formats.flatMap {
                NSLayoutConstraint.constraints(withVisualFormat: $0,
                                               options: [],
                                               metrics: ["inset": inset, "thickness": thickness],
                                               views: ["border": border]) })
            borders.append(border)
            return border
        }
        
        
        if edges.contains(.top) || edges.contains(.all) {
            addBorder(formats: "V:|-0-[border(==thickness)]", "H:|-inset-[border]-inset-|")
        }
        
        if edges.contains(.bottom) || edges.contains(.all) {
            addBorder(formats: "V:[border(==thickness)]-0-|", "H:|-inset-[border]-inset-|")
        }
        
        if edges.contains(.left) || edges.contains(.all) {
            addBorder(formats: "V:|-inset-[border]-inset-|", "H:|-0-[border(==thickness)]")
        }
        
        if edges.contains(.right) || edges.contains(.all) {
            addBorder(formats: "V:|-inset-[border]-inset-|", "H:[border(==thickness)]-0-|")
        }
        
        return borders
    }
    
    func roundCorners(radius: CGFloat = 10, corners: UIRectCorner = .allCorners) {
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        var arr: CACornerMask = []
        
        let allCorners: [UIRectCorner] = [.topLeft, .topRight, .bottomLeft, .bottomRight, .allCorners]
        
        for corn in allCorners {
            if(corners.contains(corn)){
                switch corn {
                    case .topLeft:
                        arr.insert(.layerMinXMinYCorner)
                    case .topRight:
                        arr.insert(.layerMaxXMinYCorner)
                    case .bottomLeft:
                        arr.insert(.layerMinXMaxYCorner)
                    case .bottomRight:
                        arr.insert(.layerMaxXMaxYCorner)
                    case .allCorners:
                        arr.insert(.layerMinXMinYCorner)
                        arr.insert(.layerMaxXMinYCorner)
                        arr.insert(.layerMinXMaxYCorner)
                        arr.insert(.layerMaxXMaxYCorner)
                    default: break
                }
            }
        }
        self.layer.maskedCorners = arr
        
    }
    
    private func roundCornersBezierPath(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func addShadowAndRoundCorners(){
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = false
        self.layer.shadowOpacity = 0.02
        self.layer.shadowRadius = 7
        self.layer.shadowOffset.height = 7
        self.layer.shadowColor = UIColor.black.cgColor
    }
    
	class func getAllSubviews<T: UIView>(from parenView: UIView) -> [T] {
		return parenView.subviews.flatMap { subView -> [T] in
			var result = getAllSubviews(from: subView) as [T]
			if let view = subView as? T { result.append(view) }
			return result
		}
	}
	
	class func getAllSubviews(from parenView: UIView, types: [UIView.Type]) -> [UIView] {
		return parenView.subviews.flatMap { subView -> [UIView] in
			var result = getAllSubviews(from: subView) as [UIView]
			for type in types {
				if subView.classForCoder == type {
					result.append(subView)
					return result
				}
			}
			return result
		}
	}
	
	func getAllSubviews<T: UIView>() -> [T] { return UIView.getAllSubviews(from: self) as [T] }
	func get<T: UIView>(all type: T.Type) -> [T] { return UIView.getAllSubviews(from: self) as [T] }
	func get(all types: [UIView.Type]) -> [UIView] { return UIView.getAllSubviews(from: self, types: types) }
	
	func setRedBorder(){
		self.layer.borderWidth = 1
		self.layer.borderColor = UIColor.red.cgColor
	}
	
	func setGreenBorder(){
		self.layer.borderWidth = 1
		self.layer.borderColor = UIColor.green.cgColor
	}
	
	func setYellowBorder(){
		self.layer.borderWidth = 1
		self.layer.borderColor = UIColor.yellow.cgColor
	}
	
	func shadow(color: UIColor = UIColor.black,
				offset: CGSize = CGSize(width: 0, height: 1),
				opacity: Float = 0.2,
				radius: CGFloat = 2){
		self.layer.shadowRadius = radius
		self.layer.shadowColor = color.cgColor
		self.layer.shadowOffset = offset
		self.layer.shadowOpacity = opacity
	}
	
	func removeShadow() {
		self.layer.shadowColor = nil
		self.layer.shadowOffset = .zero
		self.layer.shadowOpacity = 0
		self.layer.shadowRadius = 0
	}
	
	func addInnerShadow(topColor: UIColor = UIColor.black.withAlphaComponent(0.3)) {
		let shadowLayer = CAGradientLayer()
		shadowLayer.cornerRadius = layer.cornerRadius
		shadowLayer.frame = bounds
		shadowLayer.frame.size.height = 6.0
		shadowLayer.colors = [
			topColor.cgColor,
			self.backgroundColor?.cgColor ?? UIColor.white.withAlphaComponent(0).cgColor
		]
		shadowLayer.name = "innershadow"
		
		self.layer.sublayers?.filter {
			$0.name == shadowLayer.name
		}.forEach {
			$0.removeFromSuperlayer()
		}
		
		layer.addSublayer(shadowLayer)
	}
	
	func linearGradientBackgroundBorder(angleInDegs: Int, colors: [CGColor], locations: [NSNumber]? = nil, radius: CGFloat = 0, width: CGFloat = 2) {
		
		self.layer.cornerRadius = radius
		
		let gradientBaseLayer: CAGradientLayer = CAGradientLayer()
		gradientBaseLayer.frame = self.bounds
		gradientBaseLayer.colors = colors
		gradientBaseLayer.cornerRadius = radius
		gradientBaseLayer.locations = locations
		gradientBaseLayer.startPoint = startAndEndPointsFrom(angle: angleInDegs).startPoint
		gradientBaseLayer.endPoint = startAndEndPointsFrom(angle: angleInDegs).endPoint
		gradientBaseLayer.name = "borderGradient"
		
		self.layer.sublayers?.filter {
			$0.name == gradientBaseLayer.name
		}.forEach {
			$0.removeFromSuperlayer()
		}
		
		let shape = CAShapeLayer()
		shape.lineWidth = width
		shape.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
		shape.strokeColor = UIColor.black.cgColor
		shape.fillColor = UIColor.clear.cgColor
		gradientBaseLayer.mask = shape
		
		self.layer.insertSublayer(gradientBaseLayer, at: 0)
	}
	
	func removeLinearGradientBackground() {
		layer.sublayers?.filter {
			$0.name == "gradient"
		}.forEach {
			$0.removeFromSuperlayer()
		}
	}
	
	func linearGradientBackground(angleInDegs: Int, colors: [CGColor], locations: [NSNumber]? = nil, radius: CGFloat = 0) {
		let gradientBaseLayer: CAGradientLayer = CAGradientLayer()
		gradientBaseLayer.frame = self.bounds
		gradientBaseLayer.colors = colors
		gradientBaseLayer.cornerRadius = radius
		gradientBaseLayer.locations = locations
		gradientBaseLayer.startPoint = startAndEndPointsFrom(angle: angleInDegs).startPoint
		gradientBaseLayer.endPoint = startAndEndPointsFrom(angle: angleInDegs).endPoint
		gradientBaseLayer.name = "gradient"
		
		removeLinearGradientBackground()
		
		layer.insertSublayer(gradientBaseLayer, at: 0)
	}
	
	func changeAnimationGradientBackground(newColors: [CGColor], duration: CFTimeInterval = 0.5, animationDelegate: CAAnimationDelegate? = nil) {
		
		var currentGradientLayer: CAGradientLayer!
		
		layer.sublayers?.filter {
			$0.name == "gradient"
		}.forEach {
			currentGradientLayer = $0 as? CAGradientLayer
		}
		if currentGradientLayer == nil { return }
		
		//currentGradientLayer.removeAllAnimations()
		
		let colorsAnimation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.colors))
		colorsAnimation.fromValue = currentGradientLayer.colors
		colorsAnimation.toValue = newColors
		colorsAnimation.duration = duration
		colorsAnimation.delegate = animationDelegate
		colorsAnimation.fillMode = .forwards
		colorsAnimation.isRemovedOnCompletion = false
		currentGradientLayer.add(colorsAnimation, forKey: "colorsAnimation")
	}
	
	func startAndEndPointsFrom(angle: Int) -> (startPoint:CGPoint, endPoint:CGPoint) {
		var startPointX:CGFloat = 0.5
		var startPointY:CGFloat = 1.0
		
		var startPoint:CGPoint
		var endPoint:CGPoint
		
		switch true {
			case angle == 0:
				startPointX = 0.5
				startPointY = 1.0
			case angle == 45:
				startPointX = 0.0
				startPointY = 1.0
			case angle == 90:
				startPointX = 0.0
				startPointY = 0.5
			case angle == 135:
				startPointX = 0.0
				startPointY = 0.0
			case angle == 180:
				startPointX = 0.5
				startPointY = 0.0
			case angle == 225:
				startPointX = 1.0
				startPointY = 0.0
			case angle == 270:
				startPointX = 1.0
				startPointY = 0.5
			case angle == 315:
				startPointX = 1.0
				startPointY = 1.0
				
			case angle > 315 || angle < 45:
				startPointX = 0.5 - CGFloat(tan(angle.degreesToRads()) * 0.5)
				startPointY = 1.0
			case angle > 45 && angle < 135:
				startPointX = 0.0
				startPointY = 0.5 + CGFloat(tan(90.degreesToRads() - angle.degreesToRads()) * 0.5)
			case angle > 135 && angle < 225:
				startPointX = 0.5 - CGFloat(tan(180.degreesToRads() - angle.degreesToRads()) * 0.5)
				startPointY = 0.0
			case angle > 225 && angle < 359:
				startPointX = 1.0
				startPointY = 0.5 - CGFloat(tan(270.degreesToRads() - angle.degreesToRads()) * 0.5)
			default: break
		}
		
		startPoint = CGPoint(x: startPointX, y: startPointY)
		endPoint = startPoint.opposite()
		return (startPoint, endPoint)
	}
	
	func fadeTo(_ alpha: CGFloat, duration: TimeInterval = 0.1, async: Bool = false, isHiddenFlagUse: Bool = false, complete: ((_ finish: Bool) -> Void)? = nil) {
		if async {
			DispatchQueue.main.async {
				UIView.animate(withDuration: duration, animations: {
					self.alpha = alpha
					if isHiddenFlagUse, alpha == 0 {
						self.isHidden = true
					} else if isHiddenFlagUse, alpha == 1 {
						self.isHidden = false
					}
				}, completion: complete)
			}
		}else{
			UIView.animate(withDuration: duration, animations: {
				self.alpha = alpha
				if isHiddenFlagUse, alpha == 0 {
					self.isHidden = true
				} else if isHiddenFlagUse, alpha == 1 {
					self.isHidden = false
				}
			}, completion: complete)
		}
	}
	
	func fadeIn(_ duration: TimeInterval = 0.1, async: Bool = false, isHiddenFlagUse: Bool = false, complete: ((_ finish: Bool) -> Void)? = nil) {
		fadeTo(1.0, duration: duration, async: async, isHiddenFlagUse: isHiddenFlagUse, complete: complete)
	}
	
	func fadeOut(_ duration: TimeInterval = 0.1, async: Bool = false, isHiddenFlagUse: Bool = false, complete: ((_ finish: Bool) -> Void)? = nil) {
		fadeTo(0.0, duration: duration, async: async, isHiddenFlagUse: isHiddenFlagUse, complete: complete)
	}
	
	@discardableResult
	func disableTranslatesAutoresizingMaskIntoConstraints() -> Self {
		translatesAutoresizingMaskIntoConstraints = false
		return self
	}
	
	func rotateView(duration: TimeInterval = 0.25, infinity: Bool = false, double: Bool = false) {
		UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
			self.transform = self.transform.rotated(by: .pi)
		}) { [weak self] finished in
			if infinity {
				self?.rotateView(duration: duration)
			}else if double {
				self?.rotateView(duration: duration, infinity: infinity, double: false) 
			}
		}
	}
	
}

final class MyTapGestureRecognizer: UITapGestureRecognizer {
	var myAction: (() -> Void)? = nil
	
	deinit {
		myAction = nil
	}
}

extension UIView {
	
	func addTapGesture(cancelsTouchesInView: Bool = true, action: @escaping () -> Void) {
		
		lazy var tap = MyTapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
		tap.myAction = action
		tap.numberOfTapsRequired = 1
		tap.cancelsTouchesInView = cancelsTouchesInView
		
		addGestureRecognizer(tap)
		isUserInteractionEnabled = true
		
	}
	
	@objc func handleTap(_ sender: MyTapGestureRecognizer) {
		sender.myAction?()
	}
	
}
