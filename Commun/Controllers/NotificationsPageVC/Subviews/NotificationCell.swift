//
//  NotificationCell.swift
//  Commun
//
//  Created by Chung Tran on 1/15/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift

protocol NotificationCellDelegate: class {}

class NotificationCell: MyTableViewCell, ListItemCellType {
    // MARK: - Properties
    weak var delegate: NotificationCellDelegate?
    var item: ResponseAPIGetNotificationItem?
    var contentTrailingConstraint: NSLayoutConstraint?
    
    // MARK: - Subviews
    lazy var isNewMark = UIView(width: 6, height: 6, backgroundColor: .appMainColor, cornerRadius: 3)
    lazy var avatarImageView = MyAvatarImageView(size: 44)
    lazy var iconImageView: UIImageView = UIImageView(width: 22, height: 22, cornerRadius: 11)
    lazy var contentContainerView = UIView(forAutoLayout: ())
    lazy var contentLabel = UILabel.with(text: "Notification", textSize: 15, numberOfLines: 4)
    lazy var timestampLabel = UILabel.with(text: "ago", textSize: 13, textColor: .a5a7bd)
    lazy var descriptionImageView = UIImageView(width: 44, height: 44, cornerRadius: 10)
    lazy var actionButton = CommunButton.default(label: "follow")
    
    override func setUpViews() {
        super.setUpViews()
        contentView.backgroundColor = .white
        contentView.addSubview(isNewMark)
        isNewMark.autoPinTopAndLeadingToSuperView(inset: 13)
        
        contentView.addSubview(avatarImageView)
        avatarImageView.autoPinTopAndLeadingToSuperView(inset: 16)
        contentView.bottomAnchor.constraint(greaterThanOrEqualTo: avatarImageView.bottomAnchor, constant: 16)
            .isActive = true
        
        iconImageView.contentMode = .scaleAspectFill
        contentView.addSubview(iconImageView)
        iconImageView.autoPinEdge(.trailing, to: .trailing, of: avatarImageView, withOffset: 4)
        iconImageView.autoPinEdge(.bottom, to: .bottom, of: avatarImageView, withOffset: 4)
        
        contentView.addSubview(contentContainerView)
        contentContainerView.autoPinEdge(.top, to: .top, of: avatarImageView)
        contentContainerView.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        contentView.bottomAnchor.constraint(greaterThanOrEqualTo: contentContainerView.bottomAnchor, constant: 16)
            .isActive = true
        
        contentContainerView.addSubview(contentLabel)
        contentLabel.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        contentLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        contentContainerView.addSubview(timestampLabel)
        timestampLabel.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        timestampLabel.autoPinEdge(.top, to: .bottom, of: contentLabel, withOffset: 2)
        timestampLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        // pin trailing of content
        contentTrailingConstraint = contentContainerView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        selectionStyle = .none
    }
    
    // MARk: - Methods
    func setUp(with item: ResponseAPIGetNotificationItem) {
        self.item = item
        
        // clear
        actionButton.removeFromSuperview()
        descriptionImageView.removeFromSuperview()
        contentTrailingConstraint?.isActive = false
        contentTrailingConstraint = contentContainerView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        // common setup
        isNewMark.isHidden = !item.isNew
        
        iconImageView.isHidden = false
        avatarImageView.setAvatar(
            urlString: (item.author ?? item.voter ?? item.user)?.avatarUrl,
            namePlaceHolder: (item.author ?? item.voter ?? item.user)?.username ?? "User")
        
        let dateString = Date.from(string: item.timestamp).string(withFormat: "HH:mm")
        timestampLabel.text = dateString
        
        switch item.eventType {
        case "mention":
            iconImageView.image = UIImage(named: "notifications-page-mention")
            let aStr = NSMutableAttributedString()
                .semibold(item.author?.username ?? "a user".localized().uppercaseFirst)
                .normal(" ")
                .normal("mentioned you in a \(item.entityType ?? "comment")".localized())
                .normal(": \"")
                .normal(item.comment?.shortText ?? "")
                .normal("\"")
            contentLabel.attributedText = aStr
        case "subscribe":
            iconImageView.isHidden = true
            let aStr = NSMutableAttributedString()
                .semibold(item.user?.username ?? "a user".localized().uppercaseFirst)
                .normal(" ")
                .normal("is following you")
            contentLabel.attributedText = aStr
            
            // TODO: follow ?? unfollow
//            contentView.addSubview(actionButton)
//            actionButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
//            actionButton.autoAlignAxis(.horizontal, toSameAxisOf: avatarImageView)
//            actionButton.setTitle("follow", for: .normal)
//            
//            contentTrailingConstraint?.isActive = false
//            contentTrailingConstraint = contentContainerView.autoPinEdge(.trailing, to: .leading, of: actionButton, withOffset: -4)
        case "upvote":
            iconImageView.image = UIImage(named: "notifications-page-upvote")
            let aStr = NSMutableAttributedString()
                .semibold(item.voter?.username ?? "a user".localized().uppercaseFirst)
                .normal(" ")
                .normal("liked".localized() + " " + "your \(item.entityType ?? "post")".localized())
                .normal(": \"")
            
            aStr.normal((item.comment?.shortText ?? item.post?.shortText ?? "") + "...\"")
            contentLabel.attributedText = aStr
            
            if let imageUrl = item.comment?.imageUrl ?? item.post?.imageUrl {
                contentView.addSubview(descriptionImageView)
                descriptionImageView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
                descriptionImageView.autoAlignAxis(.horizontal, toSameAxisOf: avatarImageView)
                
                descriptionImageView.setImageDetectGif(with: imageUrl)
                
                contentTrailingConstraint?.isActive = false
                contentTrailingConstraint = contentContainerView.autoPinEdge(.trailing, to: .leading, of: descriptionImageView, withOffset: -4)
            }
        case "reply":
            iconImageView.image = UIImage(named: "notifications-page-reply")
            let aStr = NSMutableAttributedString()
                .semibold(item.author?.username ?? "a user".localized().uppercaseFirst)
                .normal(" ")
                .normal("left a comment".localized())
                .normal(": \"")
            aStr.normal((item.comment?.shortText ?? "") + "...\"")
            contentLabel.attributedText = aStr
        default:
            iconImageView.isHidden = true
            contentLabel.text = "notification"
        }
    }
}
