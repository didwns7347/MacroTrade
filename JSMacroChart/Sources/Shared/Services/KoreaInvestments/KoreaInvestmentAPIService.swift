import Foundation


class KoreaInvestmentAPIService {
    static let shared = KoreaInvestmentAPIService()
    private let tokenManager: TokenManager
    private let networkService: NetworkService
    enum ExchangeCode : String, Codable {
        /// 홍콩
        case HKS
        /// 뉴욕
        case NYS
        /// 나스닥
        case NAS
        /// 아멕스
        case AMS
        /// 도쿄
        case TSE
        /// 상해
        case SHS
        /// 상해지수/
        case SHI
        /// 심천
        case SZS
        /// 호치민
        case HSX
        /// 하노이
        case HNX
    }

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

    /// 국내주식 일별 주가 데이터를 가져옵니다.
    func fetchDomesticDailyPrice(stockCode: String, period: String = "D") async throws -> [DailyPriceInfo] {
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
    /// 해외주식 일별 주가 데이터를 가져옵니다.
    func fetchOverseasDailyPrice(stockCode: String, excd: ExchangeCode = .NAS ) async throws -> [OverseasDailyStockPrice] {
        let token = try await tokenManager.getValidToken()
        let endpoint = KoreaInvestmentEndpoint.fetchOverseasDailyPrice(token: token, EXCD: excd.rawValue, SYMB: stockCode)
        let response: OverseasStockPriceInfo = try await networkService.request(endpoint: endpoint)
        
        guard response.returnCode == "0" else {
            throw NSError(domain: "KoreaInvestmentAPI", code: Int(response.returnCode) ?? -1, userInfo: [NSLocalizedDescriptionKey: response.message])
        }
        return response.priceHistories
    }
    
    /// 국내주식 잔고를 조회합니다.
    func fetchDomesticStockBalance() async throws -> DomesticStockBalanceResponse {
        let token = try await tokenManager.getValidToken()
        let endpoint = KoreaInvestmentEndpoint.fetchDomesticStockBalance(
            token: token
        )
        let response: DomesticStockBalanceResponse = try await networkService.request(endpoint: endpoint)
        
        // API 에러 체크 (더 상세한 에러 처리)
        guard response.isSuccess else {
            let errorMessage = "[\(response.messageCode)] \(response.message)"
            throw NSError(
                domain: "KoreaInvestmentAPI", 
                code: Int(response.returnCode) ?? -1, 
                userInfo: [NSLocalizedDescriptionKey: errorMessage]
            )
        }
        
        return response
    }
    
    /// 해외주식 잔고를 조회합니다.
    func fetchOverseasStockBalance(
        exchangeCode: String = "NASD", // 기본값: 나스닥
        currencyCode: String = "USD"   // 기본값: 미국 달러
    ) async throws -> OverseasStockBalanceResponse {
        let token = try await tokenManager.getValidToken()
        let endpoint = KoreaInvestmentEndpoint.fetchOverseasStockBalance(
            token: token,
            OVRS_EXCG_CD: exchangeCode,
            TR_CRCY_CD: currencyCode
        )
        let response: OverseasStockBalanceResponse = try await networkService.request(endpoint: endpoint)
        
        // API 에러 체크 (더 상세한 에러 처리)
        guard response.isSuccess else {
            let errorMessage = "[\(response.messageCode)] \(response.message)"
            throw NSError(
                domain: "KoreaInvestmentAPI", 
                code: Int(response.returnCode) ?? -1, 
                userInfo: [NSLocalizedDescriptionKey: errorMessage]
            )
        }
        
        return response
    }
    
    /// 해외주식 예수금 조회
    func fetchOverseasAccountBalance() async throws -> OverseasAccountBalance {
        let token = try await tokenManager.getValidToken()
        let endpoint = KoreaInvestmentEndpoint.fetchOverseasAccountBalance(token: token, OVRS_EXCG_CD: "NASD")
        let response: OverseasAccountInfo = try await networkService.request(endpoint: endpoint)
        guard response.isSuccess else {
            let errorMessage = "[\(response.messageCode)] \(response.message)"
            throw NSError(
                domain: "KoreaInvestmentAPI",
                code: Int(response.returnCode) ?? -1,
                userInfo: [NSLocalizedDescriptionKey: errorMessage]
            )
        }
        return response.balance
    }

    
    private func getStartFinDates() -> (String, String) {
        return (
            Calendar.current.date(byAdding: .month, value: -2, to: Date())?.toStringYYYYMMDD() ?? "",
            Date().toStringYYYYMMDD()
        )
    }
}





