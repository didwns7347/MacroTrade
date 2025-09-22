//
//  AssetsInfo.swift
//  JSMacroChart
//
//  Created by yangjs on 9/19/25.
//
import SwiftUI
struct Asset : View {
    let assetType: String
    let totalAsset: Double
    let profitAmount: Double
    let profitPercent: Float
    let code: String
    var body: some View {
        VStack(alignment: .leading) {
            Text(assetType)
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("\(totalAsset.formatNumber(minDigits: 0)) \(code)") // Placeholder for total asset
                .font(.title2)
                .fontWeight(.bold)
            
            HStack {
                Text("\(profitAmount.formatNumber(minDigits: 0)) \(code)") // Placeholder for profit/loss amount
                    .foregroundColor(.red)
                Text("(\(profitPercent.formatNumber(minDigits: 0)))%") // Placeholder for profit/loss percentage
                    .foregroundColor(.red)
            }
            .font(.subheadline)
        }
    }
}
