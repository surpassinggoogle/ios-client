//
//  ProposalCell.swift
//  Commun
//
//  Created by Chung Tran on 8/13/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

protocol ProposalCellDelegate: class {}

class ProposalCell: MyTableViewCell, ListItemCellType {
    // MARK: - Properties
    weak var delegate: ProposalCellDelegate?
    
    // MARK: - Subviews
    lazy var stackView = UIStackView(axis: .vertical, spacing: 10, alignment: .fill, distribution: .fill)
    
    lazy var mainView = UIView(forAutoLayout: ())
    
    lazy var spacer = UIView(height: 2, backgroundColor: .appLightGrayColor)
    
    lazy var voteContainerView: UIView = {
        let view = UIView(forAutoLayout: ())
        let stackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .fill, distribution: .fill)
        view.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16))
        let button = CommunButton.default(label: "accept".localized().uppercaseFirst)
        button.addTarget(self, action: #selector(acceptButtonDidTouch), for: .touchUpInside)
        stackView.addArrangedSubviews([voteLabel, button])
        return view
    }()
    lazy var voteLabel = UILabel.with(textSize: 15)
    
    override func setUpViews() {
        super.setUpViews()
        backgroundColor = .appWhiteColor
        selectionStyle = .none
        
        contentView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        
        setUpStackView()
    }
    
    func setUpStackView() {
        stackView.addArrangedSubviews([
            mainView,
            spacer,
            voteContainerView
        ])
    }
    
    func setUp(with item: ResponseAPIContentGetProposal) {
        switch item.action {
        case "ban":
            switch item.contentType {
            case "post":
                setUp(with: item.post)
            default:
                // TODO:
                break
            }
        default:
            // TODO:
            break
        }
    }
    
    private func setUp(with post: ResponseAPIContentGetPost?) {
        if !(mainView.subviews.first is CMPostView) {
            addSubviewToMainView(CMPostView(forAutoLayout: ()))
        }
        guard let post = post, let postCell = mainView.subviews.first as? CMPostView else {return}
        postCell.setUp(post: post)
    }
    
    private func addSubviewToMainView(_ subview: UIView) {
        mainView.removeSubviews()
        mainView.addSubview(subview)
        subview.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 16, left: 16, bottom: 6, right: 16))
    }
    
    @objc func acceptButtonDidTouch() {
        
    }
}
