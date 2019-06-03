//
//  PostListController.swift
//  Commun
//
//  Created by Chung Tran on 24/05/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift
import RxCocoa
import RxSwift
import RxDataSources

protocol ItemsListController {
    associatedtype T: Equatable & IdentifiableType
    var items: BehaviorRelay<[T]> {get set}
    var disposeBag: DisposeBag {get}
    var loadingHandler: (()->Void)? {get set}
    var listEndedHandler: (()->Void)? {get set}
    var fetchNextErrorHandler: ((Error)->Void)? {get set}
}

extension ItemsListController {
    func updateItem(_ updatedItem: T) {
        var newItems = items.value
        guard let index = newItems.firstIndex(where: {$0.identity == updatedItem.identity}) else {return}
        newItems[index] = updatedItem
        items.accept(newItems)
    }
    
    func deleteItem(_ deletedItem: T) {
        let newItems = items.value.filter {$0.identity != deletedItem.identity}
        items.accept(newItems)
    }
}

protocol PostsListController: ItemsListController where T == ResponseAPIContentGetPost {}

extension PostsListController {
    func observePostDelete() {
        NotificationCenter.default.rx.notification(.init(rawValue: PostControllerPostDidDeleteNotification))
            .subscribe(onNext: { (notification) in
                guard let deletedPost = notification.object as? ResponseAPIContentGetPost
                    else {return}
                self.deleteItem(deletedPost)
            })
            .disposed(by: disposeBag)
    }
    
    func observePostChange() {
        NotificationCenter.default.rx.notification(.init(rawValue: PostControllerPostDidChangeNotification))
            .subscribe(onNext: {notification in
                guard let newPost = notification.object as? ResponseAPIContentGetPost
                    else {return}
                self.updateItem(newPost)
            })
            .disposed(by: disposeBag)
    }
}
