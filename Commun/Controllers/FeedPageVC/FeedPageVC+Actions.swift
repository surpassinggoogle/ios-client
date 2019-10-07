//
//  FeedPageVC+Actions.swift
//  Commun
//
//  Created by Chung Tran on 9/26/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension FeedPageVC {
    @IBAction func changeFeedTypeButtonDidTouch(_ sender: Any) {
        if viewModel.filter.value.feedTypeMode == .subscriptions {
            viewModel.changeFilter(feedTypeMode: .community)
        }
        
        else {
            viewModel.changeFilter(feedTypeMode: .subscriptions, feedType: .timeDesc)
        }
    }
    
    @IBAction func changeFilterButtonDidTouch(_ sender: Any) {
        // Create FiltersVC
        let vc = controllerContainer.resolve(FeedPageFiltersVC.self)!
        vc.filter.accept(viewModel.filter.value)
        vc.completion = { filter in
            self.viewModel.filter.accept(filter)
        }
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = vc
        
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func postButtonDidTouch(_ sender: Any) {
        openEditor()
    }
    
    @IBAction func photoButtonDidTouch(_ sender: Any) {
        openEditor { (editorVC) in
            editorVC.addImage()
        }
    }
    
    func openEditor(completion: ((BasicEditorVC)->Void)? = nil) {
        let editorVC = BasicEditorVC()
        editorVC.modalPresentationStyle = .fullScreen
        present(editorVC, animated: true, completion: {
            completion?(editorVC)
        })
    }
    
    @objc func didTapTryAgain(gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel,
            let text = label.text else {return}
        
        let tryAgainRange = (text as NSString).range(of: "try again".localized().uppercaseFirst)
        if gesture.didTapAttributedTextInLabel(label: label, inRange: tryAgainRange) {
            self.viewModel.fetchNext()
        }
    }
    
    @objc func refresh() {
        viewModel.reload()
    }
}
