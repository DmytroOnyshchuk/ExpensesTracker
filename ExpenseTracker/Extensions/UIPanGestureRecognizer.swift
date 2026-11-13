//
//  UIPanGestureRecognizer.swift
//  Orovera
//
//  Created by Dmytro Onyshchuk on 08.12.2022.
//  Copyright © 2022 PeaksCircle. All rights reserved.
//

import Foundation
import UIKit

public enum UIPanGestureRecognizerDirection {
    case undefined
    case bottomToTop
    case topToBottom
    case rightToLeft
    case leftToRight
}

public enum TransitionOrientation {
    case unknown
    case topToBottom
    case bottomToTop
    case leftToRight
    case rightToLeft
}

extension UIPanGestureRecognizer {
    public var direction: UIPanGestureRecognizerDirection {
        let velocity = velocity(in: view)
        let isVertical: Bool = abs(velocity.y) > abs(velocity.x)

        let direction: UIPanGestureRecognizerDirection = if isVertical {
            velocity.y > 0 ? .topToBottom : .bottomToTop
        } else {
            velocity.x > 0 ? .leftToRight : .rightToLeft
        }

        return direction
    }

    public func isQuickSwipe(for orientation: TransitionOrientation) -> Bool {
        let velocity = velocity(in: view)
        return isQuickSwipeForVelocity(velocity, for: orientation)
    }

    private func isQuickSwipeForVelocity(_ velocity: CGPoint, for orientation: TransitionOrientation) -> Bool {
        switch orientation {
        case .unknown: false
        case .topToBottom: velocity.y > 1000
        case .bottomToTop: velocity.y < -1000
        case .leftToRight: velocity.x > 1000
        case .rightToLeft: velocity.x < -1000
        }
    }
}

extension UIPanGestureRecognizer {
    typealias GestureHandlingTuple = (gesture: UIPanGestureRecognizer?, handle: (UIPanGestureRecognizer) -> Void)

    fileprivate static var handlers = [GestureHandlingTuple]()

    public convenience init(gestureHandle: @escaping (UIPanGestureRecognizer) -> Void) {
        self.init()
        UIPanGestureRecognizer.cleanup()
        set(gestureHandle: gestureHandle)
    }

    public func set(gestureHandle: @escaping (UIPanGestureRecognizer) -> Void) {
        weak let weakSelf = self
        let tuple = (weakSelf, gestureHandle)
        UIPanGestureRecognizer.handlers.append(tuple)
        addTarget(self, action: #selector(handleGesture))
    }

    fileprivate static func cleanup() {
        handlers = handlers.filter { $0.0?.view != nil }
    }

    @objc private func handleGesture(_ gesture: UIPanGestureRecognizer) {
        let handleTuples = UIPanGestureRecognizer.handlers.filter { $0.gesture === self }
        handleTuples.forEach { $0.handle(gesture) }
    }
}

extension UIPanGestureRecognizerDirection {
    public var orientation: TransitionOrientation {
        switch self {
        case .rightToLeft: .rightToLeft
        case .leftToRight: .leftToRight
        case .bottomToTop: .bottomToTop
        case .topToBottom: .topToBottom
        default: .unknown
        }
    }
}

extension UIPanGestureRecognizerDirection {
    public var isHorizontal: Bool {
        switch self {
        case .rightToLeft, .leftToRight:
            true
        default:
            false
        }
    }
}
