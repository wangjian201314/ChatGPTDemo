//
//  ChatGPTViewController.swift
//  ChatGPTDemo
//
//  Created by jian on 2023/5/19.
//

import CWLateralSlide
import MarkdownKit
import MBProgressHUD
import SVProgressHUD
import TZImagePickerController
import UIKit
import WCDBSwift

class ChatGPTViewController: BaseViewController {
    private var isEdit = false

    private var isConversation = false

    private var currentConversationId = ""

    private var isProgress = false

    private var model: ChatGPTMessageModel = .empty

    private var dataSource: [[ChatGPTMessageModel]] = []

    private var selectedMessageList: [ChatGPTMessageModel] = []

    private var popView: ChatGPTPopView?

    private var bottomPopView: ChatGPTBottomPopView?

    private lazy var leftButton: UIBarButtonItem = {
        let item = UIBarButtonItem(image: UIImage(named: "LeftMenu"), style: .plain, target: self, action: #selector(leftViewClick(_:)))
        return item
    }()

    private lazy var footerView: ChatGPTTableFooterView = {
        let footerView = ChatGPTTableFooterView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 85))
        return footerView
    }()

    private lazy var bottomView: ChatGPTBottomView = {
        let view = ChatGPTBottomView()
        view.delegate = self
        return view
    }()

    private lazy var headImage: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 15
        if let data = UserDefaultsCore.get(for: headImageUserInfo) {
            imageView.image = UIImage(data: data)
        } else {
            imageView.image = UIImage(named: "ChatGPT")
        }
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private lazy var tipLabel: UILabel = {
        let optionalLabel = UILabel()
        optionalLabel.textColor = UIColor(hexString: "#333333")
        optionalLabel.font = UIFont.gys.pingFangFont(ofSize: 18)
        if let text = UserDefaultsCore.get(for: nickNameUserInfo) {
            optionalLabel.text = text
        } else {
            optionalLabel.text = "ChatGPT"
        }
        let width = optionalLabel.sizeThatFits(CGSize(width: UIScreen.main.bounds.size.width - 60, height: CGFloat(MAXFLOAT))).width + 10
        optionalLabel.frame = CGRect(x: 35, y: 0, width: width, height: 30)
        return optionalLabel
    }()

    private lazy var arrowButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 112, y: 0, width: 14, height: 44)
        button.setImage(UIImage(named: "RightArrow"), for: .normal)
        button.addTarget(self, action: #selector(popViewClick(_:)), for: .touchUpInside)
        return button
    }()

    private lazy var titleView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 126, height: 44))
        view.backgroundColor = .clear
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(topTapGesture(_:)))
        view.addGestureRecognizer(tapGesture)
        return view
    }()

    private lazy var bottomButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 22
        button.titleLabel?.font = UIFont.gys.pingFangFont(ofSize: 18)
        button.imageEdgeInsets =
            UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        button.titleEdgeInsets =
            UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        button.backgroundColor = UIColor(hexString: "#FF4040")
        button.setImage(UIImage(named: "DeleteMessage"), for: .normal)
        button.setTitle("Delete selected".gys.localized, for: .normal)
        button.setTitleColor(UIColor(hexString: "#FFFFFF"), for: .normal)
        button.addTarget(self, action: #selector(deleteClick(_:)), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.backgroundColor = UIColor.gys.defaultBackground
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: CGFloat.leastNormalMagnitude))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: CGFloat.leastNormalMagnitude))
        tableView.rowHeight = UITableView.automaticDimension
        tableView.showsVerticalScrollIndicator = false
        tableView.gys.registerCell(withType: ChatGPTServerCel.self)
        tableView.gys.registerCell(withType: ChatGPTClientCell.self)
        tableView.gys.registerHeaderFooterView(withType: ChatGPTHeaderView.self)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .gys.defaultBackground
        navigationItem.leftBarButtonItem = leftButton

        addViewContents()
        addViewConstraints()
        readDataBase()
        tableView.reloadData()
        if let temp = UserDefaultsCore.get(for: lastConversationId) {
            currentConversationId = temp
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }

    private func refreshTitleView() {
        if let text = UserDefaultsCore.get(for: nickNameUserInfo) {
            tipLabel.text = text
        } else {
            tipLabel.text = "ChatGPT"
        }
        let width = tipLabel.sizeThatFits(CGSize(width: UIScreen.main.bounds.size.width - 60, height: CGFloat(MAXFLOAT))).width
        tipLabel.frame = CGRect(x: 35, y: 0, width: width, height: 30)
        arrowButton.frame = CGRect(x: tipLabel.frame.maxX, y: 0, width: width, height: 30)
        titleView.frame = CGRect(x: 0, y: 0, width: 35 + width + 14, height: 30)
    }

    deinit {
        ChatGPTManager.default.db.close()
        NotificationCenter.default.removeObserver(self)
    }

    private func addViewContents() {
        view.addSubview(tableView)
        view.addSubview(bottomView)
        view.addSubview(bottomButton)
        titleView.addSubview(headImage)
        titleView.addSubview(tipLabel)
        titleView.addSubview(arrowButton)
        navigationItem.titleView = titleView
        setUpFooterView()
        notification()
        refreshTitleView()
    }

    private func setUpFooterView() {
        if let temp = UserDefaultsCore.get(for: conversationIdInfo) { // 新会话
            isConversation = temp
        }
        hiddenFooterView(isHidden: isConversation)

        if let model = UserDefaultsCore.get(for: topicUserInfo) {
            footerView.createButton(topList: model.topicList)
        }

        footerView.topicBlock = { question in
            debugPrint(question)
            self.requestQuestion(question: question)
            self.bottomView.messageProgress()
        }
    }

    private func notification() {
        NotificationCenter.default
            .addObserver(forName: .publicSuccess, object: nil, queue: .main) { _ in
                if let model = UserDefaultsCore.get(for: topicUserInfo) {
                    self.footerView.createButton(topList: model.topicList)
                }
            }
    }

    private func addViewConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-40)
        }

        bottomView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }

        bottomButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.height.equalTo(40)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }

    private func hiddenFooterView(isHidden: Bool) {
        if isHidden {
            tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: CGFloat.leastNormalMagnitude))
        } else {
            footerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 85)
            tableView.tableFooterView = footerView
        }
    }

    private func editView() {
        isEdit = !isEdit
        if isEdit {
            bottomView.isHidden = true
            bottomButton.isHidden = false
            leftButton.title = "取消"
            leftButton.image = nil
        } else {
            bottomView.isHidden = false
            bottomButton.isHidden = true
            leftButton.image = UIImage(named: "LeftMenu")
            leftButton.title = nil
        }
        tableView.reloadData()
    }
}

