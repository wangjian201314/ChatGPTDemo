//
//  ChatGPTTableFooterView.swift
//  ChatGPTDemo
//
//  Created by jian on 2023/5/30.
//

import UIKit

class ChatGPTTableFooterView: UIView {
    typealias TopicRandomBlock = (String) -> Void
    var topicBlock: TopicRandomBlock?

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

    private var topArray: [TopicListModel] = []

    private lazy var tipLabel: UILabel = {
        let optionalLabel = UILabel()
        optionalLabel.font = UIFont.gys.pingFangFont(ofSize: 16)
        optionalLabel.text = "Try asking me about".gys.localized
        optionalLabel.textColor = UIColor(hexString: "#333333")
        return optionalLabel
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = UIColor(hexString: "#F9F9F9")
        scrollView.isPagingEnabled = true
        return scrollView
    }()

    private func addViewContents() {
        addSubview(tipLabel)
        addSubview(scrollView)
    }

    private func addViewConstraints() {
        tipLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(10)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(tipLabel.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview()
            make.size.equalTo(CGSize(width: UIScreen.main.bounds.size.width, height: 30))
        }
    }

    func createButton(topList: [TopicListModel]) {
        topArray = topList
        for view in subviews where view.isKind(of: UIButton.self) {
            view.removeFromSuperview()
        }

        let space = 10.0
        let margin = 15.0
        let height = 30.0
        var lastButton = UIButton(type: .custom)
        var totalWidth: CGFloat = 2 * margin
        for i in 0 ..< topList.count {
            let model = topList[i]
            let button = UIButton(type: .custom)
            button.tag = i
            button.layer.masksToBounds = true
            button.layer.cornerRadius = 15
            button.layer.borderColor = UIColor(hexString: "#CCCCCC")?.cgColor
            button.layer.borderWidth = 0.5
            button.titleLabel?.font = UIFont.gys.pingFangFont(ofSize: 14)
            button.setTitle(model.topicName, for: .normal)
            button.setTitleColor(UIColor(hexString: "#666666"), for: .normal)
            button.addTarget(self, action: #selector(topicClick(_:)), for: .touchUpInside)
            button.backgroundColor = UIColor(hexString: "#F9F9F9")
            scrollView.addSubview(button)
            let width = button.sizeThatFits(CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT))).width
            let spaces = width + space * 3
            totalWidth += spaces
            button.snp.makeConstraints { make in
                if i == 0 {
                    make.leading.equalToSuperview().offset(15.0)
                } else {
                    make.leading.equalTo(lastButton.snp.trailing).offset(10)
                }
                make.top.equalToSuperview()
                make.size.equalTo(CGSize(width: width + 2 * space, height: height))
            }
            lastButton = button
        }
        scrollView.contentSize = CGSize(width: totalWidth, height: 0)
    }
}

extension ChatGPTTableFooterView {
    @objc private func topicClick(_ sender: UIButton) {
        let topListModel = topArray[sender.tag]
        let questionArray = topListModel.questions
        guard let question = questionArray.randomElement()?.question else { return }

        topicBlock?(question)
    }
}
