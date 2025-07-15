import Foundation


class KoreaInvestmentAPIService {
    static let shared = KoreaInvestmentAPIService()
    private let tokenManager: TokenManager
    private let networkService: NetworkService

    private init(
        networkService: NetworkService = APINetworkService.shared,
        secureStorage: SecureStorageProtocol = KeychainSecureStorage.shared
    ) {
        self.networkService = networkService
        self.tokenManager = TokenManager(networkService: networkService, secureStorage: secureStorage)
    }



    func resetToken() async {
        await tokenManager.resetToken()
    }

    /// 일별 주가 데이터를 가져옵니다.
    func fetchDailyPrice(stockCode: String, period: String = "D") async throws -> [DailyPriceInfo] {
        let token = try await tokenManager.getValidToken()
        let (start,fin) = getStartFinDates()
        let endpoint = KoreaInvestmentEndpoint.fetchDailyPrice(
            token: token,
            stockCode: stockCode,
            periodDivCode: period,
            startDate: start,
            finDate: fin
        )
        let response: StockPriceResponse = try await networkService.request(endpoint: endpoint)
        
        guard response.returnCode == "0" else {
            throw NSError(domain: "KoreaInvestmentAPI", code: Int(response.returnCode) ?? -1, userInfo: [NSLocalizedDescriptionKey: response.message])
        }
        
        return response.dailyPrices
    }
    
    private func getStartFinDates() -> (String, String) {
        return (
            Calendar.current.date(byAdding: .month, value: -2, to: Date())?.toStringYYYYMMDD() ?? "",
            Date().toStringYYYYMMDD()
        )
    }
}





