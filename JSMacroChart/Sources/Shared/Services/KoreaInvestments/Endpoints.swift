//
//  Endpoint.swift
//  JSMacroChart
//
//  Created by yangjs on 7/14/25.
//
import Foundation

// MARK: - Korea Investment Endpoint
enum KoreaInvestmentEndpoint {
    case issueToken
    case fetchDailyPrice(token: String, symbol: String, period: String)
}

extension KoreaInvestmentEndpoint: EndPoint {
    var baseURL: URL {
        return URL(string: APIKeyManager.shared.baseURL)!
    }

    var path: String {
        switch self {
        case .issueToken:
            return "/oauth2/tokenP"
        case .fetchDailyPrice:
            return "/uapi/domestic-stock/v1/quotations/inquire-daily-price"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .issueToken:
            return .post
        case .fetchDailyPrice:
            return .get
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .issueToken:
            return nil
        case .fetchDailyPrice(_, let symbol, let period):
            return [
                "FID_COND_MRKT_DIV_CODE": "J",
                "FID_INPUT_ISCD": symbol,
                "FID_PERIOD_DIV_CODE": period,
                "FID_ORG_ADJ_PRC": "1"
            ]
        }
    }

    var headers: [String: String]? {
        switch self {
        case .issueToken:
            return ["content-type": "application/json"]
        case .fetchDailyPrice(let token, _, _):
            return [
                "content-type": "application/json; charset=utf-8",
                "authorization": "Bearer \(token)",
                "appkey": APIKeyManager.shared.appKey,
                "appsecret": APIKeyManager.shared.appSecret,
                "tr_id": "FHKST01010400"
            ]
        }
    }

    var requestBody: Encodable? {
        switch self {
        case .issueToken:
            return IssueTokenRequestBody(
                grantType: "client_credentials",
                appkey: APIKeyManager.shared.appKey,
                appsecret: APIKeyManager.shared.appSecret
            )
        case .fetchDailyPrice:
            return nil
        }
    }
}
