//
//  Date.swift
//  HealthTracker
//
//  Created by Denis Kuznetsov on 07.12.2020.
//  Copyright © 2020 PeaksCircle. All rights reserved.
//

import Foundation

enum DateFormat {
    case archiveMessage
    case archiveOrder
    case compensation
    case feedPreorderFull
    case feedPreorderShort
    case iso8601
    case message
    case orderStepTime
    case profileRequests
    case rfc3339
    case server
    case serverShort
    case statsDay
    case statsMonth
    case statsWeek
    case timeFull
    case timeMedium
    case transaction
    case transactionDate
    case transactionDateMedium
    case transactionDateShort
    case transactionTime
    case weakDayFull
    case weekDayShort
    
    var format: String {
        switch self {
        case .archiveMessage: "HH:mm, dd.MM.yy"
        case .compensation: "HH:mm, dd.MM.yyyy"
        case .feedPreorderFull: "dd.MM HH:mm"
        case .feedPreorderShort: "HH:mm"
        case .iso8601: "yyyy-MM-dd'T'HH:mm:ss.SS'Z'"
        case .message, .archiveOrder: "dd.MM.yyyy (HH:mm)"
        case .orderStepTime: "HH:mm"
        case .profileRequests: "yyyy-MM-dd'T'HH:mm:ss'Z'"
        case .rfc3339: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        case .server: "yyyy-MM-dd HH:mm:ss"
        case .serverShort: "yyyy-MM-dd"
        case .statsDay: "E dd.MM.yyyy"
        case .statsWeek: "dd.MM"
        case .statsMonth: "LLLL yyyy"
        case .timeFull: "HH:mm:ss"
        case .timeMedium: "HH:mm"
        case .transaction: "dd MM yyyy"
        case .transactionDate: "dd.MM.yy"
        case .transactionDateMedium: "dd.MM"
        case .transactionDateShort: "dd"
        case .transactionTime: "HH:mm"
        case .weakDayFull: "EEEE"
        case .weekDayShort: "EE"
        }
    }
}

extension Date {
    func string(with format: DateFormat) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = format.format
        formatter.timeZone = .current
        return formatter.string(from: self)
    }
    
    var toDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        return dateFormatter.string(from: self)
    }

    var toDateTimeString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        return dateFormatter.string(from: self)
    }

    var toDay: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self)
    }

    var toDayTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, HH:mm"
        return dateFormatter.string(from: self)
    }

    var localDate: Date {
        let delta = TimeZone.current.secondsFromGMT(for: self)
        return addingTimeInterval(TimeInterval(delta))
    }

    var gmt: Date {
        let delta = TimeZone.current.secondsFromGMT(for: self)
        return addingTimeInterval(-TimeInterval(delta))
    }

    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var startOfWeek: Date {
        Calendar.current.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
    }

    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)!
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

    static var yesterday: Date { Date().dayBefore }

    var dayBefore: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }

    var noon: Date {
        Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }

    var timeAgoDisplay: String {
        let calendar = Calendar.current
        let minuteAgo = calendar.date(byAdding: .minute, value: -1, to: Date())!
        let hourAgo = calendar.date(byAdding: .hour, value: -1, to: Date())!
        let dayAgo = calendar.date(byAdding: .day, value: -1, to: Date())!
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!

        if minuteAgo < self {
            //            let diff = Calendar.current.dateComponents([.second], from: self, to: Date()).second ?? .zero
            return "just now"
        } else if hourAgo < self {
            let diff = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute ?? .zero
            return "\(diff)min ago"
        } else if dayAgo < self {
            let diff = Calendar.current.dateComponents([.hour], from: self, to: Date()).hour ?? .zero
            return "\(diff)hrs ago"
        } else if weekAgo < self {
            let diff = Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? .zero
            return "\(diff)days ago"
        }
        let diff = Calendar.current.dateComponents([.weekOfYear], from: self, to: Date()).weekOfYear ?? .zero
        return "\(diff)weeks ago"
    }

    var time: DateTime {
        DateTime(self)
    }

    static func dateFrom(_ timeInterval: Int) -> Date {
        Date(timeIntervalSince1970: TimeInterval(timeInterval))
    }

    static func timeToMinutes(_ time: String) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        guard let date = formatter.date(from: time) else {
            return 0
        }
        let calendar = Calendar(identifier: .gregorian)

        let currentDateComponent = calendar.dateComponents([.hour, .minute], from: date)
        let hours = ((currentDateComponent.hour ?? .zero) * 60)
        let minutes = currentDateComponent.minute ?? .zero

        return hours + minutes
    }

    static func timeToSeconds(_ time: String) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        let date = formatter.date(from: time)
        let calendar = Calendar(identifier: .gregorian)
        if let date {
            let currentDateComponent = calendar.dateComponents([.hour, .minute], from: date)
            let numberOfSeconds = ((currentDateComponent.hour! * 60) + currentDateComponent.minute!) * 60
            return numberOfSeconds
        }
        return 0
    }

    static func timeString(_ time: Int) -> String {
        let hour = time / 3600
        let minute = (time % 3600) / 60
        let second = time % 60

        if hour > 0 {
            return String(format: "%02i:%02i", hour, minute)
        } else {
            return String(format: "%02i:%02i", minute, second)
        }
    }

    static func minutesToHoursMinutes(_ minutes: Int) -> (Int, Int) {
        let hours = minutes / 60
        return (hours >= 24 ? 0 : hours, minutes % 60)
    }

    static func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int, Int) {
        (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }

    static func timeSlots(_ start: String, _ end: String, _ interval: Int) -> [(Int, Int)] {
        var timeSlots = [(Int, Int)]()
        let firstTime = Date.timeToMinutes(start)
        let lastTime = Date.timeToMinutes(end)
        var t = firstTime
        var i: Int = .zero
        while t <= lastTime {
            t = firstTime + i * interval
            timeSlots.append(Date.minutesToHoursMinutes(t))
            i += 1
        }
        return timeSlots
    }

    func dateOnly(calendar: Calendar) -> Date {
        let yearComponent = calendar.component(.year, from: self)
        let monthComponent = calendar.component(.month, from: self)
        let dayComponent = calendar.component(.day, from: self)
        let zone = calendar.timeZone

        let newComponents = DateComponents(timeZone: zone,
                                           year: yearComponent,
                                           month: monthComponent,
                                           day: dayComponent)
        let returnValue = calendar.date(from: newComponents)
        return returnValue!
    }

    func dateNoSeconds(calendar: Calendar = Calendar.current) -> Date {
        let yearComponent = calendar.component(.year, from: self)
        let monthComponent = calendar.component(.month, from: self)
        let dayComponent = calendar.component(.day, from: self)
        let hourComponent = calendar.component(.hour, from: self)
        let minuteComponent = calendar.component(.minute, from: self)

        let zone = calendar.timeZone

        let newComponents = DateComponents(timeZone: zone,
                                           year: yearComponent,
                                           month: monthComponent,
                                           day: dayComponent,
                                           hour: hourComponent,
                                           minute: minuteComponent)
        let returnValue = calendar.date(from: newComponents)
        return returnValue!
    }

    func formattedDate(calendar: Calendar) -> String {
        let timezone = calendar.timeZone
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeZone = timezone
        formatter.locale = Locale(identifier: Locale.preferredLanguages[0])
        return formatter.string(from: self)
    }

    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }

    static func stringToDate(date: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        let date = dateFormatter.date(from: date)

        return date
    }

    func fromSecondsSinceStartOfDay(_ seconds: Int) -> Date {
        Calendar.current.startOfDay(for: self).addingTimeInterval(TimeInterval(seconds))
    }

    var secondsSinceStartOfDay: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: self)
        let seconds = (components.hour ?? .zero) * 3600 + (components.minute ?? .zero) * 60 + (components.second ?? .zero)
        return seconds
    }

    func adding(_ value: Int, _ component: Calendar.Component) -> Date {
        Calendar.current.date(byAdding: component, value: value, to: self)!
    }

    func formatted(_ format: String, locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = locale
        return formatter.string(from: self)
    }

    var toString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy, HH:mm"
        formatter.locale = Locale.current
        return formatter.string(from: self)
    }

    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale.current
        return formatter.string(from: self)
    }

    static func stringDateFrom(_ timeInterval: Int) -> String {
        Date(timeIntervalSince1970: TimeInterval(timeInterval)).toString
    }

    static func stringFromTimeInterval(_ timeInterval: Int) -> String {
        Date(timeIntervalSince1970: TimeInterval(timeInterval)).toString
    }

    static func durationString(_ minutes: Int) -> String {
        let totalMinutes = abs(minutes) // Handle negative values

        let days = totalMinutes / (24 * 60)
        let hours = (totalMinutes % (24 * 60)) / 60
        let mins = totalMinutes % 60

        var components: [String] = []

        if days > 0 {
            components.append("\(days)d")
        }

        if hours > 0 {
            components.append("\(hours)h")
        }

        if mins > 0 || components.isEmpty {
            components.append("\(mins)m")
        }

        return components.joined(separator: " ")
    }

    var toIso8601String: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.string(from: self)
    }
}

