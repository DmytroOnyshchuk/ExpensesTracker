//
//  UILabel.swift
//  Orovera
//
//  Created by Dmytro Onyshchuk on 24.07.2024.
//  Copyright © 2024 PeaksCircle. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    func strikeThrough(_ isStrikeThrough: Bool = true) {
        guard let text else { return }

        if isStrikeThrough {
            let attributeString = NSMutableAttributedString(string: text)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, attributeString.length))
            attributedText = attributeString
        } else {
            let attributeString = NSMutableAttributedString(string: text)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: [], range: NSMakeRange(0, attributeString.length))
            attributedText = attributeString
        }
    }

    @IBInspectable var adjustsFontSizeFitWidth: Bool {
        set(value) {
            adjustsFontSizeToFitWidth = value
        }
        get {
            adjustsFontSizeToFitWidth
        }
    }

    @IBInspectable var fontSize: CGFloat {
        get {
            font.pointSize
        }
        set {
            font = font.withSize(newValue)
        }
    }

    func setTextAnimate(text: String?, duration: TimeInterval = 0.25, options: UIView.AnimationOptions = .transitionCrossDissolve) {
        UIView.transition(with: self, duration: duration, options: options) {
            self.text = text
        }
    }
}
