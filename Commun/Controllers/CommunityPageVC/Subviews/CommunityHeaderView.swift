//
//  CommunityHeaderView.swift
//  Commun
//
//  Created by Chung Tran on 10/23/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class CommunityHeaderView: MyTableHeaderView {
    // MARK: - Subviews
    lazy var backButton: UIButton = {
        let button = UIButton(width: 24, height: 40, contentInsets: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 12))
        button.tintColor = .white
        button.setImage(UIImage(named: "back"), for: .normal)
        button.addTarget(self, action: #selector(backButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var coverImageView: UIImageView = {
        let imageView = UIImageView(height: 180)
        imageView.image = UIImage(named: "ProfilePageCover")
        return imageView
    }()
    
    lazy var contentView: UIView = {
        let view = UIView(height: 243, backgroundColor: .white)
        view.cornerRadius = 25
        
        view.addSubview(avatarImageView)
        avatarImageView.autoPinEdge(toSuperviewEdge: .top, withInset: 16)
        avatarImageView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        
        view.addSubview(nameLabel)
        nameLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
        nameLabel.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        
        view.addSubview(joinedDateLabel)
        joinedDateLabel.autoPinEdge(.top, to: .bottom, of: nameLabel)
        joinedDateLabel.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        
        view.addSubview(joinButton)
        joinButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        joinButton.autoAlignAxis(.horizontal, toSameAxisOf: avatarImageView)
        
        view.addSubview(descriptionLabel)
        descriptionLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        descriptionLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        descriptionLabel.autoPinEdge(.top, to: .bottom, of: avatarImageView, withOffset: 10)
        
        view.addSubview(membersCountLabel)
        membersCountLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        membersCountLabel.autoPinEdge(.top, to: .bottom, of: descriptionLabel, withOffset: 24)
        
        let memberLabel = UILabel.with(text: "members".localized().uppercaseFirst, textSize: 12, weight: .semibold, textColor: UIColor(hexString: "#A5A7BD")!)
        view.addSubview(memberLabel)
        memberLabel.autoPinEdge(.leading, to: .trailing, of: membersCountLabel, withOffset: 4)
        memberLabel.autoPinEdge(.bottom, to: .bottom, of: membersCountLabel, withOffset: -1)

        let dotLabel = UILabel.with(text: "•", textSize: 15, weight: .semibold, textColor: UIColor(hexString: "#A5A7BD")!)
        view.addSubview(dotLabel)
        dotLabel.autoPinEdge(.leading, to: .trailing, of: memberLabel, withOffset: 2)
        dotLabel.autoPinEdge(.bottom, to: .bottom, of: memberLabel)

        view.addSubview(leadsCountLabel)
        leadsCountLabel.autoPinEdge(.leading, to: .trailing, of: dotLabel, withOffset: 2)
        leadsCountLabel.autoAlignAxis(.horizontal, toSameAxisOf: membersCountLabel)

        let leadsLabel = UILabel.with(text: "leads".localized().uppercaseFirst, textSize: 12, weight: .semibold, textColor: UIColor(hexString: "#A5A7BD")!)
        view.addSubview(leadsLabel)
        leadsLabel.autoPinEdge(.leading, to: .trailing, of: leadsCountLabel, withOffset: 4)
        leadsLabel.autoPinEdge(.bottom, to: .bottom, of: leadsCountLabel, withOffset: -1)
        
        view.addSubview(pointsContainerView)
        pointsContainerView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        pointsContainerView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        pointsContainerView.autoPinEdge(.top, to: .bottom, of: membersCountLabel, withOffset: 22)
        
        return view
    }()
    
    lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView(width: 50, height: 50)
        imageView.cornerRadius = 25
        imageView.image = UIImage(named: "ProfilePageCover")
        return imageView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel.with(text: "Community", textSize: 20, weight: .bold)
        return label
    }()
    
    lazy var joinedDateLabel: UILabel = {
        let label = UILabel.descriptionLabel("Joined", size: 12)
        return label
    }()
    
    lazy var joinButton: UIButton = {
        let button = UIButton(height: 35, label: "join".localized().uppercaseFirst, labelFont: .boldSystemFont(ofSize: 15), backgroundColor: .appMainColor, textColor: .white, cornerRadius: 35 / 2, contentInsets: UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20))
        return button
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel.with(text: "Binance Exchange provides cryptocurrency trading for fintech and blockchain enthusiasts", textSize: 14, numberOfLines: 0)
        return label
    }()
    
    lazy var membersCountLabel: UILabel = {
        let label = UILabel.with(text: "1,2 k", textSize: 15, weight: .bold)
        return label
    }()
    
    lazy var leadsCountLabel: UILabel = {
        let label = UILabel.with(text: "7", textSize: 15, weight: .bold)
        return label
    }()
    
    lazy var pointsContainerView: UIView = {
        let view = UIView(height: 70, backgroundColor: .appMainColor)
        view.cornerRadius = 10
        view.addSubview(walletImageView)
        walletImageView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        walletImageView.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        view.addSubview(walletCurrencyValue)
        walletCurrencyValue.autoPinEdge(.leading, to: .trailing, of: walletImageView, withOffset: 10)
        walletCurrencyValue.autoPinEdge(.top, to: .top, of: walletImageView)
        
        view.addSubview(walletCurrencyLabel)
        walletCurrencyLabel.autoPinEdge(.leading, to: .trailing, of: walletCurrencyValue, withOffset: 2)
        walletCurrencyLabel.autoPinEdge(.bottom, to: .bottom, of: walletCurrencyValue, withOffset: -2)
        
        let equalLabel = UILabel.with(text: "=", textSize: 12, weight: .semibold, textColor: .white)
        view.addSubview(equalLabel)
        equalLabel.autoPinEdge(.leading, to: .trailing, of: walletImageView, withOffset: 10)
        equalLabel.autoPinEdge(.top, to: .bottom, of: walletCurrencyValue, withOffset: 2)
        
        view.addSubview(communValueLabel)
        communValueLabel.autoPinEdge(.leading, to: .trailing, of: equalLabel, withOffset: 2)
        communValueLabel.autoAlignAxis(.horizontal, toSameAxisOf: equalLabel)
        
        let communLabel = UILabel.with(text: "Commun", textSize: 12, weight: .semibold, textColor: .white)
        view.addSubview(communLabel)
        communLabel.autoPinEdge(.leading, to: .trailing, of: communValueLabel, withOffset: 2)
        communLabel.autoAlignAxis(.horizontal, toSameAxisOf: equalLabel)
        return view
    }()
    
    lazy var walletImageView: UIImageView = {
        let imageView = UIImageView(width: 40, height: 40, backgroundColor: .clear)
        imageView.cornerRadius = 20
        imageView.image = UIImage(named: "community-wallet")
        return imageView
    }()
    
    lazy var walletCurrencyValue: UILabel = {
        let label = UILabel.with(text: "1000", textSize: 20, weight: .semibold, textColor: .white)
        return label
    }()
    
    lazy var walletCurrencyLabel: UILabel = {
        let label = UILabel.with(text: "Binance", textSize: 12, weight: .semibold, textColor: .white)
        return label
    }()
    
    lazy var communValueLabel: UILabel = {
        let label = UILabel.with(text: "1", textSize: 12, weight: .semibold, textColor: .white)
        return label
    }()
    
    override func commonInit() {
        super.commonInit()
        backgroundColor = .white
        
        addSubview(backButton)
        backButton.autoPinEdge(toSuperviewSafeArea: .top, withInset: 8)
        backButton.autoPinEdge(toSuperviewSafeArea: .leading, withInset: 16)
        
        addSubview(coverImageView)
        coverImageView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        bringSubviewToFront(backButton)
        
        addSubview(contentView)
        contentView.autoPinEdge(.top, to: .bottom, of: coverImageView, withOffset: -25)
        contentView.autoPinEdge(toSuperviewEdge: .leading)
        contentView.autoPinEdge(toSuperviewEdge: .trailing)
        
        #warning("remove later")
        contentView.autoPinEdge(toSuperviewEdge: .bottom)
    }
    
    @objc func backButtonTapped(_ sender: UIButton) {
        parentViewController?.back()
    }
}
