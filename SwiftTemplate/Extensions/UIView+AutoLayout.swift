//
//  UIView+AutoLayout.swift
//  Orovera
//
//  Created by Dmitry Onishchuk on 19.10.2021.
//

import UIKit

public struct ConstraintPriorities {
    
    static public let required: ConstraintPriorities = ConstraintPriorities(top: 1000, left: 1000, bottom: 1000, right: 1000)
    
    let top: Float
    let left: Float
    let bottom: Float
    let right: Float
    
    public init(top: Float, left: Float, bottom: Float, right: Float) {
        self.top = top
        self.left = left
        self.bottom = bottom
        self.right = right
    }
    
}

public extension UIView {
    
    func fillSuperview() {
        anchor(top: superview?.topAnchor,
               leading: superview?.leadingAnchor,
               bottom: superview?.bottomAnchor,
               trailing: superview?.trailingAnchor)
    }
    
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                leading: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                trailing: NSLayoutXAxisAnchor? = nil,
                centerX: NSLayoutXAxisAnchor? = nil,
                centerY: NSLayoutYAxisAnchor? = nil,
                padding: UIEdgeInsets = .zero,
                paddingPriority: ConstraintPriorities = .required,
                size: CGSize = .zero) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            let topConstraint = topAnchor.constraint(equalTo: top, constant: padding.top)
            topConstraint.priority = UILayoutPriority(paddingPriority.top)
            topConstraint.isActive = true
        }
        
        if let leading = leading {
            let leadingConstraint = leadingAnchor.constraint(equalTo: leading, constant: padding.left)
            leadingConstraint.priority = UILayoutPriority(paddingPriority.left)
            leadingConstraint.isActive = true
        }
        
        if let bottom = bottom {
            let bottomConstraint = bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom)
            bottomConstraint.priority = UILayoutPriority(paddingPriority.bottom)
            bottomConstraint.isActive = true
        }
        
        if let trailing = trailing {
            let trailingConstraint = trailingAnchor.constraint(equalTo: trailing, constant: -padding.right)
            trailingConstraint.priority = UILayoutPriority(paddingPriority.right)
            trailingConstraint.isActive = true
        }
        
        if let centerX = centerX {
            centerXAnchor.constraint(equalTo: centerX).isActive = true
        }
        
        if let centerY = centerY {
            centerYAnchor.constraint(equalTo: centerY).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
        
    }
    
}
