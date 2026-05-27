import SwiftUI

struct MainView: View {
    @Bindable var vm: TimeTrackerViewModel
    @State private var showsStatistics = false

    var body: some View {
        NavigationSplitView {
            sidebar
                .navigationSplitViewColumnWidth(min: 252, ideal: 276, max: 312)
        } detail: {
            detailContent
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                TrackerToolbarButtons(vm: vm, showsStatistics: $showsStatistics)
            }
        }
        .background(Color.appBackground)
    }

    // MARK: - Sidebar

    private var sidebar: some View {
        ScrollView {
            VStack(spacing: 12) {
                OverallBalanceHeader(vm: vm)
                CalendarCardView(vm: vm)
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 8)
        }
        .scrollIndicators(.never)
        .background(Color.appChrome)
    }

    // MARK: - Detail

    private var detailContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                if showsStatistics {
                    StatisticsPanelView(vm: vm)
                } else {
                    TimerView(vm: vm)
                    DaySummaryView(vm: vm)
                    ManualEntryView(vm: vm)
                    EntriesListView(vm: vm)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 4)
            .padding(.bottom, 12)
            .animation(.easeInOut(duration: 0.2), value: showsStatistics)
        }
        .scrollIndicators(.automatic)
        .background(Color.appBackground)
        .frame(minWidth: 520)
    }
}
