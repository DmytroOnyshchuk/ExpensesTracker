//
//  UICollectionViewLayout.swift
//  HealthTracker
//
//  Created by Andrii Tymoshchuk on 13.06.2024.
//  Copyright © 2024 PeaksCircle. All rights reserved.
//

import UIKit

extension UICollectionViewLayout {
    static func createBasicListLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(130),
                                              heightDimension: .absolute(52))

        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.edgeSpacing = .init(leading: .none, top: .none, trailing: .fixed(3), bottom: .none)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(200.0),
                                               heightDimension: .absolute(55))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        group.edgeSpacing = .init(leading: .fixed(0), top: .fixed(0), trailing: .fixed(10), bottom: .flexible(0))
        let section = NSCollectionLayoutSection(group: group)

        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .horizontal

        let layout = UICollectionViewCompositionalLayout(section: section, configuration: configuration)
        return layout
    }
}
