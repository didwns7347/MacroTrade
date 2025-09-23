//
//  UserAsset.swift
//  JSMacroChart
//
//  Created by yangjs on 9/16/25.
//
import Foundation


enum AssetType: String {
    case domestic = "국내 주식"  // 국내주식
    case overseas = "해외 주식" // 해외주식
}

struct StockAsset: Identifiable {
    var id: String {
        return "\(name)_\(code ?? "")_\(ticker ?? "")"
    }
    var isProfit: Bool {
        return gainLoss > 0
    }
    
    var assetType: AssetType
    var ticker: String?
    var code: String?
    let name: String // 주식 명
    let gainLoss: Decimal // 손익 금액
    let gainLossRate: Float // 손익 비율
    let currentPrice : Decimal // 현재 주식 1개 가격
    let avgBuyingPrice : Decimal // 평균 매입 금액
    let totalCurrentPrice: Decimal // 해외주식 평가금 금액
    let totalBuyingPrice: Decimal // 해외주식 매입 금액
    let quantity: Float // 수량
    let excgCd: String? // 거래소 코드
    
  
}
