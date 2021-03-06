//
//  WalletVC.swift
//  Commun
//
//  Created by Chung Tran on 12/18/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxDataSources

class TransferHistoryVC: ListViewController<ResponseAPIWalletGetTransferHistoryItem, TransferHistoryItemCell> {
    // MARK: - Properties
    var lastOffset: CGPoint?

    // MARK: - Initializers
    init(viewModel: TransferHistoryViewModel = TransferHistoryViewModel()) {
        super.init(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUp() {
        super.setUp()
        view.backgroundColor = .appLightGrayColor
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
    }
    
    override func bind() {
        super.bind()
        
        tableView.rx.endUpdatesEvent
            .subscribe(onNext: {_ in
                if let offset = self.lastOffset {
                    self.tableView.layoutIfNeeded()
                    self.tableView.contentOffset = offset
                }
            })
            .disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    override func configureCell(with item: ResponseAPIWalletGetTransferHistoryItem, indexPath: IndexPath) -> UITableViewCell {
        let cell = super.configureCell(with: item, indexPath: indexPath) as! TransferHistoryItemCell
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        cell.roundedCorner = []
        
        if let lastSectionItemsCount = dataSource.sectionModels.last?.items.count,
            indexPath.section == dataSource.sectionModels.count - 1,
            indexPath.row == lastSectionItemsCount - 1
        {
            cell.roundedCorner.insert([.bottomLeft, .bottomRight])
        }
        
        return cell
    }
    
    override func mapItems(items: [ResponseAPIWalletGetTransferHistoryItem]) -> [AnimatableSectionModel<String, ResponseAPIWalletGetTransferHistoryItem>] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dictionary = Dictionary(grouping: items) { item -> Int in
            let date = Date.from(string: item.timestamp)
            let createdDate = calendar.startOfDay(for: date)
            return calendar.dateComponents([.day], from: createdDate, to: today).day ?? 0
        }
        
        return dictionary.keys.sorted()
            .map { (key) -> ListSection in
                var sectionLabel: String
                switch key {
                case 0:
                    sectionLabel = "today".localized().uppercaseFirst
                case 1:
                    sectionLabel = "yesterday".localized().uppercaseFirst
                default:
                    sectionLabel = String(format: NSLocalizedString("%d day", comment: ""), key) + " " + "ago".localized()
                }
                return ListSection(model: sectionLabel, items: dictionary[key] ?? [])
            }
    }
    
    override func modelSelected(_ selectedItem: ResponseAPIWalletGetTransferHistoryItem) {
        // .history type
        var friend: Friend?
        var amount: CGFloat = 0.0
        var symbol: Symbol = Symbol(sell: selectedItem.symbol, buy: selectedItem.symbol)
        
        var isReceiver = false
        var person = selectedItem.receiver
        if person.userId == Config.currentUser?.id {
            person = selectedItem.sender
            isReceiver = true
        }
        friend = Friend(id: person.userId, name: person.username ?? Config.defaultSymbol, avatarURL: person.avatarUrl)
        amount = (isReceiver ? 1 : -1) * CGFloat(selectedItem.quantityValue)
        
        if friend?.id == Config.currentUser?.id {
            friend = nil
        }
        
        switch selectedItem.meta.actionType {
        case "convert":
            amount = CGFloat(selectedItem.meta.exchangeAmount ?? 0.0)
            
            if selectedItem.symbol != Config.defaultSymbol {
                symbol.sell = selectedItem.point.symbol ?? Config.defaultSymbol
                symbol.buy = Config.defaultSymbol
            } else {
                symbol.buy = selectedItem.point.symbol ?? Config.defaultSymbol
                symbol.sell = Config.defaultSymbol
            }
            
        default:
            break
        }
        
        let transaction = Transaction(buyBalance: nil,
                                      sellBalance: nil,
                                      friend: friend,
                                      amount: amount,
                                      history: selectedItem,
                                      actionType: selectedItem.meta.actionType ?? "send",
                                      symbol: symbol,
                                      operationDate: selectedItem.timestamp.convert(toDateFormat: .nextSmsDateType))
        
        let completedVC = TransactionInfoVC(transaction: transaction)
        completedVC.modalPresentationStyle = .overCurrentContext
        completedVC.modalTransitionStyle = .crossDissolve
        tabBarController?.present(completedVC, animated: true, completion: nil)
        
        hideHud()
        
        completedVC.completionRepeat = { [weak self] in
            guard let strongSelf = self else { return }
            
            let walletSendPointsVC = CMSendPointsVC(selectedBalanceSymbol: transaction.symbol.sell, receiver: selectedItem.receiver, history: selectedItem)
            
            if let communWalletVC = strongSelf.navigationController?.viewControllers.filter({ $0 is CommunWalletVC }).first as? CommunWalletVC {
                strongSelf.navigationController?.popToViewController(communWalletVC, animated: false)

                switch selectedItem.meta.actionType {
                case "transfer":
                    communWalletVC.show(walletSendPointsVC, sender: nil)
                    
                case "convert":
                    communWalletVC.routeToConvertScene(withTransacion: transaction)
                    
                default:
                    break
                }

                strongSelf.hideHud()
                communWalletVC.appLiked()
             }
        }
    }
    
    override func handleListEmpty() {
        let title = "no transactions"
        let description = "you haven't had any transactions yet"
        tableView.addEmptyPlaceholderFooterView(emoji: "👁", title: title.localized().uppercaseFirst, description: description.localized().uppercaseFirst)
    }
    
    override func handleLoading() {
        tableView.addNotificationsLoadingFooterView()
    }
    
    // MARK: - Actions
    @objc func openFilter() {
        let vc = TransferHistoryFilterVC(filter: (viewModel as! TransferHistoryViewModel).filter.value)
        vc.completion = {filter in
            self.filterChanged(filter)
        }
        present(vc, animated: true, completion: nil)
    }
    
    func filterChanged(_ filter: TransferHistoryListFetcher.Filter) {
        lastOffset = tableView.contentOffset
        (viewModel as! TransferHistoryViewModel).filter.accept(filter)
        viewModel.state
            .filter {$0 != .loading(true)}
            .first()
            .subscribe(onSuccess: { _ in
                DispatchQueue.main.async {
                    self.lastOffset = nil
                }
            })
            .disposed(by: disposeBag)
    }
}

extension TransferHistoryVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        
        let headerView = UIView(frame: .zero)
        headerView.backgroundColor = .appWhiteColor
        view.addSubview(headerView)
        headerView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        
        let label = UILabel.with(text: dataSource.sectionModels[section].model, textSize: 12, weight: .semibold)
        headerView.addSubview(label)
        label.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        label.autoAlignAxis(toSuperviewAxis: .horizontal)
        return view
    }
    
    // https://stackoverflow.com/questions/1074006/is-it-possible-to-disable-floating-headers-in-uitableview-with-uitableviewstylep
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView(frame: .zero)
    }
}
