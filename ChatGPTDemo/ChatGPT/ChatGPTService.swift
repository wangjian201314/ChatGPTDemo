//
//  ChatGPTService.swift
//  ChatGPTDemo
//
//  Created by jian on 2023/5/19.
//

import Foundation

protocol ChatGPTDelegate: AnyObject {
    func requestChatGPTDidReceive(_ text: String)
    func requestChatGPTDidComplete(_ text: String, _ error: NSError?)
}

class ChatGPTService: NSObject {
    weak var delegate: ChatGPTDelegate?

    static let `default` = ChatGPTService()

    private var task: URLSessionTask = .init()

    private var text = ""

    func request(parameters: [String: Any]) {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        var urlRequest = ChatGPTRequest.default.urlRequest
        urlRequest.httpBody = ChatGPTRequest.default.jsonBody(parameters: parameters)
        task = session.dataTask(with: urlRequest)
        task.resume()
    }

    func cancel() {
        task.cancel()
    }

    func isCanceled() -> Bool {
        return task.progress.isCancelled
    }
}

extension ChatGPTService: URLSessionDelegate, URLSessionDataDelegate {
    func urlSession(_: URLSession, dataTask _: URLSessionDataTask, didReceive data: Data) {
        guard let string = String(data: data, encoding: .utf8) else { return }
        text.append(string)
        delegate?.requestChatGPTDidReceive(text)
        print(string)
    }

    func urlSession(_: URLSession, task _: URLSessionTask, didCompleteWithError error: Error?) {
        text = ""
        if let error = error as NSError? {
            if error.code != NSURLErrorCancelled {
                delegate?.requestChatGPTDidComplete(text, error)
            } else {
                delegate?.requestChatGPTDidComplete(text, nil)
            }
            print(error)
        } else {
            delegate?.requestChatGPTDidComplete(text, nil)
        }
    }
}
