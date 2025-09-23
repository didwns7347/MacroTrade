//
//  StockRow.swift
//  JSMacroChart
//
//  Created by yangjs on 9/22/25.
//
import SwiftUI

struct StockRow: View {
    var stock: StockAsset
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(stock.name)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("\(stock.quantity.formatNumber(minDigits: 0, maxDigits: 2))주")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(stock.gainLoss.currencyFormatted(for: stock.assetType))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(stock.isProfit ? .red : .blue)
                    
                    Text("(\(stock.gainLossRate.formatNumber())%)")
                        .font(.subheadline)
                        .foregroundColor(stock.isProfit ? .red : .blue)
                }
            }
            
            if isExpanded {
                Divider()
                
                HStack(alignment: .top) {
                    InfoItem(label: "평가금액",
                             value: stock.totalCurrentPrice.currencyFormatted(for: stock.assetType),
                             alignment: .leading,
                             isProfit: stock.isProfit)
                    
                    Spacer()
                    
                    InfoItem(label: "현재가",
                             value: stock.currentPrice.currencyFormatted(for: stock.assetType),
                             alignment: .center,
                             isProfit: stock.isProfit)
                    
                    Spacer()
                    
                    InfoItem(label: "평균단가",
                             value: stock.avgBuyingPrice.currencyFormatted(for: stock.assetType),
                             alignment: .trailing,
                             isProfit: nil)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .onTapGesture {
            withAnimation(.spring()) {
                isExpanded.toggle()
            }
        }
    }
}

// MARK: - 상세 정보 아이템
private struct InfoItem: View {
    let label: String
    let value: String
    let alignment: HorizontalAlignment
    let isProfit : Bool?
    func color() -> Color {
        guard let isProfit = isProfit else {
            return Color.primary
        }
        if isProfit { return Color.red}
        return Color.blue
    }
    var body: some View {
        VStack(alignment: alignment, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(color())
                
        }
    }
}


#Preview {
    StockRow(
        stock: StockAsset(
            assetType: .domestic,
            name:"삼성전자",
            gainLoss: 50000,
            gainLossRate:  12.5,
            currentPrice:  85000,
            avgBuyingPrice:  80000,
            totalCurrentPrice:  425000,
            totalBuyingPrice:  400000,
            quantity: 5,
            excgCd: "KRX"
        )
    )
    .padding()
}