@objc extension ChatGPTViewController {
    private func leftViewClick(_ sender: UIBarButtonItem) {
        if isEdit {
            editView()
        } else {
            let sideBar = SideBarViewController()
            cw_showDrawerViewController(sideBar, animationType: .mask, configuration: nil)
        }
    }

    private func popViewClick(_ sender: UIButton) { }

    private func selectPhoto() {
        let config = ImagePickerConfig()
        config.showSelectBtn = false
        config.allowTakePhoto = true
        config.allowCrop = true
        config.circleCrop = true
        config.maxCount = 1
        config.allowCompress = true
        config.maxCompressLength = 60 * 60
        ImagePicker.imagePicker(config: config, superVc: self) { _, _, selectedPhotos in
            if var image = selectedPhotos?.first {
                self.bottomPopView?.refreshHeadImage(image)
                self.headImage.image = image
                let data = image.pngData()
                UserDefaultsCore.set(value: data ?? Data(), for: headImageUserInfo)
            }
        } cancelSelectPhotoBlock: {
            debugPrint("取消头像选择")
        } unauthorizedBlock: { _ in
            // 相册授权弹框
        }
    }

    private func deleteClick(_ sender: UIButton) {
        if selectedMessageList.isEmpty { return }

        let alertController = UIAlertController(title: "Are you sure you want to delete this item?", message: nil, preferredStyle: .actionSheet)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            DatabaseManager.deleteMessageListModel(at: ChatGPTManager.default.db)
            self.readDataBase()
            self.leftViewClick(self.leftButton)
            self.tableView.reloadData()
        }
        alertController.addAction(deleteAction)

