//
//  NotificationsPageViewModel.swift
//  Commun
//
//  Created by Chung Tran on 1/15/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxCocoa

class NotificationsPageViewModel: ListViewModel<ResponseAPIGetNotificationItem> {
    var filter: BehaviorRelay<NotificationListFetcher.Filter>
    var unseenCount: BehaviorRelay<UInt64> {
        SocketManager.shared.unseenNotificationsRelay
    }
    
    init() {
        let filter = NotificationListFetcher.Filter(beforeThan: nil, filter: [])
        self.filter = BehaviorRelay<NotificationListFetcher.Filter>(value: filter)
        super.init(fetcher: NotificationListFetcher(filter: filter))
        defer {
            bindFilter()
            observeNewNotifications()
            getStatus()
        }
    }
    
    func bindFilter() {
        filter.distinctUntilChanged()
            .subscribe(onNext: { filter in
                self.fetcher.reset()
                (self.fetcher as! NotificationListFetcher).filter = filter
                self.fetchNext()
            })
            .disposed(by: disposeBag)
    }
    
    func observeNewNotifications() {
        SocketManager.shared.newNotificationsRelay
            .subscribe(onNext: { (items) in
                let newItems = self.fetcher.join(newItems: items)
                self.items.accept(newItems)
            })
            .disposed(by: disposeBag)
    }
    
    func getStatus() {
        RestAPIManager.instance.notificationsGetStatus()
            .map {$0.unseenCount}
            .subscribe(onSuccess: { (unseenCount) in
                self.unseenCount.accept(unseenCount)
            })
            .disposed(by: disposeBag)
    }
}
