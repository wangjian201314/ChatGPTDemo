//
//  ChatGPTHeaderView.swift
//  ChatGPTDemo
//
//  Created by jian on 2023/6/7.
//

import UIKit

class ChatGPTHeaderView: UITableViewHeaderFooterView {
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        backgroundColor = .white
        addViewContents()
        addViewConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var tipLabel: UILabel = {
        let optionalLabel = UILabel()
        optionalLabel.font = UIFont.gys.pingFangFont(ofSize: 14)
        optionalLabel.text = "Context cleared".gys.localized
        optionalLabel.textColor = UIColor(hexString: "#B8B8B8")
        optionalLabel.textAlignment = .center
        return optionalLabel
    }()

    private lazy var leftLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: "#CCCCCC")
        return view
    }()

    private lazy var rightLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: "#CCCCCC")
        return view
    }()

    private func addViewContents() {
        addSubview(tipLabel)
        addSubview(leftLineView)
        addSubview(rightLineView)
    }

    private func addViewConstraints() {
        tipLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        leftLineView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(5)
            make.centerY.equalToSuperview()
            make.height.equalTo(0.5)
            make.trailing.equalTo(tipLabel.snp_leadingMargin).offset(-10)
        }

        rightLineView.snp.makeConstraints { make in
            make.leading.equalTo(tipLabel.snp_trailingMargin).offset(5)
            make.centerY.equalToSuperview()
            make.height.equalTo(0.5)
            make.trailing.equalToSuperview().offset(-10)
        }
    }
}
