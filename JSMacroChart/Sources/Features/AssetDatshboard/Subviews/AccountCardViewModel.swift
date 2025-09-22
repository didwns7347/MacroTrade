//
//  AccountCardViewModel.swift
//  JSMacroChart
//
//  Created by yangjs on 9/19/25.
//

import Foundation

class AccountCardViewModel: ObservableObject {
    @Published var accountSummary: AccountSummary? = nil
    
    func fetchData() {
        Task { @MainActor in
            do {
                let overseasAccount = try await KoreaInvestmentAPIService.shared.fetchOverseasAccountBalance()
                let overseasStock = try await KoreaInvestmentAPIService.shared.fetchOverseasStockBalance()
                let domesticAccount = try await KoreaInvestmentAPIService.shared.fetchDomesticStockBalance()
                let domesticAccountSummary = domesticAccount.accountSummary?.first
                let exchangeRate = Double(overseasAccount.exchangeRate) ?? 1390
                let domestic = Account(
                    assetType: "국내",
                    totalAsset: Double(domesticAccountSummary?.totalAmount ?? "0") ?? 0.0,
                    profitAmount: Double(domesticAccountSummary?.totalGainLoss ?? "0") ?? 0,
                    profitPercent: Float(domesticAccountSummary?.totalGainLossRate ?? "0.0") ?? 0.0,
                    code: "₩",
                    cashBalance: Double(domesticAccountSummary?.orderableCash ?? "0.0")  ?? 0.0
                )
                let osOderableCash = Double(overseasAccount.orderableCash) ?? 0.0
                let osTotalAmount: Double = Double(overseasStock.accountSummary?.totalAmount ?? "0.0") ?? 0.0
                let overseas = Account(
                    assetType: "해외",
                    totalAsset: osTotalAmount + osOderableCash,
                    profitAmount: Double(overseasStock.accountSummary?.totalGainLoss ?? "0") ?? 0,
                    profitPercent: Float(overseasStock.accountSummary?.totalGainLossRate ?? "0.0") ?? 0.0,
                    code: "$",
                    cashBalance: osOderableCash
                )
                
                let total = domestic.totalAsset + (overseas.totalAsset * exchangeRate)
                
                self.accountSummary = AccountSummary(total: total, domestic: domestic, overseas: overseas)
            } catch {
                print("계좌 정보 패치 에러: \(error)")
            }
        }
    }
}
