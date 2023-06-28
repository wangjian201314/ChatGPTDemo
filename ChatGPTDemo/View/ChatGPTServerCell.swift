//
//  ChatGPTServerCel.swift
//  ChatGPTDemo
//
//  Created by jian on 2023/5/19.
//

import MarkdownKit
import SVProgressHUD
import UIKit

protocol SelectMessageDelegate: AnyObject {
    func selectMessage(_ cell: UITableViewCell, _ isSelect: Bool)
    func longPress(_ cell: UITableViewCell)
}

class ChatGPTServerCel: UITableViewCell {
    weak var delegate: SelectMessageDelegate?

    private var messageModel = ChatGPTMessageModel.empty

    private lazy var tipLabel: ChatGPTLabel = {
        let optionalLabel = ChatGPTLabel()
        optionalLabel.backgroundColor = UIColor(hexString: "#F7F7F7")
        optionalLabel.layer.masksToBounds = true
        optionalLabel.numberOfLines = 0
        optionalLabel.layer.cornerRadius = 8
        optionalLabel.textAlignment = .left
        optionalLabel.font = UIFont.gys.pingFangFont(ofSize: 16)
        optionalLabel.gys.setLineSpace(10)
        optionalLabel.textInsets = UIEdgeInsets(top: 5, left: 10, bottom: 10, right: 5)
        optionalLabel.text = "光年是距离的单位，而不是时间，这在天文学中常用来描述太空中的大距离。具体来说，它是光在一年内传播的距离，约为5.88万亿英里或9.46万亿公里。".gys.localized
        optionalLabel.textColor = UIColor(hexString: "#333333")
        return optionalLabel
    }()

    private lazy var bottomButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 15
        button.titleLabel?.font = UIFont.gys.pingFangFont(ofSize: 14)
        button.imageEdgeInsets =
            UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        button.titleEdgeInsets =
            UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        button.backgroundColor = UIColor(hexString: "#F7F7F7")
        button.setImage(UIImage(named: "MessageCopy"), for: .normal)
        button.setTitle("Copy".gys.localized, for: .normal)
        button.setTitleColor(UIColor(hexString: "#333333"), for: .normal)
        button.addTarget(self, action: #selector(copyClick(_:)), for: .touchUpInside)
        return button
    }()

    private lazy var backview: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: "#F7F7F7")
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 8
        return view
    }()

    private lazy var selectButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "MessageUnSelect"), for: .normal)
        button.setImage(UIImage(named: "MessageSelect"), for: .selected)
        button.addTarget(self, action: #selector(selectClick(_:)), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .white
        selectionStyle = .none
        addViewContents()
        addViewConstraints()

        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        contentView.addGestureRecognizer(longPressGestureRecognizer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addViewContents() {
        contentView.addSubview(tipLabel)
        contentView.addSubview(selectButton)
        contentView.addSubview(bottomButton)
    }

    private func addViewConstraints() {
        tipLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(5)
            make.trailing.lessThanOrEqualToSuperview().offset(-60)
            make.bottom.equalToSuperview().offset(-40)
        }

        selectButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.size.equalTo(CGSize(width: 18, height: 18))
            make.centerY.equalTo(tipLabel)
        }

        bottomButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.bottom.equalToSuperview().offset(-5)
            make.size.equalTo(CGSize(width: 70, height: 30))
        }
    }
}

extension ChatGPTServerCel {
    func setUpText(model: ChatGPTMessageModel, isHidden: Bool) {
        messageModel = model
        let markdown = model.text
        let parser = MarkdownParser(font: UIFont.gys.pingFangFont(ofSize: 18), color: .black, enabledElements: .all, customElements: [])
        let attributedString = parser.parse(markdown)
        tipLabel.attributedText = attributedString
        selectButton.isSelected = model.isSelect
        bottomButton.isHidden = isHidden

        tipLabel.snp.updateConstraints { make in
            make.bottom.equalToSuperview().offset(isHidden ? -5 : -40)
        }
    }

    func editMessage(_ isEdit: Bool) {
        if isEdit {
            tipLabel.snp.updateConstraints { make in
                make.leading.equalToSuperview().offset(43)
            }
            selectButton.isHidden = false
        } else {
            tipLabel.snp.updateConstraints { make in
                make.leading.equalToSuperview().offset(15)
            }
            selectButton.isHidden = true
        }
    }
}

@objc extension ChatGPTServerCel {
    private func selectClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        delegate?.selectMessage(self, sender.isSelected)
    }

    private func copyClick(_ sender: UIButton) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = messageModel.text
        SVProgressHUD.showSuccess(withStatus: "Copied".gys.localized)
    }

    private func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        delegate?.longPress(self)
    }
}

class ChatGPTLabel: UILabel {
    var textInsets: UIEdgeInsets = .zero

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }

    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insets = textInsets
        var rect = super.textRect(forBounds: bounds.inset(by: insets), limitedToNumberOfLines: numberOfLines)

        rect.origin.x -= insets.left
        rect.origin.y -= insets.top
        rect.size.width += (insets.left + insets.right)
        rect.size.height += (insets.top + insets.bottom)
        return rect
    }
}
