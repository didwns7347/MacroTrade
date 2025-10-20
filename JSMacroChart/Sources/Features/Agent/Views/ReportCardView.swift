//
//  ReportCardView.swift
//  JSMacroChart
//
//  Created by yangjs on 10/20/25.
//

import SwiftUI
struct ReportCardView: View {
    let report: StockReport
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(report.stockName)
                .font(.title2)
                .fontWeight(.bold)
            
            Divider()
            
            switch report.status {
            case .loading:
                HStack {
                    ProgressView()
                    Spacer()
                    Text("AI가 리포트를 생성하고 있습니다...")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding()
                
            case .success(let content):
                // Markdown 컨텐츠를 렌더링 (iOS 15+)
                Text(content)
                
            case .failure(let error):
                VStack(alignment: .leading) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text("리포트 생성 실패")
                        .fontWeight(.semibold)
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
#Preview {
    ReportCardView(report: .init(stockName: "AAPL", stockCode: "AAPL", isOverseas: false, status: .success(content: "test test")))
}
