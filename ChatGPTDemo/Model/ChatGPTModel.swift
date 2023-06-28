//
//  ChatGPTModel.swift
//  ChatGPTDemo
//
//  Created by jian on 2023/5/19.
//

import Foundation
import WCDBSwift

class ChatGPTMessageModel: TableCodable {
    static let empty = ChatGPTMessageModel(text: "", isSelect: false, type: "", messageId: "", timeStamp: 0, conversationId: "")

    var text = ""
    var isSelect = false
    var type = ""
    var messageId = ""
    var timeStamp = 0
    var conversationId = ""

    init(text: String = "", isSelect: Bool = false, type: String = "", messageId: String = "", timeStamp: Int, conversationId: String) {
        self.text = text
        self.isSelect = isSelect
        self.type = type
        self.messageId = messageId
        self.timeStamp = timeStamp
        self.conversationId = conversationId
    }

    enum CodingKeys: String, CodingTableKey {
        typealias Root = ChatGPTMessageModel
        static let objectRelationalMapping = TableBinding(CodingKeys.self)

        case text
        case isSelect
        case type
        case messageId
        case timeStamp
        case conversationId

        static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [.messageId: ColumnConstraintBinding(isPrimary: true)]
        }
    }
}

class ChatGPTManager {
    static let `default` = ChatGPTManager()

    lazy var db: Database = {
        let db: Database = DatabaseManager.DBOperation.createDB(dbPath: DatabaseManager.DBPath.Discover)
        DatabaseManager.DBOperation.createTable(LoginModel.share.uuid + DatabaseManager.TableName.ChatGPTMessage, tType: ChatGPTMessageModel.self, at: db)
        return db
    }()

    static func createMessage(conversationId: String, question: String, type: String) -> ChatGPTMessageModel {
        let messageId = String.gys.messageId()
        let model = ChatGPTMessageModel(text: question, isSelect: false, type: type, messageId: messageId, timeStamp: Date.gys.timeStamp(), conversationId: conversationId)
        DatabaseManager.insertMessageListModel(model, at: ChatGPTManager.default.db)
        UserDefaultsCore.set(value: true, for: conversationIdInfo)
        return model
    }

    static func createConversation() -> String {
        let messageId = String.gys.messageId()
        let conversationId = String.gys.messageId()
        var isConversation = false
        if let temp = UserDefaultsCore.get(for: conversationIdInfo) { // 新会话
            isConversation = temp
        }

        if isConversation == false {
            let conversationModel = ChatGPTMessageModel(text: "", isSelect: false, type: "conversation", messageId: messageId, timeStamp: Date.gys.timeStamp(), conversationId: conversationId)
            DatabaseManager.insertMessageListModel(conversationModel, at: ChatGPTManager.default.db) // conversation插入数据库
            UserDefaultsCore.set(value: conversationId, for: lastConversationId)
        }
        return conversationId
    }

    static func parameters(messageList: [ChatGPTMessageModel]) -> [String: Any] {
        var parameters: [String: Any] = [:]
        var messages: [[String: Any]] = []
        for messageModel in messageList {
            parameters["message_id"] = messageModel.messageId
            parameters["role"] = messageModel.type
            parameters["content"] = messageModel.text
            parameters["create_time"] = messageModel.timeStamp
            messages.append(parameters)
        }
        let conversationId = messageList.last?.conversationId ?? ""
        let params = ["messages": messages,
                      "conversation_id": conversationId] as [String: Any]
        return params
    }
}
