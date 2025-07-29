import UIKit

//@IBDesignable
class NibView: UIView {
	
	static var nibCache: [String: UINib] = [:]
	
	var view: UIView!
	
	var initSetupTriggered: Bool = false;
	
	init(fromCodeWithFrame frame: CGRect) {
		super.init(frame: frame)
		checkViewFromNib()
		initSetupIfNeeded()
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		checkViewFromNib()
#if TARGET_INTERFACE_BUILDER
		initSetupIfNeeded()
#endif
	}
	
	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		initSetupIfNeeded()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		checkViewFromNib()
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		initSetupIfNeeded()
	}
	
	func initSetupIfNeeded () {
		if !initSetupTriggered { initSetup() }
	}
	
	func initSetup () {
		initSetupTriggered = true
	}
	
	private func checkViewFromNib() {
		
		if let viewFromNib: UIView = loadViewFromNib() {
			backgroundColor = .clear
			
			viewFromNib.translatesAutoresizingMaskIntoConstraints = false
			
			insertSubview(viewFromNib, at: 0)
			
			viewFromNib.topAnchor.constraint(equalTo: topAnchor).isActive = true
			viewFromNib.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
			viewFromNib.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
			viewFromNib.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
			
			view = viewFromNib
		} else {
			//            view = self
		}
	}
	
	private func loadViewFromNib() -> UIView? {
		let nibName: String = String(describing: type(of: self))
		
		var nib: UINib? = NibView.nibCache[nibName]
		
		if nib == nil {
			nib = UINib(nibName: nibName, bundle: Bundle.main)
			NibView.nibCache[nibName] = nib
		}
		
		let view = nib!.instantiate(withOwner: self, options: nil).first as? UIView
		
		return view
	}
	
}
