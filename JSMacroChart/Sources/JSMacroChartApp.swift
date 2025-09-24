import SwiftUI

@main
struct JSMacroChartApp: App {
    @StateObject private var assetService = AssetService()

    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environmentObject(assetService)
        }
    }
}
