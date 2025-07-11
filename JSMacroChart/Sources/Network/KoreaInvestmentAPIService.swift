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

// MARK: - API Response Models

struct TokenResponse: Decodable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
    }
}

struct DailyPriceResponse: Decodable {
    let output: [DailyPriceData]
    let rtCd: String // 0: 성공, 1: 실패
    let msg1: String

    enum CodingKeys: String, CodingKey {
        case output = "output"
        case rtCd = "rt_cd"
        case msg1
    }
}

struct DailyPriceData: Decodable {
    let date: String // 날짜 (YYYYMMDD)
    let open: String   // 시가
    let high: String   // 고가
    let low: String    // 저가
    let close: String  // 종가

    enum CodingKeys: String, CodingKey {
        case date = "stck_bsop_date"
        case open = "stck_oprc"
        case high = "stck_hgpr"
        case low = "stck_lwpr"
        case close = "stck_clpr"
    }
}

// MARK: - Korea Investment API Service

class KoreaInvestmentAPIService {
    static let shared = KoreaInvestmentAPIService()
    private let keys = APIKeyManager.shared
    private var accessToken: String?

    private init() {}

    /// API 인증 토큰을 발급받습니다.
    private func issueToken() async throws -> String {
        let url = URL(string: "\(keys.baseURL)/oauth2/tokenP")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")

        let requestBody: [String: Any] = [
            "grant_type": "client_credentials",
            "appkey": keys.appKey,
            "appsecret": keys.appSecret
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(TokenResponse.self, from: data)
        self.accessToken = decoded.accessToken
        return decoded.accessToken
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
        let url = URL(string: "\(keys.baseURL)/uapi/domestic-stock/v1/quotations/inquire-daily-price")!
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "FID_COND_MRKT_DIV_CODE", value: "J"), // 주식
            URLQueryItem(name: "FID_INPUT_ISCD", value: symbol),
            URLQueryItem(name: "FID_PERIOD_DIV_CODE", value: period), // D: 일, W: 주, M: 월
            URLQueryItem(name: "FID_ORG_ADJ_PRC", value: "1") // 수정주가
        ]

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "content-type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "authorization")
        request.setValue(keys.appKey, forHTTPHeaderField: "appkey")
        request.setValue(keys.appSecret, forHTTPHeaderField: "appsecret")
        request.setValue("FHKST01010400", forHTTPHeaderField: "tr_id") // 거래 ID

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        print("\(data.toPrettyPrintedJSONString ?? "(no JSON)")")
        let decoded = try JSONDecoder().decode(DailyPriceResponse.self, from: data)
        guard decoded.rtCd == "0" else {
            throw NSError(domain: "KoreaInvestmentAPI", code: Int(decoded.rtCd) ?? -1, userInfo: [NSLocalizedDescriptionKey: decoded.msg1])
        }
        
        return decoded.output
    }
}
