//
//  ChatGPTBottomView.swift
//  ChatGPTDemo
//
//  Created by jian on 2023/5/30.
//

import RxCocoa
import RxSwift
import UIKit

protocol SendQuestionDelegate: AnyObject {
    func sendQuestion(_ text: String)
    func cancelQuestion()
    func cleanConversation()
}

class ChatGPTBottomView: UIView {
    weak var delegate: SendQuestionDelegate?

    private var isProgress = false

    private let bag = DisposeBag()

    private lazy var cleanButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "Clean"), for: .normal)
        button.addTarget(self, action: #selector(cleanClick(_:)), for: .touchUpInside)
        return button
    }()

    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 5, y: 0, width: 30, height: 30)
        button.setImage(UIImage(named: "SendEnable"), for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(sendClick(_:)), for: .touchUpInside)
        button.setImage(UIImage(named: "SendUnEnable"), for: .disabled)
        return button
    }()

    private lazy var rightView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
        view.addSubview(sendButton)
        return view
    }()

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 16))
        textField.delegate = self
        textField.leftViewMode = .always
        textField.rightView = rightView
        textField.rightViewMode = .always
        textField.backgroundColor = .white
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor(hexString: "#D4D4D4")?.cgColor
        textField.font = UIFont.gys.pingFangFont(ofSize: 16)
        textField.textColor = UIColor(hexString: "#333333")
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 20
        return textField
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor(hexString: "#F9F9F9")
        addViewContents()
        addViewConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addViewContents() {
        addSubview(cleanButton)
        addSubview(textField)

//        let input = textField.rx.text.orEmpty.asDriver()
//            .throttle(.milliseconds(300))
//        input.map { $0.count >= 1 && !$0.trimmingCharacters(in: .whitespaces).isEmpty }
//            .drive(sendButton.rx.isEnabled)
//            .disposed(by: bag)
    }

    private func addViewConstraints() {
        cleanButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.size.equalTo(CGSize(width: 24, height: 24))
            make.centerY.equalToSuperview()
        }

        textField.snp.makeConstraints { make in
            make.leading.equalTo(cleanButton.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-15)
            make.height.equalTo(40)
        }
    }

    private func stopSendButton() {
        isProgress = true
        sendButton.isEnabled = true
        sendButton.setImage(UIImage(named: "SendStop"), for: .normal)
    }
}

@objc extension ChatGPTBottomView {
    private func cleanClick(_ sender: UIButton) {
        UserDefaultsCore.set(value: false, for: conversationIdInfo)
        delegate?.cleanConversation()
    }

    private func sendClick(_ sender: UIButton) {
        if isProgress {
            delegate?.cancelQuestion()
        } else {
            debugPrint(textField.text ?? "")
            delegate?.sendQuestion(textField.text ?? "")
            textField.text = ""

            stopSendButton()
        }
    }
}

extension ChatGPTBottomView {
    func messageProgress() {
        stopSendButton()
    }

    func messageComplete() {
        isProgress = false
        DispatchQueue.main.async {
            self.sendButton.isEnabled = self.isTextEmpty(text: self.textField.text ?? "")
            self.sendButton.setImage(UIImage(named: "SendEnable"), for: .normal)
        }
    }
}

extension ChatGPTBottomView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        let isEmpty = text.trimmingCharacters(in: .whitespaces).isEmpty
        if !isProgress {
            sendButton.isEnabled = !isEmpty
        }

        return true
    }

    func isTextEmpty(text: String) -> Bool {
        return text.count >= 1 && !text.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
