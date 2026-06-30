import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .home

    enum Tab {
        case home, habits, journal, photos, reports, settings
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem { Label("Today", systemImage: "sun.min") }
                .tag(Tab.home)

            HabitsView()
                .tabItem { Label("Habits", systemImage: "checkmark.circle") }
                .tag(Tab.habits)

            JournalView()
                .tabItem { Label("Journal", systemImage: "heart") }
                .tag(Tab.journal)

            PhotosView()
                .tabItem { Label("Progress", systemImage: "camera") }
                .tag(Tab.photos)

            ReportsView()
                .tabItem { Label("Reports", systemImage: "chart.bar") }
                .tag(Tab.reports)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "slider.horizontal.3") }
                .tag(Tab.settings)
        }
        .tint(.primary)
    }
}
