//
//  FadeTransition.swift
//  TransitionButton
//
//  Created by Alaeddine M. on 11/1/15.
//  Copyright (c) 2015 Alaeddine M. All rights reserved.
//

import UIKit

open class FadeTransition: NSObject, UIViewControllerAnimatedTransitioning {
    var transitionDuration: TimeInterval = 0.5
    var startingAlpha: CGFloat = .zero

    public convenience init(transitionDuration: TimeInterval, startingAlpha: CGFloat) {
        self.init()
        self.transitionDuration = transitionDuration
        self.startingAlpha = startingAlpha
    }

    open func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval {
        transitionDuration
    }

    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView

        let toView = transitionContext.view(forKey: .to)!
        let fromView = transitionContext.view(forKey: .from)!

        toView.alpha = startingAlpha
        fromView.alpha = 0.8

        toView.frame = containerView.frame
        containerView.addSubview(toView)

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { () in
            toView.alpha = 1.0
            fromView.alpha = .zero
        }, completion: { _ in
            fromView.alpha = 1.0
            transitionContext.completeTransition(true)
        })
    }
}
