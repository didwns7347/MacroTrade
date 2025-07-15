import SwiftUI
import Charts

struct ContentView: View {
    @StateObject private var viewModel = EconomicChartViewModel()

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("데이터 로딩 중...")
                } else {
                    chartView
                }
            }
            .navigationTitle("경제 지표")
            .onAppear {
                viewModel.fetchData()

            }
        }
    }

    private var chartView: some View {
        Chart(viewModel.chartSeries) { series in
            ForEach(series.items) { item in
                LineMark(
                    x: .value("날짜", item.date, unit: .day),
                    y: .value("정규화된 값", item.value)
                )
                .interpolationMethod(.catmullRom)
            }
            .foregroundStyle(by: .value("지표", series.name))
            .symbol(by: .value("지표", series.name))
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    if let doubleValue = value.as(Double.self) {
                        // 원화 형식으로 Y축 레이블 표시
                        Text(doubleValue, format: .currency(code: "KRW").precision(.fractionLength(0)))
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5)) {
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.month().day(), centered: true)
            }
        }
        .chartLegend(position: .top, alignment: .center)
        .padding()
    }
}

#Preview {
    ContentView()
}

