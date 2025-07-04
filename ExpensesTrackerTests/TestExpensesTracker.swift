//
//  DateExtensionTests.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 23.06.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import XCTest
@testable import SwiftTemplate

final class TestSwfitTemplate: XCTestCase {
    
    // Выполняеться перед каждым тестом
    override func setUpWithError() throws {
        print(#function)
    }
    
    // Выполняеться после каждого теста
    override func tearDownWithError() throws {
        print(#function)
    }
    
}

final class DateExtensionTests: XCTestCase {

    // MARK: START timeToSeconds(_ time: String)
    func testTimeToSeconds_validValues() {
        XCTAssertEqual(Date.timeToSeconds("00:00"), 0)
        XCTAssertEqual(Date.timeToSeconds("01:00"), 3600)
        XCTAssertEqual(Date.timeToSeconds("02:30"), 9000)
        XCTAssertEqual(Date.timeToSeconds("23:59"), (23 * 3600 + 59 * 60))
    }
    
    func testTimeToSeconds_invalidValues() {
        XCTAssertEqual(Date.timeToSeconds(""), 0)
        XCTAssertEqual(Date.timeToSeconds("abc"), 0)
        XCTAssertEqual(Date.timeToSeconds("24:00"), 0) // Невалидное время в DateFormatter
        XCTAssertEqual(Date.timeToSeconds("12:60"), 0) // Минуты > 59
    }
    
    func testTimeToSeconds_partialInputs() {
        XCTAssertEqual(Date.timeToSeconds("12:"), 0)
        XCTAssertEqual(Date.timeToSeconds(":30"), 0)
        XCTAssertEqual(Date.timeToSeconds("12"), 0)
    }
    // MARK: END timeToSeconds(_ time: String)
}
