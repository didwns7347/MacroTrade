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
    case fetchDomesticStockBalance(
        token: String
    )
    case fetchOverseasStockBalance(
        token: String,
        OVRS_EXCG_CD: String,
        TR_CRCY_CD: String
    )
    case fetchOverseasAccountBalance(
        token: String,
        OVRS_EXCG_CD: String
    )
}



extension KoreaInvestmentEndpoint: EndPoint {
    var baseURL: URL {
        return URL(string: APIConfigManager.shared.baseURL)!
    }

    var path: String {
        switch self {
        case .issueToken:
            return "/oauth2/tokenP"
        case .fetchDailyPrice:
            return "/uapi/domestic-stock/v1/quotations/inquire-daily-itemchartprice"
        case .fetchDomesticStockBalance:
            return "/uapi/domestic-stock/v1/trading/inquire-balance"
        case .fetchOverseasStockBalance:
            return "/uapi/overseas-stock/v1/trading/inquire-balance"
        case .fetchOverseasAccountBalance:
            return "/uapi/overseas-stock/v1/trading/inquire-psamount"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .issueToken:
            return .post

        default:
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
        case .fetchDomesticStockBalance(_):
            return [
                "CANO": APIConfigManager.shared.cano,
                "ACNT_PRDT_CD": APIConfigManager.shared.accountCode,
                "AFHR_FLPR_YN": "N",        // 시간외단일가거래소여부 (N: 기본값)
                "OFL_YN": "",               // 오프라인여부 (빈값)
                "INQR_DVSN": "02",          // 조회구분 (02: 종목별)
                "UNPR_DVSN": "01",          // 단가구분 (01)
                "FUND_STTL_ICLD_YN": "N",   // 펀드결제분포함여부 (N)
                "FNCG_AMT_AUTO_RDPT_YN": "N", // 융자금액자동상환여부 (N)
                "PRCS_DVSN": "00",          // 처리구분 (00: 전일매매포함)
                "CTX_AREA_FK100": "",       // 연속조회검색조건100
                "CTX_AREA_NK100": ""        // 연속조회키100
            ]
        case .fetchOverseasStockBalance(_, let exchangeCode, let currencyCode):
            return [
                "CANO": APIConfigManager.shared.cano,
                "ACNT_PRDT_CD": APIConfigManager.shared.accountCode,
                "OVRS_EXCG_CD": exchangeCode,   // 해외거래소코드 (NASD, NYSE, AMEX, SEHK, SHAA, SZAA, TKSE, HASE, VNSE)
                "TR_CRCY_CD": currencyCode,     // 거래통화코드 (USD, HKD, CNY, JPY, VND)
                "CTX_AREA_FK200": "",           // 연속조회검색조건200
                "CTX_AREA_NK200": ""            // 연속조회키200
            ]
            
        case .fetchOverseasAccountBalance(_, let exchangeCode):
            return [
                "CANO": APIConfigManager.shared.cano,
                "ACNT_PRDT_CD": APIConfigManager.shared.accountCode,
                "OVRS_EXCG_CD": exchangeCode,
                "OVRS_ORD_UNPR" : 1.4,
                "ITEM_CD":"TRVG"
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
                "appkey": APIConfigManager.shared.appKey,
                "appsecret": APIConfigManager.shared.appSecret,
                "tr_id": "FHKST03010100"
            ]
        case .fetchDomesticStockBalance(let token):
            let trId = APIConfigManager.shared.isDemo ? "VTTC8434R" : "TTTC8434R"
            return [
                "content-type": "application/json",
//                "Connection" : "keep-alive",
                "Authorization": "Bearer \(token)",
                "appkey": APIConfigManager.shared.appKey,
                "appsecret": APIConfigManager.shared.appSecret,
                "tr_id": trId
            ]
        case .fetchOverseasStockBalance(let token, _, _):
            let trId = APIConfigManager.shared.isDemo ? "VTTS3012R" : "TTTS3012R"
            return [
                "content-type": "application/json",
//                "Connection" : "keep-alive",
                "Authorization": "Bearer \(token)",
                "appkey": APIConfigManager.shared.appKey,
                "appsecret": APIConfigManager.shared.appSecret,
                "tr_id": trId
            ]
            
        case .fetchOverseasAccountBalance(let token, _):
            return [
                "content-type": "application/json",
//                "Connection" : "keep-alive",
                "Authorization": "Bearer \(token)",
                "appkey": APIConfigManager.shared.appKey,
                "appsecret": APIConfigManager.shared.appSecret,
                "tr_id": APIConfigManager.shared.isDemo ? "TTTS3007R" : "TTTS3007R"
            ]
        }
    }

    var requestBody: Encodable? {
        switch self {
        case .issueToken:
            return [
                "grant_type": "client_credentials",
                "appkey": APIConfigManager.shared.appKey,
                "appsecret": APIConfigManager.shared.appSecret
            ]
        default :
            return nil
        }
    }
}
