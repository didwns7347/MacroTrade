import Foundation

// MARK: - Stock Price Response
struct StockPriceResponse: Decodable {
    let currentPriceInfo: CurrentPriceInfo
    let dailyPrices: [DailyPriceInfo]
    let returnCode: String
    let messageCode: String
    let message: String

    enum CodingKeys: String, CodingKey {
        case currentPriceInfo = "output1"
        case dailyPrices = "output2"
        case returnCode = "rt_cd"
        case messageCode = "msg_cd"
        case message = "msg1"
    }
}

// MARK: - Current Price Info
struct CurrentPriceInfo: Decodable {
    let previousDayComparison: String
    let previousDaySign: String
    let previousDayContrastRatio: String
    let previousDayClosingPrice: String
    let accumulatedVolume: String
    let accumulatedTradePayment: String
    let htsKoreanStockName: String
    let stockPrice: String
    let stockShortCode: String
    let previousDayVolume: String
    let stockMaxPrice: String
    let stockMinPrice: String
    let stockOpeningPrice: String
    let stockHighPrice: String
    let stockLowPrice: String
    let previousDayOpeningPrice: String
    let previousDayHighPrice: String
    let previousDayLowPrice: String
    let askPrice: String
    let bidPrice: String
    let previousDayVolumeChange: String
    let volumeTurnoverRate: String
    let stockFaceValue: String
    let listedStockCount: String
    let capital: String
    let htsAvailableVolume: String
    let per: String
    let eps: String
    let pbr: String
    let itewholLoanRmndRateName: String

    enum CodingKeys: String, CodingKey {
        case previousDayComparison = "prdy_vrss"
        case previousDaySign = "prdy_vrss_sign"
        case previousDayContrastRatio = "prdy_ctrt"
        case previousDayClosingPrice = "stck_prdy_clpr"
        case accumulatedVolume = "acml_vol"
        case accumulatedTradePayment = "acml_tr_pbmn"
        case htsKoreanStockName = "hts_kor_isnm"
        case stockPrice = "stck_prpr"
        case stockShortCode = "stck_shrn_iscd"
        case previousDayVolume = "prdy_vol"
        case stockMaxPrice = "stck_mxpr"
        case stockMinPrice = "stck_llam"
        case stockOpeningPrice = "stck_oprc"
        case stockHighPrice = "stck_hgpr"
        case stockLowPrice = "stck_lwpr"
        case previousDayOpeningPrice = "stck_prdy_oprc"
        case previousDayHighPrice = "stck_prdy_hgpr"
        case previousDayLowPrice = "stck_prdy_lwpr"
        case askPrice = "askp"
        case bidPrice = "bidp"
        case previousDayVolumeChange = "prdy_vrss_vol"
        case volumeTurnoverRate = "vol_tnrt"
        case stockFaceValue = "stck_fcam"
        case listedStockCount = "lstn_stcn"
        case capital = "cpfn"
        case htsAvailableVolume = "hts_avls"
        case per = "per"
        case eps = "eps"
        case pbr = "pbr"
        case itewholLoanRmndRateName = "itewhol_loan_rmnd_ratem name"
    }
}

// MARK: - Daily Price Info
struct DailyPriceInfo: Decodable {
    let businessDate: String
    let closingPrice: String
    let openingPrice: String
    let highPrice: String
    let lowPrice: String
    let accumulatedVolume: String
    let accumulatedTradePayment: String
    let fallingClosingCode: String
    let protectionRate: String
    let modificationYN: String
    let previousDaySign: String
    let previousDayComparison: String
    let revaluationIssueReason: String

    enum CodingKeys: String, CodingKey {
        case businessDate = "stck_bsop_date"
        case closingPrice = "stck_clpr"
        case openingPrice = "stck_oprc"
        case highPrice = "stck_hgpr"
        case lowPrice = "stck_lwpr"
        case accumulatedVolume = "acml_vol"
        case accumulatedTradePayment = "acml_tr_pbmn"
        case fallingClosingCode = "flng_cls_code"
        case protectionRate = "prtt_rate"
        case modificationYN = "mod_yn"
        case previousDaySign = "prdy_vrss_sign"
        case previousDayComparison = "prdy_vrss"
        case revaluationIssueReason = "revl_issu_reas"
    }
}


struct TokenResponse: Decodable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    let tokenExpiredAt: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case tokenExpiredAt = "access_token_token_expired"
    }
}

// MARK: - 국내주식 잔고조회 응답
struct DomesticStockBalanceResponse: Decodable {
    let stockList: [DomesticStockInfo]?  // ⭐ Optional - 에러시 nil
    let accountSummary: [DomesticAccountSummaryResponse]?  // ⭐ Optional - 에러시 nil
    let returnCode: String
    let messageCode: String
    let message: String

    enum CodingKeys: String, CodingKey {
        case stockList = "output1"
        case accountSummary = "output2"
        case returnCode = "rt_cd"
        case messageCode = "msg_cd"
        case message = "msg1"
    }
    
    // 성공/실패 판별
    var isSuccess: Bool {
        returnCode == "0"
    }
    


}

