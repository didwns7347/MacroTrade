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
                    return ["closingPrice":"\($0.closingPrice)", "date":"\($0.date)"]
                }
            )
        } else {
            result = StockDailyHistory(
                code: ticker,
                closingPrices: try await KoreaInvestmentAPIService.shared.fetchDomesticDailyPrice(stockCode: ticker).map {
                    return ["closingPrice":"\($0.closingPrice)", "date":"\($0.businessDate)"]
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

class StockPerformanceTool : Tool {
    func execute(args: String) async throws -> String {
        let infos = args.split(separator: "|")
        let ticker = String(infos[1])
        
        let stockDetail = try await KoreaInvestmentAPIService.shared.fetchDomesticStockDetail(code: ticker)
        var result: StockPerformance
        if infos[0] == "TRUE" {
            result = StockPerformance(
                name: String(infos[2]),
                code: ticker,
                marketCapitalization: stockDetail.marketCapitalization,
                per: stockDetail.per,
                pbr: stockDetail.pbr,
                eps: stockDetail.eps,
                financialStates: try await KoreaInvestmentAPIService.shared.fetchDomesticStockPerformance(code: ticker).output
            )
        } else {
            result = StockPerformance(
                name: String(infos[2]),
                code: ticker,
                marketCapitalization: stockDetail.marketCapitalization,
                per: stockDetail.per,
                pbr: stockDetail.pbr,
                eps: stockDetail.eps,
                financialStates: try await KoreaInvestmentAPIService.shared.fetchDomesticStockPerformance(code: ticker).output
            )
        }
        if let resultString = result.toJSONString(prettyPrinted: true) {
            return resultString
        } else {
            throw ToolError.encodingError
        }
    }
}
