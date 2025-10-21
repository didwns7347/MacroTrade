import Foundation
import Combine


@MainActor
class AgentViewModel: ObservableObject {
    @Published var reports: [StockReport] = []
    @Published var isLoading: Bool = false
    
    private let chartistAgent = ChartistAgent()
    private let fundamentalAgent = FundamentalAgent()
    
    /// assetService로부터 받은 주식 목록에 대한 리포트를 생성합니다.
    func generateReports(for stocks: [StockAsset]) {
        guard !isLoading else { return }
        
        self.isLoading = true
        self.reports = stocks.map { stock in
            // 처음에는 모든 리포트를 'loading' 상태로 초기화
            if stock.assetType == .domestic {
                StockReport(stockName: stock.name, stockCode:stock.code ?? "", isOverseas: false, status: .loading)
            } else {
                StockReport(stockName: stock.name, stockCode:stock.ticker ?? "",isOverseas: true, status: .loading)
            }
            
        }
        
        Task {
            // 각 주식에 대해 비동기적으로 리포트 생성 요청
            for i in 0..<reports.count {
                let stockCode = reports[i].stockCode
                let isOverseas = reports[i].isOverseas ? "TRUE": "FALSE"
                do {
                    // ChartistAgent를 실행하여 리포트 내용(Markdown 문자열)을 가져옴
//                    let reportContent = try await chartistAgent.execute(with: "\(isOverseas)|\(stockCode)")
                    let reportContent = try await fundamentalAgent.execute(with: "\(isOverseas)|\(stockCode)|\(reports[i].stockName)")
                    print("Done")
                    
                    // @MainActor 클래스 내부이므로 이미 메인 스레드에서 실행됨
                    var updatedReports = reports
                    updatedReports[i].status = .success(content: reportContent)
                    reports = updatedReports
                } catch {
                    // 에러 발생시에도 동일하게 처리
                    var updatedReports = reports
                    updatedReports[i].status = .failure(error: error)
                    reports = updatedReports
                }
            }
            self.isLoading = false
        }
    }
}
