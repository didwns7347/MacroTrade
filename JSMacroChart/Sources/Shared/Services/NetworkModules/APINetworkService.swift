//
//  APINetworkService.swift
//  JSMacroChart
//
//  Created by yangjs on 7/14/25.
//

import Foundation

public final class APINetworkService: NetworkService {
    public func request<T>(endpoint: any EndPoint) async throws -> T where T : Decodable {
        let urlRequest = try buildURLRequest(for: endpoint)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.statusCodeFail(httpResponse.statusCode)
        }
        
        do {
            NSLog("[response Body]\(endpoint.path)\n \(data.prettyJsonString)")
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}

extension APINetworkService {
    private func buildURLRequest(for endPoint: EndPoint) throws -> URLRequest {
        // baseurl + apiPath
        var urlComponents = URLComponents(
            url: endPoint.baseURL.appendingPathComponent(endPoint.path),
            resolvingAgainstBaseURL: false
        )
        // 쿼리 파라메터 설정
        urlComponents?.queryItems = endPoint.parameters?.map{
            URLQueryItem(name: $0.key, value: "\($0.value)")
        }
        // url 검사
        guard let url = urlComponents?.url else { throw NetworkError.invalidURL }
        
        var requset = URLRequest(url: url)
        
        requset.httpMethod = endPoint.method.rawValue
        endPoint.headers?.forEach({ (key: String, value: String) in
            requset.addValue(value, forHTTPHeaderField: key)
        })
        // body 설정
        if let requestBody = endPoint.requestBody {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .prettyPrinted
            guard let jsonBody = try? jsonEncoder.encode(requestBody) else {
                throw NetworkError.endpointError
            }
            NSLog("[request Body]\(endPoint.path)\n \(jsonBody.prettyJsonString)")
            
            requset.httpBody = jsonBody
        }
  
        
        return requset
    }
}
