//
//  CommentCellController.swift
//  Commun
//
//  Created by Chung Tran on 12/2/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

protocol CommentCellDelegate: class {
//    var replyingComment: ResponseAPIContentGetComment? {get set}
    var expandedComments: [ResponseAPIContentGetComment] {get set}
    var tableView: UITableView {get set}
    func cell(_ cell: CommentCell, didTapUpVoteForComment comment: ResponseAPIContentGetComment)
    func cell(_ cell: CommentCell, didTapDownVoteForComment comment: ResponseAPIContentGetComment)
    func cell(_ cell: CommentCell, didTapMoreActionFor comment: ResponseAPIContentGetComment)
    func cell(_ cell: CommentCell, didTapReplyButtonForComment comment: ResponseAPIContentGetComment)
    func cell(_ cell: CommentCell, didTapSeeMoreButtonForComment comment: ResponseAPIContentGetComment)
    func cell(_ cell: CommentCell, didTapOnTag tag: String)
    func cell(_ cell: CommentCell, didTapDeleteForComment comment: ResponseAPIContentGetComment)
    func cell(_ cell: CommentCell, didTapEditForComment comment: ResponseAPIContentGetComment)
    func cell(_ cell: CommentCell, didTapRetryForComment comment: ResponseAPIContentGetComment)
}

extension CommentCellDelegate where Self: BaseViewController {
    func cell(_ cell: CommentCell, didTapSeeMoreButtonForComment comment: ResponseAPIContentGetComment) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        if !expandedComments.contains(where: {$0.identity == comment.identity}) {
            expandedComments.append(comment)
        }
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    func cell(_ cell: CommentCell, didTapOnUserName userName: String) {
        showProfileWithUserId(userName)
    }
    
    func cell(_ cell: CommentCell, didTapOnTag tag: String) {
        #warning("open tag")
    }
    
    func cell(_ cell: CommentCell, didTapMoreActionFor comment: ResponseAPIContentGetComment) {
        let headerView = UIView(frame: .zero)
        
        let avatarImageView = MyAvatarImageView(size: 40)
        headerView.addSubview(avatarImageView)
        avatarImageView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .trailing)
        
        let nameLabel = UILabel.with(textSize: 15, weight: .bold)
        headerView.addSubview(nameLabel)
        nameLabel.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        nameLabel.autoAlignAxis(.horizontal, toSameAxisOf: avatarImageView)
        nameLabel.autoPinEdge(toSuperviewEdge: .trailing)
        
        let actions: [CommunActionSheet.Action]
        
        if comment.author?.userId == Config.currentUser?.id {
            // edit, delete
            actions = [
                CommunActionSheet.Action(
                    title: "edit".localized().uppercaseFirst,
                    icon: UIImage(named: "edit"),
                    handle: {
                        self.cell(cell, didTapEditForComment: comment)
                    },
                    tintColor: .black),
                CommunActionSheet.Action(
                    title: "delete".localized().uppercaseFirst,
                    icon: UIImage(named: "delete"),
                    handle: {
                        self.deleteComment(comment)
                    },
                    tintColor: UIColor(hexString: "#ED2C5B")!)
            ]
        }
        else {
            // report
            actions = [
                CommunActionSheet.Action(
                    title: "report".localized().uppercaseFirst,
                    icon: UIImage(named: "report"),
                    handle: {
                        self.reportComment(comment)
                    },
                    tintColor: UIColor(hexString: "#ED2C5B")!)
            ]
        }
        
        showCommunActionSheet(
            headerView: headerView,
            actions: actions,
            completion: {
                avatarImageView.setAvatar(urlString: comment.author?.avatarUrl, namePlaceHolder: comment.author?.username ?? "U")
                nameLabel.text = comment.author?.username
            })
    }
    
    func cell(_ cell: CommentCell, didTapUpVoteForComment comment: ResponseAPIContentGetComment) {
        NetworkService.shared.upvoteMessage(message: comment)
            .subscribe { (error) in
                UIApplication.topViewController()?.showError(error)
            }
            .disposed(by: self.disposeBag)
    }
    func cell(_ cell: CommentCell, didTapDownVoteForComment comment: ResponseAPIContentGetComment) {
        NetworkService.shared.downvoteMessage(message: comment)
            .subscribe { (error) in
                UIApplication.topViewController()?.showError(error)
            }
            .disposed(by: self.disposeBag)
    }
    
    func reportComment(_ comment: ResponseAPIContentGetComment) {
        let vc = ContentReportVC(content: comment)
        let nc = BaseNavigationController(rootViewController: vc)
        
        nc.modalPresentationStyle = .custom
        nc.transitioningDelegate = vc
        UIApplication.topViewController()?
            .present(nc, animated: true, completion: nil)
    }
    
    func deleteComment(_ comment: ResponseAPIContentGetComment) {
        guard let topController = UIApplication.topViewController()
        else {return}
        
        topController.showAlert(
            title: "delete".localized().uppercaseFirst,
            message: "do you really want to delete this comment".localized().uppercaseFirst + "?",
            buttonTitles: [
                "yes".localized().uppercaseFirst,
                "no".localized().uppercaseFirst],
            highlightedButtonIndex: 1)
            { (index) in
                if index == 0 {
                    topController.showIndetermineHudWithMessage("deleting comment".localized().uppercaseFirst)
                    NetworkService.shared.deleteMessage(message: comment)
                        .subscribe(onCompleted: {
                            topController.hideHud()
                        }, onError: { error in
                            topController.hideHud()
                            topController.showError(error)
                        })
                        .disposed(by: self.disposeBag)
                }
            }
    }
}
