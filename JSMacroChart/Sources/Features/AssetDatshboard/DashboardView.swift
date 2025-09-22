//
//  AssetDashboard.swift
//  JSMacroChart
//
//  Created by yangjs on 9/16/25.
//

import SwiftUI

// Placeholder data model
struct AssetRow: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    let profit: Double
    let profitPercentage: Double
}


// MARK: - MVI View
struct DashboardView: View {
    
    // Placeholder data
    let assets: [AssetRow] = [
        AssetRow(name: "AAPL", amount: 15000, profit: 2500, profitPercentage: 20),
        AssetRow(name: "GOOGL", amount: 28000, profit: -1200, profitPercentage: -4.1),
        AssetRow(name: "TSLA", amount: 8000, profit: 1500, profitPercentage: 23),
        AssetRow(name: "AAPL", amount: 15000, profit: 2500, profitPercentage: 20),
        AssetRow(name: "GOOGL", amount: 28000, profit: -1200, profitPercentage: -4.1),
        AssetRow(name: "TSLA", amount: 8000, profit: 1500, profitPercentage: 23),
        AssetRow(name: "AAPL", amount: 15000, profit: 2500, profitPercentage: 20),
        AssetRow(name: "GOOGL", amount: 28000, profit: -1200, profitPercentage: -4.1),
        AssetRow(name: "TSLA", amount: 8000, profit: 1500, profitPercentage: 23),
        AssetRow(name: "AAPL", amount: 15000, profit: 2500, profitPercentage: 20),
        AssetRow(name: "GOOGL", amount: 28000, profit: -1200, profitPercentage: -4.1),
        AssetRow(name: "TSLA", amount: 8000, profit: 1500, profitPercentage: 23),
    ]
    
    var body : some View {
        NavigationStack {
            List {
                Section {
                    AccountCardView()
                }
                
                Section(header: Text("보유 주식")) {
                    ForEach(assets) { asset in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(asset.name)
                                    .font(.headline)
                                Text("수량: 10") // Placeholder
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("\(String(format: "%.0f", asset.amount))원")
                                    .font(.headline)
                                Text("\(String(format: "%.2f", asset.profit))원 (\(String(format: "%.2f", asset.profitPercentage))%)")
                                    .font(.subheadline)
                                    .foregroundColor(asset.profit >= 0 ? .red : .blue)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            //                .navigationTitle("나의 자산")
            
            
            
        }
    }
}

// MARK: - Previews
struct AssetDashboard_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
