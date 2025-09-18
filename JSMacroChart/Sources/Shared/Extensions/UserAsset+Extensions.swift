//
//  UserAsset+Extensions.swift
//  JSMacroChart
//
//  Created by yangjs on 9/16/25.
//

import Foundation

// MARK: - UserAsset 타입 안전성 개선
extension UserAsset {
    
    // MARK: - 안전한 숫자 변환 (String → Decimal/Double)
    var safeCurrentPrice: Decimal? {
        Decimal(string: currentPrice)
    }
    
    var safeAvgBuyingPrice: Decimal? {
        Decimal(string: avgBuyingPrice)
    }
    
    var safeTotalCurrentPrice: Decimal? {
        Decimal(string: totalCurrentPrice)
    }
    
    var safeTotalBuyingPrice: Decimal? {
        Decimal(string: totalBuyingPrice)
    }
    
    var safeGainLoss: Decimal? {
        Decimal(string: gainLoss)
    }
    
    var safeGainLossRate: Double? {
        Double(gainLossRate.replacingOccurrences(of: "%", with: ""))
    }
    
    var safeQuantity: Decimal? {
        Decimal(string: quantity)
    }
    
    // MARK: - 포맷된 표시 문자열
    var formattedCurrentPrice: String {
        guard let price = safeCurrentPrice else { return currentPrice }
        return price.currencyFormatted(for: assetType)
    }
    
    var formattedTotalValue: String {
        guard let total = safeTotalCurrentPrice else { return totalCurrentPrice }
        return total.currencyFormatted(for: assetType)
    }
    
    var formattedGainLoss: String {
        guard let gainLoss = safeGainLoss else { return gainLoss }
        let formatted = gainLoss.currencyFormatted(for: assetType)
        return gainLoss >= 0 ? "+\(formatted)" : formatted
    }
    
    var formattedGainLossRate: String {
        guard let rate = safeGainLossRate else { return gainLossRate }
        let sign = rate >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", rate))%"
    }
    
    // MARK: - 비즈니스 로직
    var isProfit: Bool {
        (safeGainLoss ?? 0) > 0
    }
    
    var isLoss: Bool {
        (safeGainLoss ?? 0) < 0
    }
    
    var profitLossPercentage: Double {
        safeGainLossRate ?? 0
    }
    
    // MARK: - 식별자
    var identifier: String {
        switch assetType {
        case .domestic:
            return code ?? name
        case .overseas:
            return ticker ?? name
        }
    }
    
    // MARK: - 유효성 검증
    var isValid: Bool {
        !name.isEmpty &&
        safeCurrentPrice != nil &&
        safeQuantity != nil &&
        safeQuantity! > 0
    }
}

// MARK: - Decimal 확장 (통화 포맷팅)
private extension Decimal {
    func currencyFormatted(for assetType: AssetType) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        switch assetType {
        case .domestic:
            formatter.currencyCode = "KRW"
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 0
        case .overseas:
            formatter.currencyCode = "USD"
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 4
        }
        
        return formatter.string(from: self as NSDecimalNumber) ?? "\(self)"
    }
}

// MARK: - UserAsset Equatable 구현
extension UserAsset: Equatable {
    static func == (lhs: UserAsset, rhs: UserAsset) -> Bool {
        return lhs.identifier == rhs.identifier &&
               lhs.assetType == rhs.assetType &&
               lhs.name == rhs.name &&
               lhs.currentPrice == rhs.currentPrice &&
               lhs.quantity == rhs.quantity
    }
}

// MARK: - UserAsset Hashable 구현 (ForEach에서 id로 사용 가능)
extension UserAsset: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
        hasher.combine(assetType)
        hasher.combine(name)
    }
}

// MARK: - 컬렉션 확장
extension Array where Element == UserAsset {
    
    var domesticAssets: [UserAsset] {
        filter { $0.assetType == .domestic }
    }
    
    var overseasAssets: [UserAsset] {
        filter { $0.assetType == .overseas }
    }
    
    var totalValue: Decimal {
        compactMap { $0.safeTotalCurrentPrice }.reduce(0, +)
    }
    
    var totalGainLoss: Decimal {
        compactMap { $0.safeGainLoss }.reduce(0, +)
    }
    
    var totalGainLossRate: Double {
        let totalCurrent = totalValue
        let totalGain = totalGainLoss
        
        guard totalCurrent > 0 else { return 0 }
        
        return Double(truncating: (totalGain / totalCurrent * 100) as NSDecimalNumber)
    }
    
    var validAssets: [UserAsset] {
        filter { $0.isValid }
    }
    
    func sortedByValue(ascending: Bool = false) -> [UserAsset] {
        sorted { lhs, rhs in
            let lhsValue = lhs.safeTotalCurrentPrice ?? 0
            let rhsValue = rhs.safeTotalCurrentPrice ?? 0
            return ascending ? lhsValue < rhsValue : lhsValue > rhsValue
        }
    }
    
    func sortedByGainLoss(ascending: Bool = false) -> [UserAsset] {
        sorted { lhs, rhs in
            let lhsGain = lhs.safeGainLoss ?? 0
            let rhsGain = rhs.safeGainLoss ?? 0
            return ascending ? lhsGain < rhsGain : lhsGain > rhsGain
        }
    }
}
