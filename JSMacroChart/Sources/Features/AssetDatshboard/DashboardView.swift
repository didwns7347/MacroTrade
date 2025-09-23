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
    @StateObject var viewModel: DashboardViewModel = DashboardViewModel()

    var body : some View {
        NavigationStack {
            List {
                Section {
                    AccountCardView()
                }
                
                Section(header: Text("보유 주식")) {
                    ForEach(viewModel.stocks) { asset in
                        StockRow(stock: asset)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            //                .navigationTitle("나의 자산")
            
            
            
        }
        .onAppear {
            viewModel.fetchStocks()
        }
    }
}

// MARK: - Previews
struct AssetDashboard_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
