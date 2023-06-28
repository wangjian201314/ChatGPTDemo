//
//  ChatGPTPopViewCell.swift
//  ChatGPTDemo
//
//  Created by jian on 2023/6/8.
//

import UIKit

class ChatGPTPopViewCell: UITableViewCell {
    private lazy var tipLabel: UILabel = {
        let optionalLabel = UILabel()
        optionalLabel.textColor = UIColor(hexString: "#FFFFFF")
        optionalLabel.font = UIFont.gys.pingFangFont(ofSize: 14)
        return optionalLabel
    }()

    private lazy var iconImage: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    private lazy var lineView: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = UIColor(hexString: "#FFFFFF")?.withAlphaComponent(0.1)
        return lineView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = UIColor(hexString: "#4C4C4C")
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
        contentView.addSubview(iconImage)
        contentView.addSubview(lineView)
    }

    private func addViewConstraints() {
        iconImage.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(6)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 16, height: 16))
        }

        tipLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImage.snp.trailing).offset(5)
            make.centerY.equalToSuperview()
        }

        lineView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
            make.leading.equalToSuperview().offset(5)
            make.trailing.equalToSuperview().offset(-5)
        }
    }
}

extension ChatGPTPopViewCell {
    func setUpData(_ model: ChatGPTPopModel) {
        tipLabel.text = model.text
        iconImage.image = UIImage(named: model.imageName)
    }
}
