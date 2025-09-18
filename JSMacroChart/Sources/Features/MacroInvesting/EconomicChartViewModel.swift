import Foundation
import Combine

// MARK: - Chart Data Models

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

struct ChartSeries: Identifiable {
    let id = UUID()
    let name: String
    let items: [ChartDataPoint]
}

// MARK: - ViewModel

@MainActor
class EconomicChartViewModel: ObservableObject {

    @Published var chartSeries: [ChartSeries] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiService = KoreaInvestmentAPIService.shared
    private let dataPointLimit = 60

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }()

    func fetchData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // KODEX 구리선물(138910), TIGER 미국S&P500(360750), TIGER 미국필라델피아반도체(139320) 데이터를 가져옵니다.
                async let copperData = fetchAndProcessData(symbol: "138910")
                async let sp500Data = fetchAndProcessData(symbol: "360750")
                async let semiData = fetchAndProcessData(symbol: "139320")

                let (fetchedCopper, fetchedSP500, fetchedSemi) = try await (copperData, sp500Data, semiData)

                // 세 데이터를 Y축 스케일에 맞춰 조정합니다.
                let (alignedCopper, alignedSP500, alignedSemi) = alignAndScaleThreeSeries(series1: fetchedCopper, series2: fetchedSP500, series3: fetchedSemi)

                self.chartSeries = [
                    ChartSeries(name: "KODEX 구리선물", items: alignedCopper),
                    ChartSeries(name: "TIGER S&P500", items: alignedSP500),
                    ChartSeries(name: "TIGER 금/은 선물", items: alignedSemi)
                ]

            } catch {
                await apiService.resetToken()
                errorMessage = "데이터를 불러오는데 실패했습니다: \(error.localizedDescription)"
                print(error)
            }
            isLoading = false
        }
    }

    private func fetchAndProcessData(symbol: String) async throws -> [ChartDataPoint] {
        let dailyPrices = try await apiService.fetchDailyPrice(stockCode: symbol)
        
        let chartData = dailyPrices.compactMap { data -> ChartDataPoint? in
            guard let date = dateFormatter.date(from: data.businessDate),
                  let value = Double(data.closingPrice) else {
                return nil
            }
            return ChartDataPoint(date: date, value: value)
        }
        
        // 최신 60개 데이터만 반환합니다.
        return Array(chartData.suffix(dataPointLimit))
    }

    /// 세 데이터 시리즈의 스케일을 맞추고 날짜를 정렬합니다.
    private func alignAndScaleThreeSeries(series1: [ChartDataPoint], series2: [ChartDataPoint], series3: [ChartDataPoint]) -> ([ChartDataPoint], [ChartDataPoint], [ChartDataPoint]) {
        guard let firstValue1 = series1.first?.value,
              let firstValue2 = series2.first?.value,
              let firstValue3 = series3.first?.value,
              firstValue1 != 0, firstValue2 != 0, firstValue3 != 0 else {
            return (series1, series2, series3) // 데이터가 없으면 원본 반환
        }

        // series2, series3의 첫번째 값을 series1의 첫번째 값에 맞추기 위한 비율 계산
        let scaleFactor2 = firstValue1 / firstValue2
        let scaleFactor3 = firstValue1 / firstValue3

        let scaledSeries2 = series2.map { ChartDataPoint(date: $0.date, value: $0.value * scaleFactor2) }
        let scaledSeries3 = series3.map { ChartDataPoint(date: $0.date, value: $0.value * scaleFactor3) }
        
        // 날짜를 기준으로 데이터 정렬
        let dict1 = Dictionary(uniqueKeysWithValues: series1.map { ($0.date, $0.value) })
        let dict2 = Dictionary(uniqueKeysWithValues: scaledSeries2.map { ($0.date, $0.value) })
        let dict3 = Dictionary(uniqueKeysWithValues: scaledSeries3.map { ($0.date, $0.value) })

        let commonDates = Set(dict1.keys).intersection(Set(dict2.keys)).intersection(Set(dict3.keys)).sorted()

        let aligned1 = commonDates.map { ChartDataPoint(date: $0, value: dict1[$0]!) }
        let aligned2 = commonDates.map { ChartDataPoint(date: $0, value: dict2[$0]!) }
        let aligned3 = commonDates.map { ChartDataPoint(date: $0, value: dict3[$0]!) }

        return (aligned1, aligned2, aligned3)
    }
}