        present(alertController, animated: true, completion: nil)
    }

    private func handleTapGesture(_ tap: UITapGestureRecognizer) {
        popView?.dismiss()
        popView = nil
    }

    private func topTapGesture(_ tap: UITapGestureRecognizer) {
        if bottomPopView != nil {
            bottomPopView?.dismiss()
        }

        bottomPopView = ChatGPTBottomPopView().popView(block: { [weak self] in
            guard let self = self else { return }
            self.selectPhoto()
        }, nickName: { [weak self] _ in
            guard let self = self else { return }
            self.refreshTitleView()
        })
        view.addSubview(bottomPopView ?? ChatGPTBottomPopView())
    }
}

extension ChatGPTViewController {
    private func readDataBase() {
        var tempArray: [ChatGPTMessageModel] = []
        var tempDataSource: [[ChatGPTMessageModel]] = []
        var selectArray: [ChatGPTMessageModel] = []

        let array = DatabaseManager.getAllObjects(at: ChatGPTManager.default.db)
        for i in 0 ..< array.count {
            let model = array[i]
            if model.type == "conversation" { // 会话分割线
                if !tempArray.isEmpty {
                    tempDataSource.append(tempArray)
                }
                tempArray = []
            } else {
                tempArray.append(model)
                if i == array.count - 1 {
                    tempDataSource.append(tempArray)
                }

                if model.isSelect == true { // 选中的消息
                    selectArray.append(model)
                }
            }
        }

        dataSource = tempDataSource
        if dataSource.isEmpty {
            currentConversationId = ChatGPTManager.createConversation()
        }
        selectedMessageList = selectArray
        bottomButton.setTitle(String(format: "Delete selected".gys.localized, selectedMessageList.count), for: .normal)
        tableView.reloadData()
    }

    private func requestQuestion(question: String) {
        var chatModel = ChatGPTMessageModel.empty
        var messageList: [ChatGPTMessageModel] = dataSource.last ?? []
        if let temp = UserDefaultsCore.get(for: conversationIdInfo) { // 新会话
            isConversation = temp
        }
        if isConversation == false {
            messageList = []
        }
        chatModel = ChatGPTManager.createMessage(conversationId: currentConversationId, question: question, type: "user")
        messageList.append(chatModel)

        if dataSource.isEmpty || isConversation == false {
            dataSource.append(messageList)
        } else {
            dataSource[dataSource.count - 1] = messageList
        }

        hiddenFooterView(isHidden: true)
        tableView.reloadData()
        view.endEditing(true)

        let service = ChatGPTService.default
        service.request(parameters: ChatGPTManager.parameters(messageList: messageList))
        service.delegate = self
    }
}

extension ChatGPTViewController: SendQuestionDelegate, ChatGPTDelegate {
    func sendQuestion(_ text: String) {
        requestQuestion(question: text)
    }

    func cancelQuestion() {
        ChatGPTService.default.cancel()
    }

    func cleanConversation() {
        currentConversationId = ChatGPTManager.createConversation()
        hiddenFooterView(isHidden: false)
        readDataBase()
    }

    func requestChatGPTDidReceive(_ text: String) {
        var messageList: [ChatGPTMessageModel] = dataSource.last ?? []
        if !isProgress {
            isProgress = true
            var chatModel = ChatGPTMessageModel.empty
            if let lastModel = messageList.last {
                chatModel = lastModel
            }
            let messageId = String.gys.messageId()
            var message = text
            if text.contains("¥error_message¥") {
                message = message.replacingOccurrences(of: "¥error_message¥", with: "")
            }

            let model = ChatGPTMessageModel(text: message, isSelect: false, type: "assistant", messageId: messageId, timeStamp: Date.gys.timeStamp(), conversationId: chatModel.conversationId)
            messageList.append(model)
            dataSource[dataSource.count - 1] = messageList
        } else {
            var chatModel = ChatGPTMessageModel.empty
            if let lastModel = messageList.last {
                lastModel.text = text
                chatModel = lastModel
            }
            messageList[messageList.count - 1] = chatModel
            dataSource[dataSource.count - 1] = messageList
        }

        DispatchQueue.main.async {
            let row = messageList.count - 1
            let index = IndexPath(row: row, section: self.dataSource.count - 1)
            self.tableView.scrollToRow(at: index, at: .bottom, animated: true)
        }
    }

