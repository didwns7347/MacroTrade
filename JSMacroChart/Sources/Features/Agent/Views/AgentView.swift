import SwiftUI

struct AgentView: View {
    @StateObject private var viewModel = AgentViewModel()
    @EnvironmentObject var assetService: AssetService
    var body: some View {
        VStack {
            // Chat messages view
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.messages.filter { $0.role != .system }) { message in
                            MessageView(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count, initial: true) { _,_  in
                    // 새 메시지가 추가되면 맨 아래로 스크롤
                    if let lastMessage = viewModel.messages.last {
                        withAnimation {
                            scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Input field
            HStack {
                TextField("Ask something...", text: $viewModel.currentInput, onCommit: {
                    viewModel.sendMessage()
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.leading)
                .disabled(viewModel.isSending)
                
                if viewModel.isSending {
                    ProgressView()
                        .padding(.trailing)
                } else {
                    Button(action: {
                        viewModel.sendMessage()
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.largeTitle)
                    }
                    .padding(.trailing)
                    .disabled(viewModel.currentInput.isEmpty)
                }
            }
            .padding(.bottom)
        }
        .navigationTitle("Agent")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // 키보드 나타날 때 화면 가리는 것 방지 (더 정교한 처리가 필요할 수 있음)
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
                // 필요한 경우 UI 조정
            }
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                // 필요한 경우 UI 조정
            }
            viewModel.fetchStockMovements(stocks: assetService.stocks)
        }
    }
}



#Preview {
    NavigationView {
        AgentView()
    }
}
