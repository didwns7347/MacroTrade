//
//  KIAPITool.swift
//  JSMacroChart
//
//  Created by yangjs on 10/2/25.
//

class StockPriceHistoryTool : Tool {
    func execute(args: String) async throws -> String {
        let infos = args.split(separator: "|")
        let ticker = String(infos[1])
        var result: [DailyPriceInfo]
        if infos[0] == "" {
            result = try await KoreaInvestmentAPIService.shared.fetchDomesticDailyPrice(stockCode: ticker)
        } else {
            result = try await KoreaInvestmentAPIService.shared.fetchDomesticDailyPrice(stockCode: ticker)
        }
        if let resultString = result.toJSONString(prettyPrinted: true) {
            return resultString
        } else {
            throw ToolError.encodingError
        }
        
    }
}
