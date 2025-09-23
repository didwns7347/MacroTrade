//
//  AssetsInfo.swift
//  JSMacroChart
//
//  Created by yangjs on 9/19/25.
//
import SwiftUI
struct Asset : View {
    let assetType: AssetType
    let totalAsset: Decimal
    let profitAmount: Decimal
    let profitPercent: Float
    let code: String
    var isProfit: Bool {
        get {
            profitPercent > 0
        }
    }
    var body: some View {
        VStack(alignment: .leading) {
            Text(assetType.rawValue)
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("\(totalAsset.currencyFormatted(for: assetType))") // Placeholder for total asset
                .font(.title2)
                .fontWeight(.bold)
            
            HStack {
                Text("\(profitAmount.currencyFormatted(for: assetType)) ") // Placeholder for profit/loss amount
                    .foregroundColor(.red)
                Text("(\(profitPercent.formatNumber(minDigits: 0)))%") // Placeholder for profit/loss percentage
                    .foregroundColor(.red)
            }
            .font(.subheadline)
        }
    }
}
