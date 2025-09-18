//
//  DashboardViewModel.swift
//  JSMacroChart
//
//  Created by yangjs on 9/16/25.
//

import Foundation
import SwiftUI

// MARK: - MVI Intent (사용자 의도/액션)
enum DashboardIntent {
    case viewAppeared
    case refreshRequested
    case retryRequested
    case assetSelected(UserAsset)
}

// MARK: - MVI State (뷰 상태)
struct DashboardState: Equatable {
    var viewState: ViewState
    var assets: [UserAsset]
    var totalBalance: DashboardBalance
    var lastUpdated: Date?
    var error: DashboardError?
    
    static let initial = DashboardState(
        viewState: .idle,
        assets: [],
        totalBalance: .empty,
        lastUpdated: nil,
        error: nil
    )
}

enum ViewState: Equatable {
    case idle
    case loading
    case content
    case error
    case refreshing
}

// MARK: - Domain Models (개선된 타입 시스템)
struct DashboardBalance: Equatable {
    let totalAmount: Decimal
    let totalGainLoss: Decimal
    let totalGainLossRate: Double
    let currency: Currency
    
    static let empty = DashboardBalance(
        totalAmount: 0,
        totalGainLoss: 0,
        totalGainLossRate: 0,
        currency: .krw
    )
    
    var formattedTotalAmount: String {
        currency.formatter.string(from: totalAmount as NSDecimalNumber) ?? "0"
    }
    
    var formattedGainLoss: String {
        let formatter = currency.formatter
        formatter.positivePrefix = "+"
        return formatter.string(from: totalGainLoss as NSDecimalNumber) ?? "0"
    }
    
    var gainLossColor: Color {
        if totalGainLoss > 0 { return .red }
        else if totalGainLoss < 0 { return .blue }
        else { return .gray }
    }
}

enum Currency {
    case krw, usd
    
    var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        switch self {
        case .krw:
            formatter.currencyCode = "KRW"
            formatter.minimumFractionDigits = 0
        case .usd:
            formatter.currencyCode = "USD"
            formatter.minimumFractionDigits = 2
        }
        return formatter
    }
}

// MARK: - Error Handling
enum DashboardError: LocalizedError, Equatable {
    case networkError(String)
    case authenticationError
    case dataParsingError
    case serverError(Int)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "네트워크 오류: \(message)"
        case .authenticationError:
            return "인증에 실패했습니다. 다시 로그인해주세요."
        case .dataParsingError:
            return "데이터 처리 중 오류가 발생했습니다."
        case .serverError(let code):
            return "서버 오류 (코드: \(code))"
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
    
    static func == (lhs: DashboardError, rhs: DashboardError) -> Bool {
        switch (lhs, rhs) {
        case (.networkError(let l), .networkError(let r)): return l == r
        case (.authenticationError, .authenticationError): return true
        case (.dataParsingError, .dataParsingError): return true
        case (.serverError(let l), .serverError(let r)): return l == r
        case (.unknown, .unknown): return true
        default: return false
        }
    }
}

// MARK: - MVI ViewModel
@MainActor
final class DashboardViewModel: ObservableObject {
    
    // MARK: - Published State
    @Published private(set) var state = DashboardState.initial
    
    // MARK: - Dependencies (Protocol 기반으로 개선)
    private let userAssetRepository: UserAssetRepository
    private let analyticsService: AnalyticsService?
    
    // MARK: - Private State
    private var refreshTimer: Timer?
    
    init(
        userAssetRepository: UserAssetRepository = KoreaInvestmentUserAssetRepository(),
        analyticsService: AnalyticsService? = nil
    ) {
        self.userAssetRepository = userAssetRepository
        self.analyticsService = analyticsService
        
        setupAutoRefresh()
    }
    
    deinit {
        refreshTimer?.invalidate()
    }
    
