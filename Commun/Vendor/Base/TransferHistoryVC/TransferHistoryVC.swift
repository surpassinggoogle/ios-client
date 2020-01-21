//
//  WalletVC.swift
//  Commun
//
//  Created by Chung Tran on 12/18/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class TransferHistoryVC: ListViewController<ResponseAPIWalletGetTransferHistoryItem, TransferHistoryItemCell> {
    // MARK: - Properties
    var lastOffset: CGPoint?

//    var completionTabBarHide: ((Bool) -> Void)?
    
    
    // MARK: - Initializers
    init(viewModel: TransferHistoryViewModel = TransferHistoryViewModel()) {
        super.init(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUp() {
        super.setUp()
        view.backgroundColor = #colorLiteral(red: 0.9591314197, green: 0.9661319852, blue: 0.9840201735, alpha: 1)
        
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
    
    override func bindItems() {
        viewModel.items
            .map { (items) -> [ListSection] in
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
                            sectionLabel = "\(key) " + "days ago".localized()
                        }
                        return ListSection(model: sectionLabel, items: dictionary[key] ?? [])
                    }
            }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    override func bindItemSelected() {
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let strongSelf = self else { return }
                
                if let selectedCell = strongSelf.tableView.cellForRow(at: indexPath) as? TransferHistoryItemCell, let selectedItem = selectedCell.item {
//                    strongSelf.completionTabBarHide!(true)
                    strongSelf.showIndetermineHudWithMessage("loading".localized().uppercaseFirst)
                    
                    // .history type
                    var recipient: Recipient
                    var amount: CGFloat = 0.0
                    
                    switch selectedItem.meta.actionType {
                    case "convert":
                        recipient = Recipient(id: selectedItem.point.symbol ?? Config.defaultSymbol,
                                              name: selectedItem.point.name ?? Config.defaultSymbol,
                                              avatarURL: selectedItem.point.logo)
                        
                        amount = CGFloat((selectedItem.meta.exchangeAmount ?? 0.0) * (selectedItem.meta.actionType == "transfer" ? -1 : 1))
                        
                    default:
                        recipient = Recipient(id: selectedItem.receiver.userId,
                                              name: selectedItem.receiver.username ?? Config.defaultSymbol,
                                              avatarURL: selectedItem.receiver.avatarUrl)
                        
                        amount = CGFloat(selectedItem.quantityValue * (selectedItem.meta.actionType == "transfer" ? -1 : 1))
                    }
                    
                    let transaction = Transaction(recipient: recipient,
                                                  accuracy: 4,
                                                  symbol: selectedItem.symbol,
                                                  history: selectedItem,
                                                  amount: amount,
                                                  operationDate: selectedItem.timestamp.convert(toDateFormat: .nextSmsDateType))
                    
                    let completedVC = TransactionCompletedVC(transaction: transaction)
                    completedVC.modalPresentationStyle = .overCurrentContext
                    completedVC.modalTransitionStyle = .crossDissolve
                    
                    strongSelf.present(completedVC, animated: true, completion: nil)
                    strongSelf.hideHud()
                    
//                    completedVC.completionDismiss = {
//                        strongSelf.completionTabBarHide!(false)
//                    }
                    
                    completedVC.completionRepeat = { [weak self] in
                        guard let strongSelf = self else { return }
                        
                        let walletSendPointsVC = WalletSendPointsVC(withSelectedBalance: transaction.symbol, andRecipient: transaction.recipient)
                        walletSendPointsVC.dataModel.transaction = transaction
                        
                        if let communWalletVC = strongSelf.navigationController?.viewControllers.filter({ $0 is CommunWalletVC }).first as? CommunWalletVC {
                            strongSelf.navigationController?.popToViewController(communWalletVC, animated: false)
//                            strongSelf.completionTabBarHide!(true)

                            switch selectedItem.meta.actionType {
                            case "transfer":
                                communWalletVC.show(walletSendPointsVC, sender: nil)

                            case "convert":
                                if let walletConvertVC = communWalletVC.createConvertVC(withHistoryItem: transaction.history) {
                                    communWalletVC.routeToConvertScene(walletConvertVC: walletConvertVC)
                                }
                                
                            default:
                                break
                            }

                            strongSelf.hideHud()
                         }
                    }
                }
            })
            .disposed(by: disposeBag)
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
        headerView.backgroundColor = .white
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
