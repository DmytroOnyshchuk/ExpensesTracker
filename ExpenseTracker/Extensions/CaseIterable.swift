//
//  CaseIterable.swift
//  Orovera
//
//  Created by Dmytro Onyshchuk on 02.06.2023.
//  Copyright © 2023 PeaksCircle. All rights reserved.
//

import Foundation

extension CaseIterable where Self: Equatable {
    var index: Self.AllCases.Index? {
        Self.allCases.firstIndex { self == $0 }
    }
}
