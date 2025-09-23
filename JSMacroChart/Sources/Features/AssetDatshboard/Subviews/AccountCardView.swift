//
//  AssetsCardView.swift
//  JSMacroChart
//
//  Created by yangjs on 9/18/25.
//

import SwiftUI

struct AccountCardView: View {
    @StateObject private var viewModel = AccountCardViewModel()
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let summary = viewModel.accountSummary {
                HStack {
                    VStack(alignment: .leading) {
                        Text("총 자산")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("\(summary.total.currencyFormatted(for: .domestic))")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        isExpanded.toggle()
                    }
                }
                
                if isExpanded {
                    Divider()
                    HStack {
                        Asset(assetType: summary.overseas.assetType,
                              totalAsset: summary.overseas.totalAsset,
                              profitAmount: summary.overseas.profitAmount,
                              profitPercent: summary.overseas.profitPercent,
                              code: summary.overseas.code)
                        .frame(maxWidth: .infinity)
                        Divider()
                        Asset(assetType: summary.domestic.assetType,
                              totalAsset: summary.domestic.totalAsset,
                              profitAmount: summary.domestic.profitAmount,
                              profitPercent: summary.domestic.profitPercent,
                              code: summary.domestic.code)
                        .frame(maxWidth: .infinity)
                    }
                    .transition(.asymmetric(insertion: .opacity.combined(with: .move(edge: .top)), removal: .opacity))
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .onAppear {
            if viewModel.accountSummary == nil {
                viewModel.fetchData()
            }
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
