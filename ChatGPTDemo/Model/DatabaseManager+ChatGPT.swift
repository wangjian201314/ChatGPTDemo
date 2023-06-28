//
//  DatabaseManager+ChatGPT.swift
//  ChatGPTDemo
//
//  Created by jian on 2023/6/1.
//

import Foundation
import WCDBSwift

extension DatabaseManager {
    enum TableName {
        static let ChatGPTMessage = "ChatGPTMessage"
    }

    static func insertMessageListModel(_ model: ChatGPTMessageModel, at db: Database) {
        DatabaseManager.DBOperation.insertSingle(objects: model, into: LoginModel.share.uuid + DatabaseManager.TableName.ChatGPTMessage, at: db)
    }

    /// 删除数据
    static func deleteMessageListModel(at db: Database) {
        let condition = ChatGPTMessageModel.Properties.isSelect == true
        DatabaseManager.DBOperation.delete(from: LoginModel.share.uuid + DatabaseManager.TableName.ChatGPTMessage, where: condition, at: db)
    }

    /// 获取所有数据
    static func getAllObjects(at db: Database) -> [ChatGPTMessageModel] {
        let modelList: [ChatGPTMessageModel] = DatabaseManager.DBOperation.select(table: LoginModel.share.uuid + DatabaseManager.TableName.ChatGPTMessage, at: db) ?? []
        return modelList
    }

    /// 更新数据
    static func updateMessageListModel(_ model: ChatGPTMessageModel, at db: Database) {
        let condition = (ChatGPTMessageModel.Properties.messageId == model.messageId)
        DatabaseManager.DBOperation.update(
            object: model,
            properties: [ChatGPTMessageModel.Properties.isSelect],
            where: condition,
            into: LoginModel.share.uuid + DatabaseManager.TableName.ChatGPTMessage,
            at: db
        )
    }
}
