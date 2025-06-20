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
        guard let text = self.text else {
            return
        }
        
        if isStrikeThrough {
            let attributeString =  NSMutableAttributedString(string: text)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0,attributeString.length))
            self.attributedText = attributeString
        } else {
            let attributeString =  NSMutableAttributedString(string: text)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: [], range: NSMakeRange(0,attributeString.length))
            self.attributedText = attributeString
        }
    }
    
    func adjustTextToFit(maxWidth: CGFloat, maxHeight: CGFloat, minFontSize: CGFloat) {
        guard let currentText = text else { return }
        
        let adjustedFontSize = font.pointSize * 0.8 // Reduce by 20%
        let originalFontFits = currentText.width(forHeight: maxHeight, font: font) <= maxWidth
        
        if originalFontFits {
            font = font.withSize(font.pointSize)
        } else if currentText.width(forHeight: maxHeight, font: font.withSize(adjustedFontSize)) <= maxWidth {
            font = font.withSize(adjustedFontSize)
        }else if currentText.width(forHeight: maxHeight, font: font.withSize(adjustedFontSize)) > maxWidth {
            font = font.withSize(adjustedFontSize)
        }
    }
    
    @IBInspectable var adjustsFontSizeFitWidth: Bool {
        set(value) {
            adjustsFontSizeToFitWidth = value
        }
        get {
            return adjustsFontSizeToFitWidth
        }
    }
    
    @IBInspectable var lineHeightMultipleValue: CGFloat {
        set(value) {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = textAlignment
            paragraphStyle.lineHeightMultiple = value
            attributedText = NSAttributedString(string: text ?? "", attributes: [
                .font: font,
                .paragraphStyle: paragraphStyle,
                .foregroundColor: textColor
            ])
            
            invalidateIntrinsicContentSize()
        }
        get {
            return self.lineHeightMultipleValue
        }
    }
    
    @IBInspectable var fontSize: CGFloat {
        get {
            return self.font.pointSize
        }
        set {
            self.font = self.font.withSize(newValue)
        }
    }
    
    
    func setTextAnimate(text: String?, duration: TimeInterval = 0.25, options: UIView.AnimationOptions = .transitionCrossDissolve) {
        UIView.transition(with: self, duration: duration, options: options) {
            self.text = text
        }
    }
    
}
