//
//  NotificationsPageViewModel.swift
//  Commun
//
//  Created by Chung Tran on 10/04/2019.
//  Copyright (c) 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

struct NotificationsPageViewModel {
    let bag = DisposeBag()
    let list = BehaviorRelay<[ResponseAPIOnlineNotificationData]>(value: [])
    
    private let fetcher = NotificationsFetcher()
    
    func reload() {
        fetcher.reset()
        fetchNext()
    }
    
    func fetchNext() {
        fetcher.fetchNext()
            .asDriver(onErrorJustReturn: [])
            .map {self.list.value + $0}
            .drive(list)
            .disposed(by: bag)
    }
}
