import Foundation

enum BackupXLSXWriter {
    private static let namespace = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
    private static let relationships = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
    private static let packageRelationships = "http://schemas.openxmlformats.org/package/2006/relationships"
    private static let declaration = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>"
    private static let columnWidths: [Double] = [18, 22, 26, 14, 40]

    private enum Style: Int {
        case header = 1
        case date = 2
        case amount = 3
    }

    static func data(header: [String], rows: [BackupTableRow], sheetName: String, timeZone: TimeZone = .current) -> Data {
        var archive = ZipArchive()
        archive.add("[Content_Types].xml", contentTypes)
        archive.add("_rels/.rels", rootRelationships)
        archive.add("xl/workbook.xml", workbook(sheetName: sheetName))
        archive.add("xl/_rels/workbook.xml.rels", workbookRelationships)
        archive.add("xl/styles.xml", styles)
        archive.add("xl/worksheets/sheet1.xml", sheet(header: header, rows: rows, timeZone: timeZone))
        return archive.finalized()
    }

    private static var contentTypes: String {
        declaration
            + "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\">"
            + "<Default Extension=\"rels\" ContentType=\"application/vnd.openxmlformats-package.relationships+xml\"/>"
            + "<Default Extension=\"xml\" ContentType=\"application/xml\"/>"
            + "<Override PartName=\"/xl/workbook.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml\"/>"
            + "<Override PartName=\"/xl/worksheets/sheet1.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml\"/>"
            + "<Override PartName=\"/xl/styles.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml\"/>"
            + "</Types>"
    }

    private static var rootRelationships: String {
        declaration
            + "<Relationships xmlns=\"\(packageRelationships)\">"
            + "<Relationship Id=\"rId1\" Type=\"\(relationships)/officeDocument\" Target=\"xl/workbook.xml\"/>"
            + "</Relationships>"
    }

    private static var workbookRelationships: String {
        declaration
            + "<Relationships xmlns=\"\(packageRelationships)\">"
            + "<Relationship Id=\"rId1\" Type=\"\(relationships)/worksheet\" Target=\"worksheets/sheet1.xml\"/>"
            + "<Relationship Id=\"rId2\" Type=\"\(relationships)/styles\" Target=\"styles.xml\"/>"
            + "</Relationships>"
    }

    private static var styles: String {
        let plain = "fillId=\"0\" borderId=\"0\" xfId=\"0\""
        return declaration
            + "<styleSheet xmlns=\"\(namespace)\">"
            + "<fonts count=\"2\">"
            + "<font><sz val=\"11\"/><name val=\"Calibri\"/></font>"
            + "<font><b/><sz val=\"11\"/><name val=\"Calibri\"/></font>"
            + "</fonts>"
            + "<fills count=\"2\">"
            + "<fill><patternFill patternType=\"none\"/></fill>"
            + "<fill><patternFill patternType=\"gray125\"/></fill>"
            + "</fills>"
            + "<borders count=\"1\"><border><left/><right/><top/><bottom/><diagonal/></border></borders>"
            + "<cellStyleXfs count=\"1\"><xf numFmtId=\"0\" fontId=\"0\" fillId=\"0\" borderId=\"0\"/></cellStyleXfs>"
            + "<cellXfs count=\"4\">"
            + "<xf numFmtId=\"0\" fontId=\"0\" \(plain)/>"
            + "<xf numFmtId=\"0\" fontId=\"1\" \(plain) applyFont=\"1\"/>"
            + "<xf numFmtId=\"22\" fontId=\"0\" \(plain) applyNumberFormat=\"1\"/>"
            + "<xf numFmtId=\"4\" fontId=\"0\" \(plain) applyNumberFormat=\"1\"/>"
            + "</cellXfs>"
            + "</styleSheet>"
    }

    private static func workbook(sheetName: String) -> String {
        let forbidden = CharacterSet(charactersIn: "[]:*?/\\")
        let cleaned = String(String(sheetName.unicodeScalars.filter { !forbidden.contains($0) }).prefix(31))
        let name = cleaned.isEmpty ? "Sheet1" : cleaned
        return declaration
            + "<workbook xmlns=\"\(namespace)\" xmlns:r=\"\(relationships)\">"
            + "<sheets><sheet name=\"\(escaped(name))\" sheetId=\"1\" r:id=\"rId1\"/></sheets>"
            + "</workbook>"
    }

    private static func sheet(header: [String], rows: [BackupTableRow], timeZone: TimeZone) -> String {
        var xml = declaration
        xml += "<worksheet xmlns=\"\(namespace)\">"
        xml += "<sheetViews><sheetView workbookViewId=\"0\">"
        xml += "<pane ySplit=\"1\" topLeftCell=\"A2\" activePane=\"bottomLeft\" state=\"frozen\"/>"
        xml += "</sheetView></sheetViews>"
        xml += "<cols>"
        for (index, width) in columnWidths.enumerated() {
            xml += "<col min=\"\(index + 1)\" max=\"\(index + 1)\" width=\"\(width)\" customWidth=\"1\"/>"
        }
        xml += "</cols>"
        xml += "<sheetData>"

        xml += "<row r=\"1\">"
        for (column, title) in header.enumerated() {
            xml += textCell(title, column: column, row: 1, style: .header)
        }
        xml += "</row>"

        for (index, row) in rows.enumerated() {
            let number = index + 2
            xml += "<row r=\"\(number)\">"
            xml += numberCell(serialDate(row.date, timeZone: timeZone), column: 0, row: number, style: .date)
            xml += textCell(row.folder, column: 1, row: number)
            xml += textCell(row.category, column: 2, row: number)
            xml += numberCell(amountText(row.amount), column: 3, row: number, style: .amount)
            xml += textCell(row.comment, column: 4, row: number)
            xml += "</row>"
        }

        xml += "</sheetData></worksheet>"
        return xml
    }

