//
//  UserAssetRepository.swift
//  JSMacroChart
//
//  Created by yangjs on 9/16/25.
//

import Foundation

protocol UserAssetRepository {
    func getUserAssets() async -> [StockAsset]
    func getAccountSummary() async throws -> AccountSummary
}

/*
 한국투자증권 API를 활용해 유저 해외/국내 자산 정보 조회.
 */
struct KoreaInvestmentUserAssetRepository: UserAssetRepository {

    
    private let apiService: KoreaInvestmentAPIService
    
    // TODO: 계좌번호 설정을 별도 Config나 UserDefaults에서 관리하도록 개선 필요
    private let accountNumber: String = "81234567" // 임시 계좌번호 (8자리)
    private let accountProductCode: String = "01"   // 임시 계좌상품코드 (2자리)
    
    init(apiService: KoreaInvestmentAPIService = .shared) {
        self.apiService = apiService
    }
    
    func getAccountSummary() async throws -> AccountSummary {
        async let overseasAccountFetch = apiService.fetchOverseasAccountBalance()
        async let overseasStockFetch = apiService.fetchOverseasStockBalance()
        async let domesticAccountFetch = apiService.fetchDomesticStockBalance()
        
        let (overseasAccount, overseasStock, domesticAccount) = try await (overseasAccountFetch, overseasStockFetch, domesticAccountFetch)
        
        let domesticAccountSummary = domesticAccount.accountSummary?.first
        let exchangeRate = Decimal(string:overseasAccount.exchangeRate) ?? 1390
        
        let domestic = Account(
            assetType: .domestic,
            totalAsset: Decimal(string:domesticAccountSummary?.totalAmount ?? "0") ?? 0.0,
            profitAmount: Decimal(string:domesticAccountSummary?.totalGainLoss ?? "0") ?? 0,
            profitPercent: Float(domesticAccountSummary?.totalGainLossRate ?? "0.0") ?? 0.0,
            code: "₩",
            cashBalance: Decimal(string:domesticAccountSummary?.orderableCash ?? "0.0")  ?? 0.0
        )
        
        let osOrderableCash = Decimal(string:overseasAccount.orderableCash) ?? 0.0
        let osTotalAmount: Decimal = Decimal(string: overseasStock.accountSummary?.totalAmount ?? "0.0") ?? 0.0
        
        let overseas = Account(
            assetType: .overseas,
            totalAsset: osTotalAmount + osOrderableCash,
            profitAmount: Decimal(string:overseasStock.accountSummary?.totalGainLoss ?? "0") ?? 0,
            profitPercent: Float(overseasStock.accountSummary?.totalGainLossRate ?? "0.0") ?? 0.0,
            code: "$",
            cashBalance: osOrderableCash
        )
        
        let total = domestic.totalAsset + (overseas.totalAsset * exchangeRate)
        
        return AccountSummary(total: total, domestic: domestic, overseas: overseas)
    }
    
    func getUserAssets() async -> [StockAsset] {
//        print("getUserAssets")
        do {
            // 동시에 국내/해외 주식 잔고 조회
            async let domesticResponse = apiService.fetchDomesticStockBalance()
            
            async let overseasResponse = apiService.fetchOverseasStockBalance(
                exchangeCode: "NASD", // 나스닥
                currencyCode: "USD"   // 미국 달러
            )
            
            let domesticResult = try await domesticResponse
            let overseasResult = try await overseasResponse
            
            var userAssets: [StockAsset] = []
            
            // 국내주식을 UserAsset으로 변환 (안전한 접근)
            for domesticStock in domesticResult.stockList ?? [] {
                let userAsset = StockAsset(
                    assetType: .domestic,
                    ticker: nil,
                    code: domesticStock.code,
                    name: domesticStock.name,
                    gainLoss: domesticStock.gainLoss.getDecimalValue() ?? 0.0,
                    gainLossRate: domesticStock.gainLossRate.getFloatValue() ?? 0.0,
                    currentPrice: domesticStock.currentPrice.getDecimalValue() ?? 0.0,
                    avgBuyingPrice: domesticStock.avgBuyingPrice.getDecimalValue() ?? 0.0,
                    totalCurrentPrice: domesticStock.totalCurrentPrice.getDecimalValue() ?? 0.0,
                    totalBuyingPrice: domesticStock.totalBuyingPrice.getDecimalValue() ?? 0.0,
                    quantity: domesticStock.quantity.getFloatValue() ?? 0.0,
                    excgCd: nil
                )
                userAssets.append(userAsset)
            }
            print(userAssets)
            // 해외주식을 UserAsset으로 변환 (안전한 접근)
            for overseasStock in overseasResult.safeStockList {
                let userAsset = StockAsset(
                    assetType: .overseas,
                    ticker: overseasStock.ticker,
                    code: nil,
                    name: overseasStock.name,
                    gainLoss: overseasStock.gainLoss.getDecimalValue() ?? 0.0,
                    gainLossRate: overseasStock.gainLossRate.getFloatValue() ?? 0.0,
                    currentPrice: overseasStock.currentPrice.getDecimalValue() ?? 0.0,
                    avgBuyingPrice: overseasStock.avgBuyingPrice.getDecimalValue() ?? 0.0,
                    totalCurrentPrice: overseasStock.totalCurrentPrice.getDecimalValue() ?? 0.0,
                    totalBuyingPrice: overseasStock.totalBuyingPrice.getDecimalValue() ?? 0.0,
                    quantity: overseasStock.quantity.getFloatValue() ?? 0.0,
                    excgCd: overseasStock.excgCd
                )
                userAssets.append(userAsset)
            }
            print(userAssets)
            return userAssets
            
        } catch {
            print("❌ 자산 조회 실패: \(error.localizedDescription)")
            return []
        }
    }
}
