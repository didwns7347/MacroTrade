import SwiftUI

struct AgentView: View {
    @StateObject private var viewModel = AgentViewModel()
    @EnvironmentObject var assetService: AssetService

    var body: some View {
        NavigationView {
            ScrollView {
                if viewModel.isLoading && viewModel.reports.isEmpty {
                    ProgressView("Loading Reports...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.reports) { report in
                            ReportCardView(report: report)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("AI Stock Reports")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                // 화면이 나타날 때 보유 주식에 대한 리포트 생성 시작
                if viewModel.reports.isEmpty { // 중복 실행 방지
                    viewModel.generateReports(for: assetService.stocks)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Button(action: {
                            viewModel.generateReports(for: assetService.stocks)
                        }) {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
            }
        }
    }
}



#Preview {


    AgentView()

}