    private static func reference(column: Int, row: Int) -> String {
        let letter = Character(UnicodeScalar(UInt8(65 + column)))
        return "\(letter)\(row)"
    }

    private static func textCell(_ text: String, column: Int, row: Int, style: Style? = nil) -> String {
        guard !text.isEmpty else { return "" }
        let styleAttribute = style.map { " s=\"\($0.rawValue)\"" } ?? ""
        return "<c r=\"\(reference(column: column, row: row))\"\(styleAttribute) t=\"inlineStr\">"
            + "<is><t xml:space=\"preserve\">\(escaped(text))</t></is></c>"
    }

    private static func numberCell(_ value: String, column: Int, row: Int, style: Style) -> String {
        "<c r=\"\(reference(column: column, row: row))\" s=\"\(style.rawValue)\"><v>\(value)</v></c>"
    }

    private static func serialDate(_ date: Date, timeZone: TimeZone) -> String {
        let localSeconds = date.timeIntervalSince1970 + Double(timeZone.secondsFromGMT(for: date))
        return String(format: "%.6f", locale: Locale(identifier: "en_US_POSIX"), localSeconds / 86400 + 25569)
    }

    private static func amountText(_ amount: Int) -> String {
        let magnitude = abs(amount)
        let sign = amount < 0 ? "-" : ""
        let cents = magnitude % 100
        return sign + String(magnitude / 100) + "." + (cents < 10 ? "0" : "") + String(cents)
    }

    private static func escaped(_ text: String) -> String {
        var result = ""
        for scalar in text.unicodeScalars {
            switch scalar {
            case "&": result += "&amp;"
            case "<": result += "&lt;"
            case ">": result += "&gt;"
            case "\"": result += "&quot;"
            case "\t", "\n", "\r": result.unicodeScalars.append(scalar)
            default:
                if scalar.value >= 0x20, scalar.value != 0xFFFE, scalar.value != 0xFFFF {
                    result.unicodeScalars.append(scalar)
                }
            }
        }
        return result
    }
}

private struct ZipArchive {
    private struct Entry {
        let name: Data
        let checksum: UInt32
        let size: UInt32
        let offset: UInt32
    }

    private static let checksumTable: [UInt32] = (0 ..< 256).map { index in
        (0 ..< 8).reduce(UInt32(index)) { value, _ in
            value & 1 == 1 ? 0xEDB8_8320 ^ (value >> 1) : value >> 1
        }
    }

    private static let version: UInt16 = 20
    private static let utf8Flag: UInt16 = 0x0800
    private static let dosDate: UInt16 = 0x0021

    private var body = Data()
    private var entries: [Entry] = []

    mutating func add(_ name: String, _ text: String) {
        let content = Data(text.utf8)
        let entry = Entry(
            name: Data(name.utf8),
            checksum: Self.checksum(content),
            size: UInt32(content.count),
            offset: UInt32(body.count)
        )
        entries.append(entry)

        body.append(littleEndian: UInt32(0x0403_4B50))
        appendCommonFields(of: entry, to: &body)
        body.append(littleEndian: UInt16(entry.name.count))
        body.append(littleEndian: UInt16(0))
        body.append(entry.name)
        body.append(content)
    }

    func finalized() -> Data {
        var directory = Data()
        for entry in entries {
            directory.append(littleEndian: UInt32(0x0201_4B50))
            directory.append(littleEndian: Self.version)
            appendCommonFields(of: entry, to: &directory)
            directory.append(littleEndian: UInt16(entry.name.count))
            directory.append(littleEndian: UInt16(0))
            directory.append(littleEndian: UInt16(0))
            directory.append(littleEndian: UInt16(0))
            directory.append(littleEndian: UInt16(0))
            directory.append(littleEndian: UInt32(0))
            directory.append(littleEndian: entry.offset)
            directory.append(entry.name)
        }

        var result = body
        result.append(directory)
        result.append(littleEndian: UInt32(0x0605_4B50))
        result.append(littleEndian: UInt16(0))
        result.append(littleEndian: UInt16(0))
        result.append(littleEndian: UInt16(entries.count))
        result.append(littleEndian: UInt16(entries.count))
        result.append(littleEndian: UInt32(directory.count))
        result.append(littleEndian: UInt32(body.count))
        result.append(littleEndian: UInt16(0))
        return result
    }

    private func appendCommonFields(of entry: Entry, to data: inout Data) {
        data.append(littleEndian: Self.version)
        data.append(littleEndian: Self.utf8Flag)
        data.append(littleEndian: UInt16(0))
        data.append(littleEndian: UInt16(0))
        data.append(littleEndian: Self.dosDate)
        data.append(littleEndian: entry.checksum)
        data.append(littleEndian: entry.size)
        data.append(littleEndian: entry.size)
    }

    private static func checksum(_ data: Data) -> UInt32 {
        var value: UInt32 = 0xFFFF_FFFF
        for byte in data {
            value = checksumTable[Int((value ^ UInt32(byte)) & 0xFF)] ^ (value >> 8)
        }
        return value ^ 0xFFFF_FFFF
    }
}

extension Data {
    fileprivate mutating func append<T: FixedWidthInteger>(littleEndian value: T) {
        withUnsafeBytes(of: value.littleEndian) { append(contentsOf: $0) }
    }
}
