//
//  AssetSume.swift
//  JSMacroChart
//
//  Created by yangjs on 9/19/25.
//
import Foundation
struct AccountSummary {
    var total: Decimal
    var domestic: Account
    var overseas: Account
}

struct Account {
    let assetType: AssetType
    let totalAsset: Decimal
    let profitAmount: Decimal
    let profitPercent: Float
    let code: String
    let cashBalance: Decimal
}

