//
//  CreateRulesVC.swift
//  Commun
//
//  Created by Chung Tran on 9/28/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxCocoa

class CreateRulesVC: CMRulesVC, CreateCommunityVCType {
    let isDataValid = BehaviorRelay<Bool>(value: false)
    
    init() {
        let string = "[{\"title\":\"Content\",\"text\":\"- Here you can publish all types of content, create original or publish links to other sources;\\n- Content must be relevant to the thematic of the community;\",\"id\":\"\(String.randomString(length: 8, fromSet: String.latinLetters))\"},{\"title\":\"PROHIBITED\",\"text\":\"- Publishing of NSFW content without tagging it as NSFW;\\n- Publishing of disturbing content, spam or advertisement is strictly forbidden;\\n- Insulting users in comments or posts;\\n- Publishing of personal data of people without their agreement;\",\"id\":\"\(String.randomString(length: 8, fromSet: String.latinLetters))\"},{\"title\":\"Rules violation\",\"text\":\"In case of violation of the rules, comments and posts with violations will be deprived of payments and excluded from displaying in community and general feed. Also, leaders have the right to limit your access to the community\",\"id\":\"\(String.randomString(length: 8, fromSet: String.latinLetters))\"}]"
        let rules = try! JSONDecoder().decode([ResponseAPIContentGetCommunityRule].self, from: string.data(using: .utf8)!)
        
        super.init(originalItems: rules)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUp() {
        super.setUp()
        setUpHeaderView()
    }
    
    override func bind() {
        super.bind()
        itemsRelay.map {!$0.isEmpty}
            .asDriver(onErrorJustReturn: false)
            .drive(isDataValid)
            .disposed(by: disposeBag)
    }
    
    private func setUpHeaderView() {
        let headerView = MyTableHeaderView(tableView: tableView)
        let stackView = UIStackView(axis: .vertical, spacing: 30, alignment: .center, distribution: .fill)
        headerView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0))
        
        let label = UILabel.with(text: "We’ve added some default rules for your community.\nYou can edit, remove or add new rules for this community.".localized().uppercaseFirst, textSize: 15, numberOfLines: 0, textAlignment: .center)
        let spacer = UIView.spacer(height: 1, backgroundColor: .e2e6e8)
        stackView.addArrangedSubviews([
            label,
            spacer
        ])
        spacer.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        label.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -32).isActive = true
    }
}
