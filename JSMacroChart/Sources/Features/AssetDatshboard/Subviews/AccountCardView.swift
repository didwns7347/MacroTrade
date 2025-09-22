//
//  AssetsCardView.swift
//  JSMacroChart
//
//  Created by yangjs on 9/18/25.
//

import SwiftUI

struct AccountCardView: View {
    @StateObject private var viewModel = AccountCardViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let summary = viewModel.accountSummary {
                Text("총 자산")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("\(summary.total.formatNumber(minDigits: 0, maxDigits: 2)) ₩")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Divider()
                HStack {
                    Asset(assetType: summary.overseas.assetType,
                          totalAsset: summary.overseas.totalAsset,
                          profitAmount: summary.overseas.profitAmount,
                          profitPercent: summary.overseas.profitPercent,
                          code: summary.overseas.code)
                    Spacer()
                    Divider()
                    Spacer()
                    Asset(assetType: summary.domestic.assetType,
                          totalAsset: summary.domestic.totalAsset,
                          profitAmount: summary.domestic.profitAmount,
                          profitPercent: summary.domestic.profitPercent,
                          code: summary.domestic.code)
                }
            } else {
                ProgressView()
            }
        }
        .padding(.vertical, 8)
        .onAppear {
            viewModel.fetchData()
        }
    }
}

#Preview {
    AccountCardView()
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(10)
        .padding()
        .frame(height: 300)
}
