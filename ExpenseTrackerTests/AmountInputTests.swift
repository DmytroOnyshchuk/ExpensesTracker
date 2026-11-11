//
//  AmountInputTests.swift
//  ExpenseTrackerTests
//
//  Created by Dmytro Onyshchuk on 11.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

@testable import ExpenseTracker
import XCTest

final class AmountInputTests: XCTestCase {
    /// Набирает строку на клавиатуре: цифры, «.» — разделитель, «<» — стирание.
    private func typing(_ keys: String) -> AmountInput {
        var input = AmountInput()
        for key in keys {
            switch key {
            case ".":
                input.tap(.decimalSeparator)
            case "<":
                input.tap(.backspace)
            default:
                input.tap(.digit(key.wholeNumberValue ?? 0))
            }
        }
        return input
    }

    func testEmptyInput() {
        let input = AmountInput()

        XCTAssertTrue(input.isEmpty)
        XCTAssertEqual(input.amount, 0)
        XCTAssertNil(input.text)
    }

    func testWholeNumberIsStoredInMinorUnits() {
        let input = typing("12")

        XCTAssertEqual(input.amount, 1200)
        XCTAssertEqual(input.text, "12")
    }

    func testSeparatorWithoutFraction() {
        let input = typing("12.")

        XCTAssertEqual(input.amount, 1200)
        XCTAssertEqual(input.text, "12,")
    }

    func testFractionDigits() {
        XCTAssertEqual(typing("12.5").amount, 1250)
        XCTAssertEqual(typing("12.5").text, "12.5")

        XCTAssertEqual(typing("12.05").amount, 1205)
        XCTAssertEqual(typing("12.05").text, "12.05")
    }

    func testSeparatorFirstStartsWithZero() {
        XCTAssertEqual(typing(".").text, "0,")
        XCTAssertEqual(typing(".").amount, 0)

        XCTAssertEqual(typing(".5").text, "0.5")
        XCTAssertEqual(typing(".5").amount, 50)
    }

    func testThirdFractionDigitIsIgnored() {
        let input = typing("12.345")

        XCTAssertEqual(input.amount, 1234)
        XCTAssertEqual(input.text, "12.34")
    }

    func testSecondSeparatorIsIgnored() {
        let input = typing("1.2.3")

        XCTAssertEqual(input.amount, 123)
        XCTAssertEqual(input.text, "1.23")
    }

    func testNonZeroDigitReplacesLastZeroOfZeroAmount() {
        let input = typing("0.005")

        XCTAssertEqual(input.amount, 5)
        XCTAssertEqual(input.text, "0.05")
    }

    func testBackspaceRemovesFractionThenSeparatorThenDigits() {
        XCTAssertEqual(typing("12.5<").text, "12,")
        XCTAssertEqual(typing("12.5<<").text, "12")
        XCTAssertEqual(typing("12.5<<<").text, "1")
        XCTAssertEqual(typing("12.5<<<").amount, 100)
    }

    func testErasingDownToZeroClearsInput() {
        XCTAssertTrue(typing("5<").isEmpty)
        XCTAssertTrue(typing("0.5<").isEmpty)
        XCTAssertNil(typing("0.5<").text)
    }

    func testBackspaceOnEmptyInputDoesNothing() {
        XCTAssertTrue(typing("<").isEmpty)
    }

    func testReset() {
        var input = typing("12.5")
        input.reset()

        XCTAssertTrue(input.isEmpty)
        XCTAssertEqual(input.amount, 0)
        XCTAssertEqual(typing("12.5").amount, 1250)
    }
}
