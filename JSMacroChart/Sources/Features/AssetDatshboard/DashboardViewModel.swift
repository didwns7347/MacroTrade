import Foundation
import Combine

class DashboardViewModel: ObservableObject {
    @Published var stocks: [StockAsset] = []
    func fetchStocks() {
        Task { @MainActor in
            stocks = await KoreaInvestmentUserAssetRepository().getUserAssets()
        }
    }
}
