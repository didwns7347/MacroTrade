//
//  NetworkServiceProtocol.swift
//  CMCores
//
//  Created by yangjs on 7/18/24.
//

import Foundation
public protocol NetworkService {
    func request<T:Decodable>(endpoint: EndPoint) async throws -> T
}

