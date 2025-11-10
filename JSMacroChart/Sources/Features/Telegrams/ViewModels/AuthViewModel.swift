import Foundation

@MainActor
class AuthViewModel: ObservableObject {
    
    // MARK: - Published Properties for View
    
    @Published var authState: TDAuthState = .unauthenticated
    @Published var isLoading = false
    
    // Input fields
    @Published var phoneNumber = ""
    @Published var authCode = ""
    @Published var password = ""
    
    // MARK: - Private Properties
    
    private let tdService = TDAPIService.shared
    
    init() {
        // 초기화 시 자동 로그인 체크
        Task {
            await checkAutoLogin()
        }
    }
    
    // MARK: - Public Methods (Actions)
    
    /// 앱 시작 시 자동 로그인을 체크합니다.
    func checkAutoLogin() async {
        isLoading = true
        do {
            // TDLib 초기화
            try await tdService.initialize()
            
            // 현재 인증 상태 확인
            let state = try await tdService.getAuthorizationState()
            authState = tdService.convertToTDAuthState(state)
            
            // 이미 로그인된 상태면 자동 로그인 완료
            if case .authorizationStateReady = state {
                print("Auto login successful - user is already authenticated")
            }
        } catch {
            print("Auto login check failed: \(error)")
        }
        isLoading = false
    }
    
    /// 인증 상태를 다시 확인합니다.
    func refreshAuthState() async {
        do {
            let state = try await tdService.getAuthorizationState()
            authState = tdService.convertToTDAuthState(state)
        } catch {
            print("Failed to refresh auth state: \(error)")
        }
    }
    
    /// 현재 인증 상태에 따라 적절한 액션을 트리거합니다.
    func triggerAuthAction() {
        isLoading = true
        
        Task {
            switch authState {
            case .waitingForPhoneNumber:
                await tdService.sendPhoneNumber(phoneNumber)
            case .waitingForCode:
                await tdService.sendAuthCode(authCode)
            case .waitingForPassword:
                await tdService.sendPassword(password)
            default:
                isLoading = false
                print("No action needed for state: \(authState)")
                return
            }
            
            // 액션 후 상태 다시 확인
            await refreshAuthState()
            isLoading = false
        }
    }
}
