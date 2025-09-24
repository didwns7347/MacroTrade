//
//  StockDayMovement.swift
//  JSMacroChart
//
//  Created by yangjs on 9/24/25.
//


struct StockDayMovement: Codable {
    let code: String // 주식 코드
    let name: String // 이름
    let type: AssetType // 해왜 또는 국내주식
    let closingPrices: [String] // 종가
}
