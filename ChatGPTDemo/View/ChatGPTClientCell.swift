//
//  ChatGPTClientCell.swift
//  ChatGPTDemo
//
//  Created by jian on 2023/5/30.
//

import UIKit

class ChatGPTClientCell: UITableViewCell {
    weak var delegate: SelectMessageDelegate?

    private lazy var tipLabel: ChatGPTLabel = {
        let optionalLabel = ChatGPTLabel()
        optionalLabel.backgroundColor = UIColor(hexString: "#4A93FF")
        optionalLabel.layer.masksToBounds = true
        optionalLabel.layer.cornerRadius = 8
        optionalLabel.textAlignment = .left
        optionalLabel.numberOfLines = 0
        optionalLabel.gys.setLineSpace(10)
        optionalLabel.font = UIFont.gys.pingFangFont(ofSize: 16)
        optionalLabel.textInsets = UIEdgeInsets(top: 5, left: 10, bottom: 10, right: 5)
        optionalLabel.text = "Try asking me about".gys.localized
        optionalLabel.textColor = UIColor(hexString: "#FFFFFF")
        return optionalLabel
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
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addViewContents() {
        contentView.addSubview(tipLabel)
        contentView.addSubview(selectButton)
    }

    private func addViewConstraints() {
        tipLabel.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualToSuperview().offset(60)
            make.top.equalToSuperview().offset(5)
            make.trailing.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-5)
        }

        selectButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-15)
            make.size.equalTo(CGSize(width: 18, height: 18))
            make.centerY.equalTo(tipLabel)
        }
    }
}

extension ChatGPTClientCell {
    @objc private func selectClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        delegate?.selectMessage(self, sender.isSelected)
    }
}

extension ChatGPTClientCell {
    func setUpText(model: ChatGPTMessageModel) {
        tipLabel.text = model.text
        selectButton.isSelected = model.isSelect
    }

    func editMessage(_ isEdit: Bool) {
        if isEdit {
            tipLabel.snp.updateConstraints { make in
                make.trailing.equalToSuperview().offset(-43)
            }
            selectButton.isHidden = false
        } else {
            tipLabel.snp.updateConstraints { make in
                make.trailing.equalToSuperview().offset(-15)
            }
            selectButton.isHidden = true
        }
    }
}
