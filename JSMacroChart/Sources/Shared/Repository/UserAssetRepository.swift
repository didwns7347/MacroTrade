//
//  UserAssetRepository.swift
//  JSMacroChart
//
//  Created by yangjs on 9/16/25.
//

import Foundation

protocol UserAssetRepository {
    func getUserAssets() async -> [StockAsset]
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
    
    func getUserAssets() async -> [StockAsset] {
        print("getUserAssets")
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
                    gainLoss: domesticStock.gainLoss,
                    gainLossRate: domesticStock.gainLossRate,
                    currentPrice: domesticStock.currentPrice,
                    avgBuyingPrice: domesticStock.avgBuyingPrice,
                    totalCurrentPrice: domesticStock.totalCurrentPrice,
                    totalBuyingPrice: domesticStock.totalBuyingPrice,
                    quantity: domesticStock.quantity,
                    excgCd: nil
                )
                userAssets.append(userAsset)
            }
            
            // 해외주식을 UserAsset으로 변환 (안전한 접근)
            for overseasStock in overseasResult.safeStockList {
                let userAsset = StockAsset(
                    assetType: .overseas,
                    ticker: overseasStock.ticker,
                    code: nil,
                    name: overseasStock.name,
                    gainLoss: overseasStock.gainLoss,
                    gainLossRate: overseasStock.gainLossRate,
                    currentPrice: overseasStock.currentPrice,
                    avgBuyingPrice: overseasStock.avgBuyingPrice,
                    totalCurrentPrice: overseasStock.totalCurrentPrice,
                    totalBuyingPrice: overseasStock.totalBuyingPrice,
                    quantity: overseasStock.quantity,
                    excgCd: overseasStock.excgCd
                )
                userAssets.append(userAsset)
            }
            
            return userAssets
            
        } catch {
            print("❌ 자산 조회 실패: \(error.localizedDescription)")
            return []
        }
    }
}