    func requestChatGPTDidComplete(_ text: String, _ error: NSError?) {
        if error != nil { }
        isProgress = false
        bottomView.messageComplete()

        let messageList: [ChatGPTMessageModel] = dataSource.last ?? []
        var chatModel = ChatGPTMessageModel.empty
        if let lastModel = messageList.last {
            chatModel = lastModel
        }
        DatabaseManager.insertMessageListModel(chatModel, at: ChatGPTManager.default.db)
    }
}

extension ChatGPTViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        dataSource.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let messageList: [ChatGPTMessageModel] = dataSource[section]
        return messageList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messageList: [ChatGPTMessageModel] = dataSource[indexPath.section]
        let messageModel = messageList[indexPath.row]

        if messageModel.type == "user" {
            let cell = tableView.gys
                .dequeueReusableCell(withType: ChatGPTClientCell.self) ?? ChatGPTClientCell.gys
                .create()
            cell.selectionStyle = .none
            cell.delegate = self
            cell.setUpText(model: messageModel)
            cell.editMessage(isEdit)
            return cell
        } else {
            let cell = tableView.gys
                .dequeueReusableCell(withType: ChatGPTServerCel.self) ?? ChatGPTServerCel.gys
                .create()
            cell.selectionStyle = .none
            cell.delegate = self
            var isHidden = true
            if !dataSource.isEmpty, indexPath.section == dataSource.count - 1, indexPath.row == messageList.count - 1 {
                isHidden = false
            }
            cell.setUpText(model: messageModel, isHidden: isHidden)
            cell.editMessage(isEdit)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        var height = 0.0
        if let temp = UserDefaultsCore.get(for: conversationIdInfo) { // 新会话
            isConversation = temp
        }
        if !dataSource.isEmpty {
            if section != dataSource.count - 1 || isConversation == false {
                height = 34.0
            }
        }

        return height
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let header = tableView.gys.dequeueReusableHeaderFooterView(withType: ChatGPTHeaderView.self) ?? ChatGPTHeaderView.gys.create()
        if let temp = UserDefaultsCore.get(for: conversationIdInfo) { // 新会话
            isConversation = temp
        }
        if !dataSource.isEmpty {
            if section != dataSource.count - 1 || isConversation == false {
                return header
            }
        }
        return UIView()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if popView != nil {
            popView?.dismiss()
        }
    }
}

extension ChatGPTViewController: SelectMessageDelegate {
    func selectMessage(_ cell: UITableViewCell, _ isSelect: Bool) {
        guard let index = tableView.indexPath(for: cell) else { return }

        let messageList: [ChatGPTMessageModel] = dataSource[index.section]
        let model = messageList[index.row]
        model.isSelect = isSelect
        DatabaseManager.updateMessageListModel(model, at: ChatGPTManager.default.db)
        readDataBase()
    }

    func longPress(_ cell: UITableViewCell) {
        guard let index = tableView.indexPath(for: cell) else { return }
        let messageList: [ChatGPTMessageModel] = dataSource[index.section]
        let messageModel = messageList[index.row]
        let cellRect = tableView.rectForRow(at: index)
        let cellRectInScreen = tableView.convert(cellRect, to: nil)
        var originY = cellRectInScreen.minY
        if originY < UIScreen().gys.statusBarHeight + 44.0 {
            originY = UIScreen().gys.statusBarHeight + 44.0
        }

        if popView != nil {
            popView?.dismiss()
        }

        popView = ChatGPTPopView().popView(array: ChatGPTPopModel.popDataSource(), marginY: originY, selectResult: { model in
            if model.type == .popViewCopy {
                let pasteboard = UIPasteboard.general
                pasteboard.string = messageModel.text
                SVProgressHUD.showSuccess(withStatus: "Copied".gys.localized)
            } else if model.type == .popViewDelete {
                self.editView()
            }
        })
        view.addSubview(popView ?? ChatGPTPopView())
    }
}

extension ChatGPTViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // 允许UITableView和其他手势同时识别
        if otherGestureRecognizer.view == tableView {
            return true
        }
        // 不允许其他手势同时识别
        return false
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: popView)
        if CGRectContainsPoint(touch.view?.frame ?? UIScreen.main.bounds, location) {
            return false
        }
        return true
    }
}
