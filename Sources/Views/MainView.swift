import SwiftUI
import UniformTypeIdentifiers

struct MainView: View {
    @Bindable var vm: TimeTrackerViewModel

    var body: some View {
        NavigationSplitView {
            sidebar
                .navigationSplitViewColumnWidth(min: 280, ideal: 300, max: 340)
        } detail: {
            detailContent
        }
        .toolbar {
            toolbarContent
        }
        .overlay {
            if vm.showTimerPrompt {
                TimerPromptOverlay(vm: vm)
            }
        }
    }

    // MARK: - Sidebar

    private var sidebar: some View {
        ScrollView {
            VStack(spacing: 20) {
                CalendarCardView(vm: vm)
                StatisticsView(vm: vm)
            }
            .padding(16)
        }
        .background(.background)
    }

    // MARK: - Detail

    private var detailContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                TimerView(vm: vm)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 20)

                DaySummaryView(vm: vm)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)

                ManualEntryView(vm: vm)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)

                EntriesListView(vm: vm)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
            }
        }
        .background(.background)
        .frame(minWidth: 520)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
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

            ExportButton(vm: vm)
        }
    }
}

// MARK: - Export Button

private struct ExportButton: View {
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

// MARK: - Text Export Document

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
