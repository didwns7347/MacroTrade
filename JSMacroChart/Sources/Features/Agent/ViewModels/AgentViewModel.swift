import Foundation
import Combine

// 리포트의 상태를 나타내는 열거형
enum ReportStatus: Equatable {
    case loading
    case success(content: String)
    case failure(error: Error)
    
    static func == (lhs: ReportStatus, rhs: ReportStatus) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.success(let content1), .success(let content2)):
            return content1 == content2
        case (.failure(let error1), .failure(let error2)):
            return error1.localizedDescription == error2.localizedDescription
        default:
            return false
        }
    }
}

// 개별 주식 리포트 데이터를 담을 구조체
struct StockReport: Identifiable, Hashable {
    let id = UUID()
    let stockName: String
    let stockCode: String
    let isOverseas: Bool
    var status: ReportStatus
    
    // Hashable 준수를 위한 구현
    static func == (lhs: StockReport, rhs: StockReport) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

@MainActor
class AgentViewModel: ObservableObject {
    @Published var reports: [StockReport] = []
    @Published var isLoading: Bool = false
    
    private let chartistAgent = ChartistAgent()
    
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
                    
                    let reportContent = try await chartistAgent.execute(with: "\(isOverseas)|\(stockCode)")
                    print("Done")
                    
                    // 배열 요소를 직접 수정하는 대신 새 배열을 생성하여 @Published 트리거
                    var updatedReports = reports
                    updatedReports[i].status = .success(content: reportContent)
                    reports = updatedReports
                } catch {
                    // 에러 발생시에도 같은 방식으로 배열 업데이트
                    var updatedReports = reports
                    updatedReports[i].status = .failure(error: error)
                    reports = updatedReports
                }
            }
            self.isLoading = false
        }
    }
}
