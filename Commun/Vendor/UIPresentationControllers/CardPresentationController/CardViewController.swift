//
//  CardViewController.swift
//  Commun
//
//  Created by Chung Tran on 12/13/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class CardViewController: BaseViewController {
    var contentView: UIView
    
    init(contentView: UIView, backgroundColor: UIColor = .appWhiteColor) {
        self.contentView = contentView
        super.init(nibName: nil, bundle: nil)
        
        transitioningDelegate = self
        modalPresentationStyle = .custom
        view.backgroundColor = backgroundColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUp() {
        super.setUp()
       
        contentView.configureForAutoLayout()
        
        view.addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges()
    }
}

extension CardViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CardPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
