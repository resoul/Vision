import Foundation

enum FilmixStreamDecoder {
    nonisolated static func decodeQualityMap(from list: [String]) -> [String: String] {
        let regex = try! NSRegularExpression(pattern: "\\[(.*?)\\]")
        var result: [String: String] = [:]
        for item in list {
            let range = NSRange(item.startIndex..., in: item)
            guard let match = regex.firstMatch(in: item, range: range),
                  let keyRange = Range(match.range(at: 1), in: item) else { continue }
            let key   = String(item[keyRange])
            let value = item.replacingOccurrences(of: "[\(key)]", with: "").trimmingCharacters(in: .whitespaces)
            result[key] = value
        }
        return result
    }
    
    nonisolated static func decodeTokens(_ s: String) -> String {
        let tokens = [
            ":<:bzl3UHQwaWk0MkdXZVM3TDdB",
            ":<:SURhQnQwOEM5V2Y3bFlyMGVI",
            ":<:bE5qSTlWNVUxZ01uc3h0NFFy",
            ":<:Mm93S0RVb0d6c3VMTkV5aE54",
            ":<:MTluMWlLQnI4OXVic2tTNXpU"
        ]

        var clean = String(s.dropFirst(2))
        clean = clean.replacingOccurrences(of: "\\/", with: "/")

        var modified = true
        while modified {
            modified = false
            for token in tokens where clean.contains(token) {
                clean = clean.replacingOccurrences(of: token, with: "")
                modified = true
            }
        }

        guard let data = Data(base64Encoded: clean) else { return "" }
        return String(data: data, encoding: .utf8) ?? ""
    }
}
