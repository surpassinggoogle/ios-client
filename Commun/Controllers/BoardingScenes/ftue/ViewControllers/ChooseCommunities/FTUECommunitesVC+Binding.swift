//
//  FTUECommunitesVC+Binding.swift
//  Commun
//
//  Created by Chung Tran on 11/26/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import ESPullToRefresh

extension FTUECommunitiesVC: UICollectionViewDelegateFlowLayout, CommunityCellDelegate {
    func bindControl() {
        let offsetY = communitiesCollectionView.rx
            .contentOffset
            .map {$0.y + self.communitiesCollectionView.contentInset.top}
            .share()
        
        offsetY
            .map { $0 > 30 }
            .distinctUntilChanged()
            .bind(to: headerView.rx.isHidden)
            .disposed(by: disposeBag)
        
        offsetY
            .map {$0 < -20}
            .distinctUntilChanged()
            .subscribe(onNext: { (show) in
                self.communitiesCollectionView.subviews.first(where: {$0 is ESRefreshHeaderView})?.alpha = show ? 1 : 0
            })
            .disposed(by: disposeBag)
    }
    
    func bindCommunities() {
        // state
        viewModel.state
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .loading(let isLoading):
                    if isLoading && self?.viewModel.items.value.count == 0 {
                        self?.view.showLoading()
                    }
                    else {
                        self?.view.hideLoading()
                    }
                case .listEnded:
                    self?.view.hideLoading()
                case .listEmpty:
                    self?.view.hideLoading()
                case .error(_):
                    self?.view.hideLoading()
                    if self?.viewModel.items.value.count == 0 {
                        self?.view.showErrorView {
                            self?.view.hideErrorView()
                            self?.viewModel.reload()
                        }
                    }
                }
                
            })
            .disposed(by: disposeBag)
        
        // items
        viewModel.items
            .skip(1)
            .bind(to: communitiesCollectionView.rx.items(cellIdentifier: "CommunityCollectionCell", cellType: FTUECommunityCell.self)) { index, model, cell in
                cell.setUp(with: model)
                cell.delegate = self
                cell.shouldShowBonus = (self.viewModel.chosenCommunities.value.count < 3)
                
                if index >= self.viewModel.items.value.count - 3 {
                    self.viewModel.fetchNext()
                }
            }
            .disposed(by: disposeBag)
        
        communitiesCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        // chosenCommunity
        viewModel.chosenCommunities
            .map {communities -> [ResponseAPIContentGetCommunity?] in
                var communities = communities as [ResponseAPIContentGetCommunity?]
                if communities.count < 3 {
                    var placeholders = [ResponseAPIContentGetCommunity?]()
                    for _ in 0..<(3-communities.count) {
                        placeholders.append(nil)
                    }
                    communities += placeholders
                }
                return Array(communities.prefix(3))
            }
            .bind(to: chosenCommunitiesCollectionView.rx.items(cellIdentifier: "FTUEChosenCommunityCell", cellType: FTUEChosenCommunityCell.self)) { index, model, cell in
                if let model = model {
                    cell.deleteButton.isHidden = false
                    cell.setUp(with: model)
                }
                else {
                    cell.avatarImageView.image = nil
                    cell.avatarImageView.percent = 0
                    cell.deleteButton.isHidden = true
                }
                cell.delegate = self
            }
            .disposed(by: disposeBag)
        
        viewModel.chosenCommunities
            .map {$0.count >= 3}
            .distinctUntilChanged()
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    func observeCommunityFollowed() {
        ResponseAPIContentGetCommunity.observeItemChanged()
            .filter {$0.isSubscribed == true}
            .distinctUntilChanged {$0.identity == $1.identity}
            .subscribe(onNext: { [weak self] (community) in
                guard var chosenCommunities = self?.viewModel.chosenCommunities.value else {return}
                chosenCommunities.joinUnique([community])
                self?.viewModel.chosenCommunities.accept(chosenCommunities)
            })
            .disposed(by: disposeBag)
        
        ResponseAPIContentGetCommunity.observeItemChanged()
            .filter {$0.isSubscribed == false}
            .distinctUntilChanged {$0.identity == $1.identity}
            .subscribe(onNext: { [weak self] (community) in
                guard var chosenCommunities = self?.viewModel.chosenCommunities.value else {return}
                chosenCommunities.removeAll(where: {$0.identity == community.identity})
                self?.viewModel.chosenCommunities.accept(chosenCommunities)
            })
            .disposed(by: disposeBag)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.width - collectionView.contentInset.left - collectionView.contentInset.right
        let horizontalSpacing: CGFloat = 16 * Config.heightRatio
        let itemWidth = (width - horizontalSpacing) / 2
        return CGSize(width: itemWidth, height: 190)
    }
}