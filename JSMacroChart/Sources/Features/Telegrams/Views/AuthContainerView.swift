import SwiftUI

struct AuthContainerView: View {
    // ViewModel을 관찰하여 UI를 업데이트합니다.
    @StateObject private var viewModel = AuthViewModel()
    
    var body: some View {
        // ViewModel의 인증 상태에 따라 적절한 뷰를 보여줍니다.
        Group {
            switch viewModel.authState {
            case .waitingForPhoneNumber:
                AuthInputView(
                    title: "Phone Number",
                    subtitle: "Please enter your phone number to log in to Telegram.",
                    placeholder: "+1 234 567 8900",
                    text: $viewModel.phoneNumber, // ViewModel의 프로퍼티와 바인딩
                    isLoading: viewModel.isLoading
                ) {
                    viewModel.triggerAuthAction() // ViewModel의 액션 호출
                }
                
            case .waitingForCode:
                AuthInputView(
                    title: "Confirmation Code",
                    subtitle: "We've sent a code to your Telegram app or SMS.",
                    placeholder: "12345",
                    text: $viewModel.authCode,
                    isLoading: viewModel.isLoading
                ) {
                    viewModel.triggerAuthAction()
                }
                
            case .waitingForPassword:
                AuthInputView(
                    title: "2-Step Verification",
                    subtitle: "Please enter your cloud password.",
                    placeholder: "Your Password",
                    text: $viewModel.password,
                    isSecure: true,
                    isLoading: viewModel.isLoading
                ) {
                    viewModel.triggerAuthAction()
                }
                
            case .ready:
                // 로그인이 성공하면 보여줄 메인 컨텐츠 뷰
                // TODO: ContentView() 또는 다른 뷰로 교체하세요.
                Text("Login Successful!")
                    .font(.largeTitle)
                
            default:
                // .unauthenticated, .loggingOut 등 다른 상태일 때
                VStack {
                    Text("Connecting to Telegram...")
                    ProgressView()
                }
            }
        }
    }
}

#Preview {
    AuthContainerView()
}
