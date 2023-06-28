//
//  ChatGPTBottomPopView.swift
//  ChatGPTDemo
//
//  Created by jian on 2023/6/9.
//

import UIKit

class ChatGPTBottomPopView: UIView {
    typealias HeadImageClcikBlock = () -> Void
    var headImageBlock: HeadImageClcikBlock?

    typealias NickNameBlock = (String) -> Void
    var nickNameBlock: NickNameBlock?

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear
        UIView.setAnimationsEnabled(true)
    }

    private lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: "#CECFD0")
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 1.5
        return view
    }()

    private lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 8
        return view
    }()

    private lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: "#000000")?.withAlphaComponent(0.3)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        view.addGestureRecognizer(tapGesture)
        return view
    }()

    lazy var headImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 15
        if let data = UserDefaultsCore.get(for: headImageUserInfo) {
            imageView.image = UIImage(data: data)
        } else {
            imageView.image = UIImage(named: "ChatGPTHeadImage")
        }
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectImageTapGesture(_:)))
        tapGesture.view?.tag = 1
        imageView.addGestureRecognizer(tapGesture)
        return imageView
    }()

    private lazy var detailLabel: UILabel = {
        let optionalLabel = UILabel()
        optionalLabel.font = UIFont.gys.mediumPingFangFont(ofSize: 12)
        optionalLabel.text = "This bot is powered by Open AI".gys.localized
        optionalLabel.textColor = UIColor(hexString: "#666666")
        optionalLabel.textAlignment = .center
        return optionalLabel
    }()

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.textAlignment = .center
        textField.backgroundColor = .white
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor(hexString: "#D4D4D4")?.cgColor
        textField.font = UIFont.gys.mediumPingFangFont(ofSize: 18)
        textField.textColor = UIColor(hexString: "#333333")
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 8
        if let nickName = UserDefaultsCore.get(for: nickNameUserInfo) {
            textField.text = nickName.gys.localized
        } else {
            textField.text = "ChatGPT".gys.localized
        }
        return textField
    }()

    private func addViewContents() {
        addSubview(backView)
        addSubview(bottomView)
        bottomView.addSubview(topView)
        bottomView.addSubview(detailLabel)
        bottomView.addSubview(headImage)
        bottomView.addSubview(textField)
    }

    private func addViewConstraints() {
        backView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        bottomView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(274)
            make.height.equalTo(274)
        }

        topView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 40, height: 3))
        }

        headImage.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 60, height: 60))
        }

        textField.snp.makeConstraints { make in
            make.top.equalTo(headImage.snp.bottom).offset(15)
            make.size.equalTo(CGSize(width: 137, height: 48))
            make.centerX.equalToSuperview()
        }

        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(48.5)
            make.centerX.equalToSuperview()
        }
    }

    func show() {
        layoutIfNeeded()

        DispatchQueue.main.async {
            UIView.animate(withDuration: 2.0, animations: {
                self.bottomView.snp.remakeConstraints { make in
                    make.leading.equalToSuperview()
                    make.trailing.equalToSuperview()
                    make.bottom.equalToSuperview()
                    make.height.equalTo(274)
                }
            })
        }
    }

    func dismiss() {
        if bottomView.subviews.count <= 0 {
            return
        }

        layoutIfNeeded()
        UIView.animate(withDuration: 2.0) {
            self.bottomView.snp.remakeConstraints { make in
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.bottom.equalToSuperview().offset(274)
                make.height.equalTo(274)
            }
        }
        backView.removeFromSuperview()
        bottomView.removeFromSuperview()
        topView.removeFromSuperview()
        detailLabel.removeFromSuperview()
        textField.removeFromSuperview()
        headImage.removeFromSuperview()
        removeFromSuperview()
    }
}

extension ChatGPTBottomPopView {
    func popView(block: @escaping () -> Void, nickName: @escaping (String) -> Void) -> ChatGPTBottomPopView {
        headImageBlock = block
        nickNameBlock = nickName
        frame = UIScreen.main.bounds
        addViewContents()
        addViewConstraints()
        show()
        return self
    }

    func refreshHeadImage(_ image: UIImage) {
        headImage.image = image
    }
}

extension ChatGPTBottomPopView: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        let nickName = textField.text ?? "ChatGPT"
        UserDefaultsCore.set(value: nickName.gys.localized, for: nickNameUserInfo)
        nickNameBlock?(nickName)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
//        let _ = text.trimmingCharacters(in: .whitespaces).isEmpty
        if text.count > 16 {
            return false
        }
        return true
    }
}

@objc extension ChatGPTBottomPopView {
    private func handleTapGesture(_ tap: UITapGestureRecognizer) {
        dismiss()
    }

    private func selectImageTapGesture(_ tap: UITapGestureRecognizer) {
        headImageBlock?()
    }
}