    // MARK: - Intent Handling (MVI 패턴의 핵심)
    func handle(intent: DashboardIntent) {
        switch intent {
        case .viewAppeared:
            handleViewAppeared()
            
        case .refreshRequested:
            handleRefreshRequested()
            
        case .retryRequested:
            handleRetryRequested()
            
        case .assetSelected(let asset):
            handleAssetSelected(asset)
        }
    }
}

// MARK: - Intent Handlers
private extension DashboardViewModel {
    
    func handleViewAppeared() {
        analyticsService?.track(event: "dashboard_viewed")
        
        if state.viewState == .idle {
            loadDashboardData()
        }
    }
    
    func handleRefreshRequested() {
        analyticsService?.track(event: "dashboard_refresh_requested")
        
        updateState { state in
            state.viewState = .refreshing
            state.error = nil
        }
        
        Task {
            await performDataLoad()
        }
    }
    
    func handleRetryRequested() {
        analyticsService?.track(event: "dashboard_retry_requested")
        
        updateState { state in
            state.viewState = .loading
            state.error = nil
        }
        
        Task {
            await performDataLoad()
        }
    }
    
    func handleAssetSelected(_ asset: UserAsset) {
        analyticsService?.track(event: "asset_selected", parameters: [
            "asset_type": asset.assetType == .domestic ? "domestic" : "overseas",
            "asset_name": asset.name
        ])
        
        // 여기서 상세 화면으로 네비게이션 등 처리
        // NavigationService나 Coordinator를 통해 처리하는 것이 좋음
    }
}

// MARK: - Business Logic
private extension DashboardViewModel {
    
    func loadDashboardData() {
        updateState { state in
            state.viewState = .loading
            state.error = nil
        }
        
        Task {
            await performDataLoad()
        }
    }
    
    func performDataLoad() async {
        do {
            let assets = await userAssetRepository.getUserAssets()
            let balance = calculateTotalBalance(from: assets)
            
            updateState { state in
                state.viewState = .content
                state.assets = assets
                state.totalBalance = balance
                state.lastUpdated = Date()
                state.error = nil
            }
            
        } catch let error as NSError where error.code == -1009 {
            updateState { state in
                state.viewState = .error
                state.error = .networkError("인터넷 연결을 확인해주세요.")
            }
            
        } catch let error as NSError where error.code == 401 {
            updateState { state in
                state.viewState = .error
                state.error = .authenticationError
            }
            
        } catch {
            updateState { state in
                state.viewState = .error
                state.error = .unknown
            }
        }
    }
    
    func calculateTotalBalance(from assets: [UserAsset]) -> DashboardBalance {
        var totalAmount: Decimal = 0
        var totalGainLoss: Decimal = 0
        
        for asset in assets {
            // String → Decimal 안전 변환 (기존 문제점 개선)
            if let currentPrice = Decimal(string: asset.totalCurrentPrice) {
                totalAmount += currentPrice
            }
            
            if let gainLoss = Decimal(string: asset.gainLoss) {
                totalGainLoss += gainLoss
            }
        }
        
        let gainLossRate = totalAmount > 0 ? Double(truncating: (totalGainLoss / totalAmount * 100) as NSDecimalNumber) : 0
        
        return DashboardBalance(
            totalAmount: totalAmount,
            totalGainLoss: totalGainLoss,
            totalGainLossRate: gainLossRate,
            currency: .krw
        )
    }
    
    func setupAutoRefresh() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            guard let self = self,
                  self.state.viewState == .content else { return }
            
            Task { @MainActor in
                self.handle(intent: .refreshRequested)
            }
        }
    }
}

// MARK: - State Management Helpers
private extension DashboardViewModel {
    
    func updateState(_ update: (inout DashboardState) -> Void) {
        var newState = state
        update(&newState)
        state = newState
    }
}

// MARK: - Analytics Protocol (추후 확장 가능)
protocol AnalyticsService {
    func track(event: String, parameters: [String: Any]?)
}

extension AnalyticsService {
    func track(event: String) {
        track(event: event, parameters: nil)
    }
}
