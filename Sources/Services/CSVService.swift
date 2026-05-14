import Foundation

/// Reads and writes TimeEntry arrays to CSV files, maintaining backward compatibility
/// with the Python app's format: date,start_time,end_time,duration,is_off_day,is_overtime_taken,note
enum CSVService {
    private static let header = "date,start_time,end_time,duration,is_off_day,is_overtime_taken,note"

    // MARK: - Reading

    /// Parse a CSV file into TimeEntry array. Handles legacy files missing the "note" column.
    static func readEntries(from url: URL) throws -> [TimeEntry] {
        let content = try String(contentsOf: url, encoding: .utf8)
        let lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
        guard lines.count > 1 else { return [] }

        let headerLine = lines[0]
        let hasNoteColumn = headerLine.contains("note")

        return lines.dropFirst().compactMap { line -> TimeEntry? in
            let fields = parseCSVLine(line)
            guard fields.count >= 5 else { return nil }

            let dateStr = fields[0]
            guard let date = DateFormatter.isoDate.date(from: dateStr) else { return nil }

            let startTime = fields[1]
            let endTime = fields[2]
            let duration = fields[3]
            let isOffDay = fields[4].lowercased() == "true"
            let isOvertimeTaken = fields.count > 5 ? fields[5].lowercased() == "true" : false
            let note = hasNoteColumn && fields.count > 6 ? fields[6] : ""

            return TimeEntry(
                date: date,
                startTime: startTime,
                endTime: endTime,
                duration: duration,
                isOffDay: isOffDay,
                isOvertimeTaken: isOvertimeTaken,
                note: note
            )
        }
    }

    // MARK: - Writing

    /// Write entries to CSV, creating parent directories if needed.
    static func writeEntries(_ entries: [TimeEntry], to url: URL) throws {
        let dir = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

        var lines = [header]
        for entry in entries {
            let row = [
                entry.dateString,
                entry.startTime,
                entry.endTime,
                entry.duration,
                String(entry.isOffDay),
                String(entry.isOvertimeTaken),
                escapeCSVField(entry.note)
            ].joined(separator: ",")
            lines.append(row)
        }

        let content = lines.joined(separator: "\n") + "\n"
        try content.write(to: url, atomically: true, encoding: .utf8)
    }

    // MARK: - CSV Parsing Helpers

    /// Parse a CSV line respecting quoted fields that may contain commas.
    private static func parseCSVLine(_ line: String) -> [String] {
        var fields: [String] = []
        var current = ""
        var inQuotes = false

        for char in line {
            if char == "\"" {
                inQuotes.toggle()
            } else if char == "," && !inQuotes {
                fields.append(current.trimmingCharacters(in: .whitespaces))
                current = ""
            } else {
                current.append(char)
            }
        }
        fields.append(current.trimmingCharacters(in: .whitespaces))
        return fields
    }

    /// Escape a field for CSV output (quote if it contains commas or quotes).
    private static func escapeCSVField(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            return "\"\(field.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return field
    }
}
