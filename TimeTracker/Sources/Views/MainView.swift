import SwiftUI

/// Root view: two-column layout mirroring the Python app.
/// Left: timer, quick actions, manual entry, entries list.
/// Right: statistics, calendar.
struct MainView: View {
    @Bindable var vm: TimeTrackerViewModel

    var body: some View {
        HSplitView {
            leftColumn
                .frame(minWidth: 480)
            rightColumn
                .frame(minWidth: 300, idealWidth: 340, maxWidth: 400)
        }
        .frame(minWidth: 900, minHeight: 650)
    }

    // MARK: - Left Column

    private var leftColumn: some View {
        ScrollView {
            VStack(spacing: 16) {
                TimerView(vm: vm)
                QuickActionsBar(vm: vm)
                ManualEntryView(vm: vm)
                DaySummaryView(vm: vm)
                EntriesListView(vm: vm)
            }
            .padding(20)
        }
    }

    // MARK: - Right Column

    private var rightColumn: some View {
        ScrollView {
            VStack(spacing: 16) {
                StatisticsView(vm: vm)
                CalendarCardView(vm: vm)
            }
            .padding(20)
        }
    }
}

// MARK: - Quick Actions Bar

private struct QuickActionsBar: View {
    let vm: TimeTrackerViewModel

    @State private var showExporter = false
    @State private var exportContent = ""

    var body: some View {
        HStack(spacing: 8) {
            Button {
                vm.goToToday()
            } label: {
                Label("Today", systemImage: "sun.max")
            }

            Button {
                vm.refreshData()
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
            }

            Button {
                exportContent = vm.exportData()
                showExporter = true
            } label: {
                Label("Export", systemImage: "square.and.arrow.up")
            }
        }
        .buttonStyle(.bordered)
        .fileExporter(
            isPresented: $showExporter,
            document: TextExportDocument(content: exportContent),
            contentType: .plainText,
            defaultFilename: "time_export_\(DateFormatter.isoDate.string(from: .now)).txt"
        ) { _ in }
    }
}

// MARK: - Text Export Document

import UniformTypeIdentifiers

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
