import Foundation
import Alamofire

final class FilmixNetworkClient {
    let baseURL = "https://filmix.my"

    private let session: Session = {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36"
        ]
        config.httpCookieStorage = .shared
        config.httpShouldSetCookies = true
        config.httpCookieAcceptPolicy = .always
        return Session(configuration: config)
    }()
    
    func get(url: String) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            session.request(url, method: .get).responseData { response in
                continuation.resume(with: response.result.mapError { $0 as Error })
            }
        }
    }
    
    func getString(url: String) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            session.request(url, method: .get).responseString { response in
                continuation.resume(with: response.result.mapError { $0 as Error })
            }
        }
    }
    
    func post(url: String,
                     parameters: Parameters,
                     headers: HTTPHeaders) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            session.request(url, method: .post, parameters: parameters, headers: headers)
                .responseData { response in
                    continuation.resume(with: response.result.mapError { $0 as Error })
                }
        }
    }
    
    func postDecodable<T: Decodable>(
        url: String,
        parameters: Parameters,
        headers: HTTPHeaders,
        as type: T.Type = T.self
    ) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            session.request(url, method: .post, parameters: parameters, headers: headers)
                .responseDecodable(of: type) { response in
                    continuation.resume(with: response.result.mapError { $0 as Error })
                }
        }
    }
    
    func cookiesString(for urlString: String) -> String {
        guard let url = URL(string: urlString),
              let cookies = HTTPCookieStorage.shared.cookies(for: url) else { return "" }

        var header = HTTPCookie.requestHeaderFields(with: cookies)["Cookie"] ?? ""

        if !header.contains("alora="),
           let baseURL = URL(string: baseURL),
           let minotaurs = HTTPCookieStorage.shared.cookies(for: baseURL)?
            .first(where: { $0.name == "minotaurs" }) {
            let sep = header.isEmpty ? "" : "; "
            header += "\(sep)alora=\(minotaurs.value)"
        }
        return header
    }
}
