//
//  UserAsset.swift
//  JSMacroChart
//
//  Created by yangjs on 9/16/25.
//



enum AssetType {
    case domestic // 국내주식
    case overseas // 해외주식
}

struct UserAsset {
    var assetType: AssetType
    var ticker: String?
    var code: String?
    let name: String // 주식 명
    let gainLoss: String // 손익 금액
    let gainLossRate: String // 손익 비율
    let currentPrice : String // 현재 주식 1개 가격
    let avgBuyingPrice : String // 평균 매입 금액
    let totalCurrentPrice: String // 해외주식 평가금 금액
    let totalBuyingPrice: String // 해외주식 매입 금액
    let quantity: String // 수량
    let excgCd: String? // 거래소 코드
}
