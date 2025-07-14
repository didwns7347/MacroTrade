//
//  AuthRepositoryService.swift
//  JSMacroChart
//
//  Created by yangjs on 7/14/25.
//
import Foundation

protocol SecureStorageProtocol  {
    func save(_ data: Data, service: String, account: String)
    func read(service: String, account: String) -> Data?
    func delete(service: String, account: String)
}
