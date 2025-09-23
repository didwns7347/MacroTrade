//
//  AccountCardViewModel.swift
//  JSMacroChart
//
//  Created by yangjs on 9/19/25.
//

import Foundation

class AccountCardViewModel: ObservableObject {
    @Published var accountSummary: AccountSummary? = nil
    private let repository: UserAssetRepository
    
    init(repository: UserAssetRepository = KoreaInvestmentUserAssetRepository()) {
        self.repository = repository
    }
    
    func fetchData() {
        Task { @MainActor in
            do {
                self.accountSummary = try await repository.getAccountSummary()
            } catch {
                print("계좌 정보 패치 에러: \(error)")
            }
        }
    }
    
    
}
