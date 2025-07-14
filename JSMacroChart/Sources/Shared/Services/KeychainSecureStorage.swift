//
//  KeychainSecureStorage.swift
//  JSMacroChart
//
//  Created by yangjs on 7/14/25.
//
import Security
import Foundation
final class KeychainSecureStorage: SecureStorageProtocol {
    static let shared = KeychainSecureStorage()
    private init() {}
    
    
    func save(_ data: Data, service: String, account: String) {
        let query: CFDictionary = [
            kSecClass : kSecClassGenericPassword,
            kSecAttrService : service,
            kSecAttrAccount : account,
            kSecValueData :  data
        ] as CFDictionary
        SecItemDelete(query )
        SecItemAdd(query, nil)
        
    }
    
    func read(service: String, account: String) -> Data? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrServer: service,
            kSecAttrAccount: account,
            kSecMatchLimit: kSecMatchLimitOne,
            kSecReturnData: true
        ] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        return result as? Data
    }
    
    func delete(service: String, account: String) {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ] as CFDictionary

        SecItemDelete(query)
    }
    
}
