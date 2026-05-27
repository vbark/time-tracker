import SwiftUI
import UniformTypeIdentifiers

struct TrackerToolbarButtons: View {
    let vm: TimeTrackerViewModel
    @Binding var showsStatistics: Bool

    var body: some View {
        Button {
            vm.goToToday()
        } label: {
            Label("Today", systemImage: "calendar")
        }
        .help("Go to Today")

        Button {
            vm.refreshData()
        } label: {
            Label("Refresh", systemImage: "arrow.clockwise")
        }
        .help("Refresh Data")

        ExportToolbarButton(vm: vm)

        Button {
            showsStatistics.toggle()
        } label: {
            Label("Statistics", systemImage: showsStatistics ? "chart.bar.fill" : "chart.bar")
        }
        .help(showsStatistics ? "Show Timer" : "Show Statistics")
    }
}

private struct ExportToolbarButton: View {
    let vm: TimeTrackerViewModel
    @State private var showExporter = false
    @State private var exportContent = ""

    var body: some View {
        Button {
            exportContent = vm.exportData()
            showExporter = true
        } label: {
            Label("Export", systemImage: "square.and.arrow.up")
        }
        .help("Export Data")
        .fileExporter(
            isPresented: $showExporter,
            document: TextExportDocument(content: exportContent),
            contentType: .plainText,
            defaultFilename: "time_export_\(DateFormatter.isoDate.string(from: .now)).txt"
        ) { _ in }
    }
}

struct TextExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.plainText] }
    let content: String

    init(content: String) { self.content = content }
    init(configuration: ReadConfiguration) throws {
        content = String(data: configuration.file.regularFileContents ?? Data(), encoding: .utf8) ?? ""
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: Data(content.utf8))
    }
}
