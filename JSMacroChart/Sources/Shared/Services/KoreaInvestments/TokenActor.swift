//
//  TokenActor.swift
//  JSMacroChart
//
//  Created by yangjs on 7/15/25.
//
import Foundation

// MARK: - Token Manager (actor)
actor TokenManager {
    enum KeychainKey {
        static let service = "com.jsMacro.KoreaInvestmentAPI"
        static let accessToken = "accessToken"
        static let tokenExpiresAt = "expiresIn"
    }
    private var token: String?
    private var expiresAt: Date?
    private let networkService: NetworkService
    private let apiKeyManager: APIConfigManager
    private let secureStorage: SecureStorageProtocol
    private var refreshingTask: Task<String, Error>? = nil

    init(
        networkService: NetworkService = APINetworkService.shared,
        apiKeyManager: APIConfigManager = .shared,
        secureStorage: SecureStorageProtocol = KeychainSecureStorage.shared
    ) {
        self.networkService = networkService
        self.apiKeyManager = apiKeyManager
        self.secureStorage = secureStorage
        let (token, expiresAt) = TokenManager.loadTokenFromKeychainStatic(secureStorage: secureStorage)
        self.token = token
        self.expiresAt = expiresAt
    }

    private static func loadTokenFromKeychainStatic(secureStorage: SecureStorageProtocol) -> (String?, Date?) {
        if let tokenData = secureStorage.read(service: KeychainKey.service, account: KeychainKey.accessToken),
           let token = String(data: tokenData, encoding: .utf8),
           let expiresAtData = secureStorage.read(service: KeychainKey.service, account: KeychainKey.tokenExpiresAt),
           let expiresAt = try? JSONDecoder().decode(Date.self, from: expiresAtData) {
            return (token, expiresAt)
        }
        return (nil, nil)
    }

    func getValidToken() async throws -> String {
        let now = Date()
        if let token = token, let expires = expiresAt, expires > now {
//            print("token=",token)
            return token
        }
        // 이미 발급 중이면 기존 Task를 기다림
        if let task = refreshingTask {
            return try await task.value
        }
        // 새로 발급 Task 생성
        let task = Task<String, Error> {
            let endpoint = KoreaInvestmentEndpoint.issueToken
            let response: TokenResponse = try await networkService.request(endpoint: endpoint)
            let newToken = response.accessToken
            let newExpiresAt = response.tokenExpiredAt.convertToDate()

            let expiresAtData = try JSONEncoder().encode(newExpiresAt)
            secureStorage.save(newToken.data(using: .utf8) ?? Data(), service: KeychainKey.service, account: KeychainKey.accessToken)
            secureStorage.save(expiresAtData, service: KeychainKey.service, account: KeychainKey.tokenExpiresAt)
            // actor 상태 갱신
            self.token = newToken
            self.expiresAt = newExpiresAt
            return newToken
        }
        refreshingTask = task
        defer { refreshingTask = nil }
        return try await task.value
    }

    func resetToken() {
        self.token = nil
        self.expiresAt = nil
        secureStorage.delete(service: KeychainKey.service, account: KeychainKey.accessToken)
        secureStorage.delete(service: KeychainKey.service, account: KeychainKey.tokenExpiresAt)
    }
}
