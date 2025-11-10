
//
//  TDAPIService.swift
//  JSMacroChart
//
//  Created by yangjs on 10/22/25.
//
import Foundation
import TDLibKit
import UIKit

class TDAPIService {
    static let shared = TDAPIService()
    let manager = TDLibClientManager()
    let client: TDLibClient
    
    private init() {
        // 클로저는 나중에 호출되므로 self는 이미 초기화된 상태입니다
        self.client = self.manager.createClient { data, client in
            if let update = try? client.decoder.decode(Update.self, from: data) {
                // Update는 처리되지만, 상태 확인은 ViewModel에서 직접 getAuthorizationState()로 확인
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// AuthorizationState를 TDAuthState로 변환
    func convertToTDAuthState(_ state: AuthorizationState) -> TDAuthState {
        switch state {
        case .authorizationStateWaitPhoneNumber:
            return .waitingForPhoneNumber
        case .authorizationStateWaitCode:
            return .waitingForCode
        case .authorizationStateWaitPassword:
            return .waitingForPassword
        case .authorizationStateReady:
            return .ready
        case .authorizationStateLoggingOut:
            return .loggingOut
        case .authorizationStateClosing, .authorizationStateClosed:
            return .unauthenticated
        default:
            return .unauthenticated
        }
    }
    
    func setUpParameters() async throws -> Void {
        let apiId = Bundle.main.object(forInfoDictionaryKey: "TD_API_ID") as? String ?? "1234"
        print(apiId + "   1234")
        try await client.setTdlibParameters(
            apiHash: Bundle.main.object(forInfoDictionaryKey: "TD_API_HASH") as? String,
            apiId: Int(apiId),
            applicationVersion: "1.0",
            databaseDirectory: "\(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path)/tdlib",
            databaseEncryptionKey: nil,
            deviceModel: UIDevice.current.model,
            filesDirectory: nil,
            systemLanguageCode: Locale.current.language.languageCode?.identifier ?? "en",
            systemVersion: UIDevice.current.systemVersion,
            useChatInfoDatabase: true,
            useFileDatabase: true,
            useMessageDatabase: true,
            useSecretChats: false,
            useTestDc: false
        )
    }
    // MARK: - Public Methods (모두 이전과 동일)
    
    func sendPhoneNumber(_ number: String) async {

            do { try await client.setAuthenticationPhoneNumber(phoneNumber: number, settings: nil)}
            catch { print("Error sending phone number: \(error)") }
    
    }
    
    func sendAuthCode(_ code: String) async {

            do { try await client.checkAuthenticationCode(code: code) }
            catch { print("Error sending auth code: \(error)") }
        
    }
    
    func sendPassword(_ password: String) async {

            do { try await client.checkAuthenticationPassword(password: password) }
            catch { print("Error sending password: \(error)") }
        
    }
    
    func logout() async {

            do { try await client.logOut() }
            catch { print("Error logging out: \(error)") }
        
    }
    
    func findChatId(title: String) async throws -> Int64? {
        let authState = try await client.getAuthorizationState()
        if authState != .authorizationStateReady { return nil }
        let chats = try await client.getChats(chatList: .chatListMain, limit: 100)
        for id in chats.chatIds {
            print(id)
        }
   
        return nil
    }
    
    func getAuthorizationState() async throws -> AuthorizationState {
        return try await client.getAuthorizationState()
    }
    
    // MARK: - Auto Login
    
    /// 앱 시작 시 TDLib 파라미터를 설정합니다.
    func initialize() async throws {
        try await setUpParameters()
    }
}
