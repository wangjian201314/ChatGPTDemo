//
//  ChatGPTRequest.swift
//  GYS
//
//  Created by jian on 2023/5/18.
//

import Foundation

class ChatGPTRequest {
    static let `default` = ChatGPTRequest()

    var urlRequest: URLRequest {
        let url = URL(string: "https://xxx")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        headers.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
        return urlRequest
    }

    var headers: [String: String] {
        ["TH_platform": "ios",
         "xToken": "xxx",
         "Content-Type": "application/json"]
    }

    func jsonBody(parameters: [String: Any]) -> Data {
        do {
            let json = try JSONSerialization.data(withJSONObject: parameters, options: [.prettyPrinted])
            return json
        } catch {
            return Data()
        }
    }
}
