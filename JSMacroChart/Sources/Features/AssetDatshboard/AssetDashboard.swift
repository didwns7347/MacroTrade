//
//  AssetDashboard.swift
//  JSMacroChart
//
//  Created by yangjs on 9/16/25.
//

import SwiftUI

// MARK: - MVI View
struct AssetDashboard: View {
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                content
            }
            .navigationTitle("자산 현황")
            .refreshable {
                viewModel.handle(intent: .refreshRequested)
            }
        }
        .onAppear {
            viewModel.handle(intent: .viewAppeared)
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.state.viewState {
        case .idle, .loading:
            LoadingView()
            
        case .content:
            DashBoardView(
                state: viewModel.state,
                onAssetTap: { asset in
                    viewModel.handle(intent: .assetSelected(asset))
                }
            )
            
        case .error:
            ErrorView(
                error: viewModel.state.error,
                onRetry: {
                    viewModel.handle(intent: .retryRequested)
                }
            )
            
        case .refreshing:
            DashBoardView(
                state: viewModel.state,
                onAssetTap: { asset in
                    viewModel.handle(intent: .assetSelected(asset))
                }
            )
            .overlay(
                ProgressView()
                    .scaleEffect(0.8)
                    .padding(.top, 20),
                alignment: .top
            )
        }
    }
}

// MARK: - Loading View
private struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("자산 정보를 불러오는 중...")
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Content View
private struct DashBoardView: View {
    let state: DashboardState
    let onAssetTap: (UserAsset) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // 총 자산 요약 카드
                TotalBalanceCard(balance: state.totalBalance)
                
                // 보유 자산 리스트
                AssetListSection(
                    assets: state.assets,
                    onAssetTap: onAssetTap
                )
                
                // 마지막 업데이트 시간
                if let lastUpdated = state.lastUpdated {
                    LastUpdatedView(date: lastUpdated)
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Total Balance Card
private struct TotalBalanceCard: View {
    let balance: DashboardBalance
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("총 평가금액")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.blue)
            }
            
            Text(balance.formattedTotalAmount)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            HStack {
                Text("평가손익")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(balance.formattedGainLoss)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(balance.gainLossColor)
                    
                    Text("\(balance.totalGainLossRate, specifier: "%.2f")%")
                        .font(.caption)
                        .foregroundColor(balance.gainLossColor)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Asset List Section
private struct AssetListSection: View {
    let assets: [UserAsset]
    let onAssetTap: (UserAsset) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("보유 자산")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVStack(spacing: 8) {
                ForEach(assets.indices, id: \.self) { index in
                    AssetRowView(asset: assets[index])
                        .onTapGesture {
                            onAssetTap(assets[index])
                        }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Asset Row View
private struct AssetRowView: View {
    let asset: UserAsset
    
    private var gainLossColor: Color {
        guard let gainLoss = Double(asset.gainLoss) else { return .gray }
        if gainLoss > 0 { return .red }
        else if gainLoss < 0 { return .blue }
        else { return .gray }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(asset.name)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primary)
                
                if asset.assetType == .domestic, let code = asset.code {
                    Text(code)
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else if asset.assetType == .overseas, let ticker = asset.ticker {
                    Text(ticker)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(formattedPrice(asset.currentPrice))
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)
                
                HStack(spacing: 4) {
                    Text(formattedGainLoss(asset.gainLoss))
                        .font(.caption)
                        .foregroundColor(gainLossColor)
                    
                    Text("(\(asset.gainLossRate)%)")
                        .font(.caption)
                        .foregroundColor(gainLossColor)
                }
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
    
    private func formattedPrice(_ price: String) -> String {
        guard let value = Double(price) else { return price }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? price
    }
    
    private func formattedGainLoss(_ gainLoss: String) -> String {
        guard let value = Double(gainLoss) else { return gainLoss }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.positivePrefix = "+"
        return formatter.string(from: NSNumber(value: value)) ?? gainLoss
    }
}

// MARK: - Error View
private struct ErrorView: View {
    let error: DashboardError?
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            VStack(spacing: 8) {
                Text("오류가 발생했습니다")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(error?.localizedDescription ?? "알 수 없는 오류")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("다시 시도") {
                onRetry()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - Last Updated View
private struct LastUpdatedView: View {
    let date: Date
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var body: some View {
        Text("마지막 업데이트: \(formattedDate)")
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.vertical, 8)
    }
}

// MARK: - Previews
struct AssetDashboard_Previews: PreviewProvider {
    static var previews: some View {
        AssetDashboard()
    }
}
