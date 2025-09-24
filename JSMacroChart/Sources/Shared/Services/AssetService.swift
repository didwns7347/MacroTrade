
import Foundation
import Combine

class AssetService: ObservableObject {
    @Published var stocks: [StockAsset] = []
    
    // MARK: - 임시 KoreaInvestmentUserAssetRepository 사용
    private let repository = KoreaInvestmentUserAssetRepository()

    func fetchStocks() {
        Task { @MainActor in
            stocks = await repository.getUserAssets()
        }
    }
}
