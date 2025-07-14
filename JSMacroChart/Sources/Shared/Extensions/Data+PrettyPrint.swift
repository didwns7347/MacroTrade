import Foundation
public extension Data {
    var prettyJsonString : String {
        get{
            do {
                // JSON 데이터를 객체로 디코딩
                let jsonObject = try JSONSerialization.jsonObject(with: self, options: [])
                
                // 객체를 예쁘게 포맷된 JSON 데이터로 변환
                let prettyJsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                
                // 예쁘게 포맷된 JSON 데이터를 문자열로 변환
                if let prettyJsonString = String(data: prettyJsonData, encoding: .utf8) {
                    return prettyJsonString
                }
                return "Pretty Print 실패"
            } catch {
                return "JSON 변환 오류: \(error)"
            }
        }
    }
}
