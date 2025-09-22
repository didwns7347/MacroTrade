import Foundation
import Combine

class DashboardViewModel: ObservableObject {
    @Published var stocks: [StockAsset] = []
    func fetchStokcs() {
        
    }
}
