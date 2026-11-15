//
//  StoredSettings.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 15.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import SwiftUI

@propertyWrapper
struct StoredSettings: DynamicProperty {
    @AppStorage(UDKey.appSettings.rawValue, store: UserDefaults.shared) private var data: Data?

    var wrappedValue: AppSettings {
        get { AppSettings(jsonData: data) ?? AppSettings() }
        nonmutating set { data = newValue.jsonData() }
    }

    var projectedValue: Binding<AppSettings> {
        Binding(get: { wrappedValue }, set: { wrappedValue = $0 })
    }
}
