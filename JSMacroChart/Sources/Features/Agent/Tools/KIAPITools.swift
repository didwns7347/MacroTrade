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
        var result: StockDailyHistory
        if infos[0] == "TRUE" {
            result = StockDailyHistory( 
                code: ticker,
                closingPrices: try await KoreaInvestmentAPIService.shared.fetchOverseasDailyPrice(stockCode: ticker).map {
                    $0.closingPrice
                }
            )
        } else {
            result = StockDailyHistory(
                code: ticker,
                closingPrices: try await KoreaInvestmentAPIService.shared.fetchDomesticDailyPrice(stockCode: ticker).map {
                    $0.closingPrice
                }
            )
        }
        if let resultString = result.toJSONString(prettyPrinted: true) {
            return resultString
        } else {
            throw ToolError.encodingError
        }
        
    }
}
