//
//  Utils.swift
//  JSMacroChart
//
//  Created by yangjs on 9/22/25.
//
import Foundation

extension Double {
    func formatNumber(minDigits: Int = 2,
                      maxDigits: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = minDigits
        formatter.maximumFractionDigits = maxDigits
        
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
extension Float {
    func formatNumber(minDigits: Int = 2,
                      maxDigits: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = minDigits
        formatter.maximumFractionDigits = maxDigits
        
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
extension Decimal {
    func formatNumber(minDigits: Int = 2,
                      maxDigits: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = minDigits
        formatter.maximumFractionDigits = maxDigits
        
        return formatter.string(from: NSNumber(nonretainedObject: self)) ?? "\(self)"
    }
}
