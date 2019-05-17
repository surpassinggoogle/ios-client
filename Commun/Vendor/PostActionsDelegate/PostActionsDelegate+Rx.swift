//
//  PostActionsDelegate+Rx.swift
//  Commun
//
//  Created by Chung Tran on 17/05/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import CyberSwift

extension PostActionsDelegate {
    func upVoteObserver(_ post: ResponseAPIContentGetPost) -> Completable {
        var voteType = VoteType.upvote
        if post.votes.hasUpVote {voteType = .unvote}
        
        return NetworkService.shared.voteMessage(voteType: voteType,
                                                 messagePermlink: post.contentId.permlink,
                                                 messageAuthor: post.author?.username ?? "",
                                                 refBlockNum: post.contentId.refBlockNum)
    }
    
    func downVoteObserver(_ post: ResponseAPIContentGetPost) -> Completable {
        var voteType = VoteType.downvote
        if post.votes.hasUpVote {voteType = .unvote}
        
        return NetworkService.shared.voteMessage(voteType: voteType,
                                                 messagePermlink: post.contentId.permlink,
                                                 messageAuthor: post.author?.username ?? "",
                                                 refBlockNum: post.contentId.refBlockNum)
    }
}
