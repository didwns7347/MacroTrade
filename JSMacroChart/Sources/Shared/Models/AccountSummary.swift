//
//  AssetSume.swift
//  JSMacroChart
//
//  Created by yangjs on 9/19/25.
//

struct AccountSummary {
    var total: Double
    var domestic: Account
    var overseas: Account
}

struct Account {
    let assetType: String
    let totalAsset: Double
    let profitAmount: Double
    let profitPercent: Float
    let code: String
    let cashBalance: Double
}

