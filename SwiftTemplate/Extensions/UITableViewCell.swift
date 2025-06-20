//
//  UITableViewCell.swift
//  HealthTracker
//
//  Created by Denis Kuznetsov on 28.12.2020.
//  Copyright © 2020 PeaksCircle. All rights reserved.
//

import UIKit

extension UITableViewCell {
    
    var superTableView: UITableView? {
        return next(UITableView.self)
    }
    
    var selfIndexPath: IndexPath? {
        guard let tableView = superTableView else { return nil }
        return tableView.indexPath(for: self)
    }
    
}
