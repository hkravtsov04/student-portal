import SwiftUI

@main
struct YourApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(appState)
        }
    }
}

