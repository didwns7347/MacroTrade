//
//  StockReport.swift
//  JSMacroChart
//
//  Created by yangjs on 10/21/25.
//
import Foundation
// 개별 주식 리포트 데이터를 담을 구조체
struct StockReport: Identifiable, Hashable {
    let id = UUID()
    let stockName: String
    let stockCode: String
    let isOverseas: Bool
    var status: ReportStatus
    
    // Equatable 준수를 위한 구현 - status 변화도 감지하도록 수정
    static func == (lhs: StockReport, rhs: StockReport) -> Bool {
        lhs.id == rhs.id &&
        lhs.stockName == rhs.stockName &&
        lhs.stockCode == rhs.stockCode &&
        lhs.isOverseas == rhs.isOverseas &&
        lhs.status == rhs.status
    }
    
    // Hashable 준수를 위한 구현 - id만 사용 (고유성 보장)
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

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


