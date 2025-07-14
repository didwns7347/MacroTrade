//
//  Types.swift
//  JSMacroChart
//
//  Created by yangjs on 7/14/25.
//
import Foundation

struct IssueTokenRequestBody: Encodable {
    let grantType: String
    let appkey: String
    let appsecret: String

    enum CodingKeys: String, CodingKey {
        case grantType = "grant_type"
        case appkey
        case appsecret
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
