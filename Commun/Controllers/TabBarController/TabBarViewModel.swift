//
//  TabBarViewModel.swift
//  Commun
//
//  Created by Chung Tran on 15/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift

struct TabBarViewModel {
    func getFreshCount() -> Single<UInt16> {
        return NetworkService.shared.getFreshNotifications()
            .map {$0.fresh}
    }
}