// MARK: - 해외주식 잔고조회 응답
struct OverseasStockBalanceResponse: Decodable {
    let stockList: [OverseasStockInfo]?  // ⭐ Optional - 에러시 nil
    let accountSummary: OverseasAccountSummaryResponse?  // ⭐ Optional - 에러시 nil
    let returnCode: String
    let messageCode: String
    let message: String

    enum CodingKeys: String, CodingKey {
        case stockList = "output1"
        case accountSummary = "output2"
        case returnCode = "rt_cd"
        case messageCode = "msg_cd"
        case message = "msg1"
    }
    
    // 성공/실패 판별
    var isSuccess: Bool {
        returnCode == "0"
    }
    
    // 안전한 데이터 접근
    var safeStockList: [OverseasStockInfo] {
        stockList ?? []
    }

}


struct OverseasStockInfo : Codable {
    let ticker: String // 주식 티커
    let name: String // 주식 명
    let gainLoss: String // 손익 금액
    let gainLossRate: String // 손익 비율
    let currentPrice : String // 현재 주식 1개 가격
    let avgBuyingPrice : String // 평균 매입 금액
    let totalCurrentPrice: String // 해외주식 평가금 금액
    let totalBuyingPrice: String // 해외주식 매입 금액
    let quantity: String // 수량
    let excgCd: String // 거래소 코드
    
    enum CodingKeys : String, CodingKey {
        case ticker = "ovrs_pdno"
        case name = "ovrs_item_name"
        case gainLoss = "frcr_evlu_pfls_amt"
        case gainLossRate = "evlu_pfls_rt"
        case currentPrice = "now_pric2"
        case avgBuyingPrice = "pchs_avg_pric"
        case totalCurrentPrice = "frcr_pchs_amt1"
        case totalBuyingPrice = "ovrs_stck_evlu_amt"
        case quantity = "ovrs_cblc_qty"
        case excgCd = "ovrs_excg_cd"
    }
    
}
struct DomesticStockInfo : Codable {
    let code: String? // 주식 코드
    let name: String // 주식 명
    let gainLoss: String // 손익 금액
    let gainLossRate: String // 손익 비율
    let currentPrice : String // 현재 주식 1개 가격
    let avgBuyingPrice : String // 평균 매입 금액
    let totalCurrentPrice: String // 해외주식 평가금 금액
    let totalBuyingPrice: String // 해외주식 매입 금액
    let quantity: String // 수량
//    let excgCd: String // 거래소 코드
    
    enum CodingKeys : String, CodingKey {
        case code = "pdno"
        case name = "prdt_name"
        case gainLoss = "evlu_pfls_amt"
        case gainLossRate = "evlu_pfls_rt"
        case currentPrice = "prpr"
        case avgBuyingPrice = "pchs_avg_pric"
        case totalCurrentPrice = "evlu_amt"
        case totalBuyingPrice = "pchs_amt"
        case quantity = "hldg_qty"
//        case excgCd = "ovrs_excg_cd"
    }
}

struct DomesticAccountSummaryResponse : Codable {
    let totalAmount: String
    let totalGainLoss: String
    let totalGainLossRate: String
    let orderableCash: String
    enum CodingKeys : String, CodingKey {
        case totalAmount = "bfdy_tot_asst_evlu_amt"
        case totalGainLoss = "asst_icdc_amt"
        case totalGainLossRate = "asst_icdc_erng_rt"
        case orderableCash = "dnca_tot_amt"
    }
}

struct OverseasAccountSummaryResponse : Codable {
    let totalAmount: String // 총평가 금액
    let totalGainLoss: String // 수익금
    let totalGainLossRate: String // 수익률
    enum CodingKeys : String, CodingKey {
        case totalAmount = "frcr_pchs_amt1"
        case totalGainLoss = "ovrs_tot_pfls"
        case totalGainLossRate = "tot_pftrt"
    }
}

struct OverseasAccountInfo: Codable {
    let balance: OverseasAccountBalance
    
    let returnCode: String
    let messageCode: String
    let message: String
    enum CodingKeys : String, CodingKey {
        case balance = "output"
        case returnCode = "rt_cd"
        case messageCode = "msg_cd"
        case message = "msg1"
    }
    // 성공/실패 판별
    var isSuccess: Bool {
        returnCode == "0"
    }
}
struct OverseasAccountBalance: Codable {
    let currencyCode : String
    let orderableCash : String
    let exchangeRate : String
    
    enum CodingKeys : String, CodingKey {
        case currencyCode = "tr_crcy_cd"
        case orderableCash = "ord_psbl_frcr_amt"
        case exchangeRate = "exrt"
    }
}

struct DomesticAccountInfo: Codable {
    let balance: DomesticAccountBalance
    let returnCode: String
    let messageCode: String
    let message: String
    enum CodingKeys : String, CodingKey {
        case balance = "output"
        case returnCode = "rt_cd"
        case messageCode = "msg_cd"
        case message = "msg1"
    }
    // 성공/실패 판별
    var isSuccess: Bool {
        returnCode == "0"
    }
}

struct DomesticAccountBalance: Codable {
    let cash: String
}
