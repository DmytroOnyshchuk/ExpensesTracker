//
//  LoadableViewProtocol.swift
//  Orovera
//
//  Created by Dmytro Onyshchuk on 23.06.2023.
//  Copyright © 2023 PeaksCircle. All rights reserved.
//

import SwiftUI
import UIKit

protocol LoadableViewProtocol where Self: UIView {
    func hideContent()
    func showContent()
}

extension LoadableViewProtocol {
    func startLoadingIndicator(_ align: Align = .center, indicatorColor: UIColor = UIColor(Color.appBlack), style: UIActivityIndicatorView.Style = .medium) {
        var newIndicator: UIActivityIndicatorView {
            let indicator = UIActivityIndicatorView()
            indicator.style = style
            indicator.color = indicatorColor
            indicator.hidesWhenStopped = false
            indicator.translatesAutoresizingMaskIntoConstraints = false
            return indicator
        }

        hideContent()
        let activityIndicatorView = UIView.Indicator.values[self] ?? newIndicator
        if activityIndicatorView.superview == nil {
            activityIndicatorView.addToSuperview(in: self, align: align)
        }
        activityIndicatorView.startAnimating()
    }

    func hideContent() {
        isUserInteractionEnabled = false
        alpha = 0
    }

    func stopLoadingIndicator() {
        UIView.Indicator.values[self]?.stopAnimating()
        UIView.Indicator.values[self]?.removeFromSuperview()
        UIView.Indicator.values.removeValue(forKey: self)
        showContent()
    }

    func showContent() {
        isUserInteractionEnabled = true
        alpha = 1
    }
}

enum Align {
    case center, centerLeft, centerRigth, centerTop, centerBottom
    case leftTop, leftBottom
    case rightTop, rightBottom
}

extension UIActivityIndicatorView {
    func addToSuperview(in view: UIView, align: Align = .center) {
        guard let superview = view.superview else { return }
        superview.addSubview(self)
        Indicator.values[view] = self
        switch align {
        case .center:
            NSLayoutConstraint.activate(
                [
                    centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    centerYAnchor.constraint(equalTo: view.centerYAnchor),
                ]
            )
        case .centerLeft:
            NSLayoutConstraint.activate(
                [
                    centerYAnchor.constraint(equalTo: view.centerYAnchor),
                    leadingAnchor.constraint(equalTo: view.leadingAnchor),
                ]
            )
        case .centerRigth:
            NSLayoutConstraint.activate(
                [
                    centerYAnchor.constraint(equalTo: view.centerYAnchor),
                    trailingAnchor.constraint(equalTo: view.trailingAnchor),
                ]
            )
        case .centerTop:
            NSLayoutConstraint.activate(
                [
                    centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    topAnchor.constraint(equalTo: view.topAnchor),
                ]
            )
        case .centerBottom:
            NSLayoutConstraint.activate(
                [
                    centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    bottomAnchor.constraint(equalTo: view.bottomAnchor),
                ]
            )
        case .leftTop:
            NSLayoutConstraint.activate(
                [
                    leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    topAnchor.constraint(equalTo: view.topAnchor),
                ]
            )
        case .leftBottom:
            NSLayoutConstraint.activate(
                [
                    leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    bottomAnchor.constraint(equalTo: view.bottomAnchor),
                ]
            )
        case .rightTop:
            NSLayoutConstraint.activate(
                [
                    trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    topAnchor.constraint(equalTo: view.topAnchor),
                ]
            )
        case .rightBottom:
            NSLayoutConstraint.activate(
                [
                    trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    bottomAnchor.constraint(equalTo: view.bottomAnchor),
                ]
            )
        }
    }
}

extension UIView {
    fileprivate enum Indicator {
        static var values = [UIView: UIActivityIndicatorView]()
    }
}

extension UIView: LoadableViewProtocol {}

// extension UILabel: LoadableViewProtocol {
// }
//
// extension UIButton: LoadableViewProtocol {
// }
//
// extension UIStackView: LoadableViewProtocol {
// }
//
// extension UITextView: LoadableViewProtocol {
// }

extension UITableView: LoadableViewProtocol {
    func hideContent() {
        isUserInteractionEnabled = false
    }

    func showContent() {
        isUserInteractionEnabled = true
    }
}

extension UICollectionView: LoadableViewProtocol {
    func hideContent() {
        isUserInteractionEnabled = false
    }

    func showContent() {
        isUserInteractionEnabled = true
    }
}
