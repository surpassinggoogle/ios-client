//
//  ListItemCell.swift
//  Commun
//
//  Created by Chung Tran on 11/29/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift

protocol ListItemCellType: UITableViewCell {
    associatedtype T: ListItemType
    func setUp(with item: T)
}
