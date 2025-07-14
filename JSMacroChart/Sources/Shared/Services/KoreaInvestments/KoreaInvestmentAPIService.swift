import Foundation

// MARK: - API Key Manager

/// Info.plist에서 한국투자증권 API 관련 키를 로드하고 관리하는 구조체
struct APIKeyManager {
    static let shared = APIKeyManager()

    let appKey: String
    let appSecret: String
    let baseURL: String

    private init() {
        guard let appKey = Bundle.main.object(forInfoDictionaryKey: "APP_KEY") as? String,
              let appSecret = Bundle.main.object(forInfoDictionaryKey: "APP_SECRET") as? String,
              let baseURL = Bundle.main.object(forInfoDictionaryKey: "URL_BASE") as? String else {
            fatalError("API 키가 Info.plist에 설정되지 않았습니다.")
        }
        self.appKey = appKey
        self.appSecret = appSecret
        self.baseURL = baseURL
    }
}


// MARK: - Korea Investment API Service
class KoreaInvestmentAPIService {
    static let shared = KoreaInvestmentAPIService()
    private let keys = APIKeyManager.shared
    private var accessToken: String?
    private let networkService: NetworkService

    private init(networkService: NetworkService = APINetworkService()) {
        self.networkService = networkService
    }

    /// API 인증 토큰을 발급받습니다.
    private func issueToken() async throws -> String {
        let endpoint = KoreaInvestmentEndpoint.issueToken
        let response: TokenResponse = try await networkService.request(endpoint: endpoint)
        self.accessToken = response.accessToken
        return response.accessToken
    }

    /// 유효한 토큰을 가져옵니다. 없거나 만료되었다면 새로 발급받습니다.
    private func getValidToken() async throws -> String {
        // TODO: 실제로는 토큰 만료 시간을 체크하고 필요할 때만 재발급해야 합니다.
        // 지금은 단순화를 위해 매번 새로 발급받도록 구현합니다.
        return try await issueToken()
    }

    /// 일별 주가 데이터를 가져옵니다.
    func fetchDailyPrice(symbol: String, period: String = "D") async throws -> [DailyPriceData] {
        let token = try await getValidToken()
        let endpoint = KoreaInvestmentEndpoint.fetchDailyPrice(token: token, symbol: symbol, period: period)
        let response: DailyPriceResponse = try await networkService.request(endpoint: endpoint)
        
        guard response.rtCd == "0" else {
            throw NSError(domain: "KoreaInvestmentAPI", code: Int(response.rtCd) ?? -1, userInfo: [NSLocalizedDescriptionKey: response.msg1])
        }
        
        return response.output
    }
}



