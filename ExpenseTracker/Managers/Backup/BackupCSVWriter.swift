import Foundation

struct BackupTableRow {
    let date: Date
    let folder: String
    let category: String
    let amount: Int
    let note: String
}

enum BackupCSVWriter {
    static func data(header: [String], rows: [BackupTableRow], locale: Locale = .current) -> Data {
        let decimalSeparator = locale.decimalSeparator ?? "."
        let delimiter = decimalSeparator == "," ? ";" : ","

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"

        var lines = [line(header, delimiter: delimiter)]
        for row in rows {
            let fields = [
                dateFormatter.string(from: row.date),
                row.folder,
                row.category,
                amountText(row.amount, decimalSeparator: decimalSeparator),
                row.note,
            ]
            lines.append(line(fields, delimiter: delimiter))
        }

        return Data(("\u{FEFF}" + lines.joined(separator: "\r\n") + "\r\n").utf8)
    }

    private static func amountText(_ amount: Int, decimalSeparator: String) -> String {
        let magnitude = abs(amount)
        let sign = amount < 0 ? "-" : ""
        return sign + String(magnitude / 100) + decimalSeparator + String(format: "%02d", magnitude % 100)
    }

    private static func line(_ fields: [String], delimiter: String) -> String {
        fields.map { escaped($0, delimiter: delimiter) }.joined(separator: delimiter)
    }

    private static func escaped(_ field: String, delimiter: String) -> String {
        let needsQuotes = field.contains(delimiter) || field.contains("\"") || field.contains("\n") || field.contains("\r")
        guard needsQuotes else { return field }
        return "\"" + field.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }
}
