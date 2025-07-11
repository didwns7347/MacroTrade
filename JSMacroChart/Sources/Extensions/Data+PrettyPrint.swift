import Foundation

extension Data {
    /// Data 객체를 예쁘게 들여쓰기 된 JSON 문자열로 변환합니다.
    /// 변환에 실패할 경우 nil을 반환합니다.
    var toPrettyPrintedJSONString: String? {
        // 1. Data를 Foundation의 JSON 객체로 직렬화합니다.
        guard let jsonObject = try? JSONSerialization.jsonObject(with: self, options: []) else {
            // JSON으로 변환할 수 없는 경우, 일반 UTF-8 문자열로 변환을 시도합니다.
            return String(data: self, encoding: .utf8)
        }

        // 2. JSON 객체를 예쁘게 출력하는 옵션(.prettyPrinted)을 사용하여 다시 Data로 변환합니다.
        guard let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]) else {
            return nil
        }

        // 3. 최종적으로 변환된 Data를 UTF-8 문자열로 만들어 반환합니다.
        return String(data: prettyJsonData, encoding: .utf8)
    }
}
