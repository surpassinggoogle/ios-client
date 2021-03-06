//
//  BalancesVC.swift
//  Commun
//
//  Created by Chung Tran on 12/23/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxDataSources

class BalancesVC: SubsViewController<ResponseAPIWalletGetBalance, BalanceCell> {
    // MARK: - Properties
    var canChooseCommun: Bool
    var completion: ((ResponseAPIWalletGetBalance) -> Void)?
    var showEmptyBalances: Bool
    
    // MARK: - Initializers
    init(userId: String? = nil, canChooseCommun: Bool = true, showEmptyBalances: Bool = true, completion: ((ResponseAPIWalletGetBalance) -> Void)? = nil) {
        self.canChooseCommun = canChooseCommun
        self.showEmptyBalances = showEmptyBalances
        self.completion = completion
        
        let vm: BalancesViewModel
        if userId == nil || userId == Config.currentUser?.id {
            vm = BalancesViewModel.ofCurrentUser
        } else {
            vm = BalancesViewModel(userId: userId)
        }
        
        super.init(viewModel: vm)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUp() {
        super.setUp()
        title = "points".localized().uppercaseFirst
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
    }
    
    override func configureCell(with item: ResponseAPIWalletGetBalance, indexPath: IndexPath) -> UITableViewCell {
        let cell = super.configureCell(with: item, indexPath: indexPath) as! BalanceCell
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        return cell
    }
    
    override func mapItems(items: [ResponseAPIWalletGetBalance]) -> [AnimatableSectionModel<String, ResponseAPIWalletGetBalance>] {
        return super.mapItems(items: items.hidenEmptyBalances(hide: !showEmptyBalances).sortedByBalanceValue())
    }
    
    override func handleListEmpty() {
        let title = "no balances"
        let description = "you haven't had any balance yet"
        tableView.addEmptyPlaceholderFooterView(emoji: "👁", title: title.localized().uppercaseFirst, description: description.localized().uppercaseFirst)
    }
    
    override func modelSelected(_ item: ResponseAPIWalletGetBalance) {
        if !canChooseCommun && item.symbol == Config.defaultSymbol {return}
        self.completion?(item)
        self.dismiss(animated: true, completion: nil)
    }
}
