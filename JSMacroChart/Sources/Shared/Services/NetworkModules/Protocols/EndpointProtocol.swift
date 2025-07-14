//
//  EndpointProtocol.swift
//  CMCores
//
//  Created by yangjs on 7/18/24.
//
import Foundation
public protocol EndPoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod{ get }
    var parameters: [String: Any]? { get }
    var headers: [String: String ]? { get }
    var requestBody : Encodable? { get }
}

public enum HTTPMethod: String {
    case get
    case post
    case put
    case delete
    case patch
    case head
    case options
}

public enum NetworkError: Error {
    case urlSessionError(Error)
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    case statusCodeFail(Int)
    case endpointError
}
