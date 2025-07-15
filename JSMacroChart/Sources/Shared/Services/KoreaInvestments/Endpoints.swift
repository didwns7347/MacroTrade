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
    case fetchDailyPrice(
        token: String,
        stockCode: String,
        periodDivCode: String,
        startDate: String,
        finDate: String
    )
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
            return "/uapi/domestic-stock/v1/quotations/inquire-daily-itemchartprice"
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
        case .fetchDailyPrice(_, let stockCode, let period, let startDate, let finDate ):
            return [
                "fid_cond_mrkt_div_code": "J",
                "fid_input_iscd": stockCode,
                "fid_input_date_1": startDate,
                "fid_input_date_2": finDate,
                "fid_period_div_code": period,
                "fid_org_adj_prc":"1"
            ]
        }
    }

    var headers: [String: String]? {
        switch self {
        case .issueToken:
            return ["content-type": "application/json"]
        case .fetchDailyPrice(let token, _, _, _, _):
            return [
                "content-type": "application/json",
                "Connection" : "keep-alive",
                "Authorization": "Bearer \(token)",
                "appkey": APIKeyManager.shared.appKey,
                "appsecret": APIKeyManager.shared.appSecret,
                "tr_id": "FHKST03010100"
            ]
        }
    }

    var requestBody: Encodable? {
        switch self {
        case .issueToken:
            return [
                "grant_type": "client_credentials",
                "appkey": APIKeyManager.shared.appKey,
                "appsecret": APIKeyManager.shared.appSecret
            ]
        case .fetchDailyPrice:
            return nil
        }
    }
}
