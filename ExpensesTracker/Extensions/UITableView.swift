//
//  UITableView.swift
//  Orovera
//
//  Created by Dmytro Onyshchuk on 04.08.2023.
//  Copyright © 2023 PeaksCircle. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
	
	func updateHeaderViewHeight() {
		
		if let headerView = tableHeaderView {
			
			headerView.setNeedsLayout()
			headerView.layoutIfNeeded()
			headerView.sizeToFit()
			
			let headerHeight = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
			var headerFrame = headerView.frame
			
			// Needed or we will stay in viewDidLayoutSubviews() forever
			if headerHeight != headerFrame.size.height {
				headerFrame.size.height = headerHeight
				headerView.frame = headerFrame
				tableHeaderView = headerView
			}
		}
		
	}
    
    func updateLastCell() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.beginUpdates()
            if let indexPath = self.visibleCells.last?.selfIndexPath {
                self.reloadRows(at: [indexPath], with: .automatic)
            }
            self.endUpdates()
        }
    }
    
    func setBackgroundMessage(_ message: String) {
        let labelMessage = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        labelMessage.text = message
        labelMessage.textColor = .lightGray
        labelMessage.numberOfLines = 0
        labelMessage.textAlignment = .center
        labelMessage.font = UIFont(name: "TrebuchetMS", size: 22)
        labelMessage.sizeToFit()
        
        self.backgroundView = labelMessage
        self.separatorStyle = .none
    }
    
    func clearBackgroundMessage() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
    
    func scrollToBottom(animated: Bool = true) {
        DispatchQueue.main.async {
            let lastSection = self.numberOfSections - 1
            guard lastSection >= 0, self.numberOfRows(inSection: lastSection) > 0 else { return }
            let lastRow = self.numberOfRows(inSection: lastSection) - 1
            let indexPath = IndexPath(row: lastRow, section: lastSection)
            self.layoutIfNeeded()
            self.scrollToRow(at: indexPath, at: .bottom, animated: animated)
            self.layoutIfNeeded()
        }
    }
    
    func showPlaceholder(_ show: Bool, text: String? = nil) {
        DispatchQueue.main.async {
            if show {
                let footer = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 124))
                
                let placeholderLabel = UILabel()
                placeholderLabel.font = .appRegularFont(ofSize: 20)
                placeholderLabel.numberOfLines = 0
                placeholderLabel.textColor = .black
                placeholderLabel.text = text ?? "No data"
                placeholderLabel.textAlignment = .center
                placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
                placeholderLabel.lineBreakMode = .byWordWrapping
                footer.addSubview(placeholderLabel)
                
                NSLayoutConstraint.activate([
                    placeholderLabel.widthAnchor.constraint(equalToConstant: footer.frame.width - 64),
                    placeholderLabel.centerXAnchor.constraint(equalTo: footer.centerXAnchor),
                    placeholderLabel.centerYAnchor.constraint(equalTo: footer.centerYAnchor)
                ])
                
                self.tableFooterView = footer
            } else {
                self.tableFooterView = nil
            }
        }
    }
	
}