final class DateTime: Comparable, Equatable {
    init(_ date: Date) {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.hour, .minute], from: date)
        let dateSeconds = dateComponents.hour! * 3600 + dateComponents.minute! * 60

        self.secondsSinceBeginningOfDay = dateSeconds
        self.hour = dateComponents.hour!
        self.minute = dateComponents.minute!
    }

    init(_ hour: Int, _ minute: Int) {
        let dateSeconds = hour * 3600 + minute * 60
        self.secondsSinceBeginningOfDay = dateSeconds

        self.hour = hour
        self.minute = minute
    }

    var hour: Int
    var minute: Int

    var date: Date {
        let calendar = Calendar.current
        var dateComponents = DateComponents()

        dateComponents.hour = hour
        dateComponents.minute = minute

        return calendar.date(byAdding: dateComponents, to: Date())!
    }

    private let secondsSinceBeginningOfDay: Int

    static func == (lhs: DateTime, rhs: DateTime) -> Bool {
        lhs.secondsSinceBeginningOfDay == rhs.secondsSinceBeginningOfDay
    }

    static func < (lhs: DateTime, rhs: DateTime) -> Bool {
        lhs.secondsSinceBeginningOfDay < rhs.secondsSinceBeginningOfDay
    }

    static func <= (lhs: DateTime, rhs: DateTime) -> Bool {
        lhs.secondsSinceBeginningOfDay <= rhs.secondsSinceBeginningOfDay
    }

    static func >= (lhs: DateTime, rhs: DateTime) -> Bool {
        lhs.secondsSinceBeginningOfDay >= rhs.secondsSinceBeginningOfDay
    }

    static func > (lhs: DateTime, rhs: DateTime) -> Bool {
        lhs.secondsSinceBeginningOfDay > rhs.secondsSinceBeginningOfDay
    }
}

extension Date {
    private static let relativeDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()

    var relativeDayName: String? {
        let calendar = Calendar.current
        guard calendar.isDateInToday(self) || calendar.isDateInYesterday(self) else { return nil }

        let text = Self.relativeDayFormatter.string(from: self)
        return text.prefix(1).capitalized + text.dropFirst()
    }

    func dayString(_ style: Date.FormatStyle) -> String {
        relativeDayName ?? formatted(style)
    }
}
