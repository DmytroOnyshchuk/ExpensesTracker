import Combine
import UIKit

extension UITextField {
    @IBInspectable var placeholderColor: UIColor {
        get {
            attributedPlaceholder?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor ?? .clear
        }
        set {
            guard let attributedPlaceholder else { return }
            let attributes: [NSAttributedString.Key: UIColor] = [.foregroundColor: newValue]
            self.attributedPlaceholder = NSAttributedString(string: attributedPlaceholder.string, attributes: attributes)
        }
    }

    enum PaddingSpace {
        case left(CGFloat)
        case right(CGFloat)
        case equalSpacing(CGFloat)
    }

    func addPadding(padding: PaddingSpace) {
        leftViewMode = .always
        layer.masksToBounds = true

        switch padding {
        case let .left(spacing):
            let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: frame.height))
            leftView = leftPaddingView
            leftViewMode = .always

        case let .right(spacing):
            let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: frame.height))
            rightView = rightPaddingView
            rightViewMode = .always

        case let .equalSpacing(spacing):
            let equalPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: frame.height))
            // left
            leftView = equalPaddingView
            leftViewMode = .always
            // right
            rightView = equalPaddingView
            rightViewMode = .always
        }
    }
}

// MARK: - UITextField Extension for Combine

extension UITextField {
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: self)
            .map { ($0.object as? UITextField)?.text ?? "" }
            .eraseToAnyPublisher()
    }
}
