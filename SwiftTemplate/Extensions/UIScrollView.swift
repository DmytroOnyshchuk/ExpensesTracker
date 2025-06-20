import UIKit

extension UIScrollView {
    
    func register<T: UITableViewCell>(_ classType: T.Type) {
        let nibName = String(describing: T.name)
        let nib = UINib(nibName: nibName, bundle: nil)
        guard let tableView = self as? UITableView else {
            fatalError()
        }
        tableView.register(nib, forCellReuseIdentifier: nibName)
    }
    
    func get<T: UITableViewCell>(_ classType: T.Type, identifier: String? = nil) -> T {
        guard let tableView = self as? UITableView else {
            fatalError()
        }
        return tableView.dequeueReusableCell(withIdentifier: identifier ?? T.name) as! T
    }
    
    func register<T: UITableViewHeaderFooterView>(headerFooter classType: T.Type) {
        guard let tableView = self as? UITableView else {
            fatalError()
        }
        let identifier = String(describing: T.self)
        let nib = UINib(nibName: identifier, bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: identifier)
    }
    
    func get<T: UITableViewHeaderFooterView>(headerFooter classType: T.Type) -> T {
        guard let tableView = self as? UITableView else {
            fatalError()
        }
        let identifier = String(describing: T.self)
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) as! T
    }
    
    func register<T: UICollectionViewCell>(_ classType: T.Type) {
        let nibName = String(describing: T.name)
        let nib = UINib(nibName: nibName, bundle: nil)
        guard let collectionView = self as? UICollectionView else {
            fatalError()
        }
        collectionView.register(nib, forCellWithReuseIdentifier: nibName)
    }
	
	func register<T: UICollectionReusableView>(_ classType: T.Type) {
		let nibName = String(describing: T.name)
		let nib = UINib(nibName: nibName, bundle: nil)
		guard let collectionView = self as? UICollectionView else {
			fatalError()
		}
		collectionView.register(nib, forSupplementaryViewOfKind: nibName, withReuseIdentifier: nibName)
	}
    
    func get<T: UICollectionViewCell>(_ classType: T.Type, indexPath: IndexPath) -> T {
        guard let collectionView = self as? UICollectionView else {
            fatalError()
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: T.name, for: indexPath) as! T
    }
	
	func get<T: UICollectionReusableView>(_ classType: T.Type, indexPath: IndexPath) -> T {
		guard let collectionView = self as? UICollectionView else {
			fatalError()
		}
		
		return collectionView.dequeueReusableSupplementaryView(ofKind: T.name, withReuseIdentifier: T.name, for: indexPath) as! T
	}
    
}

extension UIScrollView {
    
    func scrollToTop(animated: Bool = true) {
        setContentOffset(CGPoint(x: 0, y: -contentInset.top), animated: animated)
    }
    
}
