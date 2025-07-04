//
//  SwiftTemplateUITestsLaunchTests.swift
//  SwiftTemplateUITests
//
//  Created by Dmytro Onyshchuk on 23.06.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import XCTest

final class SwiftTemplateUITestsLaunchTests: XCTestCase {

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
}
