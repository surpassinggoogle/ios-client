//
//  UITableView.swift
//  Commun
//
//  Created by Chung Tran on 31/05/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import ASSpinnerView

// Tags for footerView
let loadingViewTag = 9999
let postLoadingFooterViewTag = 99991
let listErrorFooterViewTag = 99992

extension UITableView {
    func addLoadingFooterView() {
        // Prevent dupplicating
        if tableFooterView?.tag == loadingViewTag {
            return
        }
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: self.width, height: 60))
        containerView.tag = loadingViewTag
        let spinnerView = ASSpinnerView()
        spinnerView.spinnerLineWidth = 4
        spinnerView.spinnerDuration = 0.3
        spinnerView.spinnerStrokeColor = #colorLiteral(red: 0.4784313725, green: 0.6470588235, blue: 0.8980392157, alpha: 1)
        containerView.addSubview(spinnerView)
        
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        spinnerView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 0).isActive = true
        spinnerView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 0).isActive = true
        spinnerView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        spinnerView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        containerView.bringSubviewToFront(spinnerView)
        
        self.tableFooterView = containerView
    }
    
    func addPostLoadingFooterView() {
        // Prevent dupplicating
        if tableFooterView?.tag == postLoadingFooterViewTag {
            return
        }
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: self.width, height: 352))
        containerView.tag = postLoadingFooterViewTag
        let placeholderPostCell = PlaceholderPostCell(frame: CGRect(x: 0, y: 0, width: self.width, height: 352))
        containerView.addSubview(placeholderPostCell)

        placeholderPostCell.translatesAutoresizingMaskIntoConstraints = false
        placeholderPostCell.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 0).isActive = true
        placeholderPostCell.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 0).isActive = true
        placeholderPostCell.widthAnchor.constraint(equalTo: containerView.widthAnchor, constant: 0).isActive = true
        placeholderPostCell.heightAnchor.constraint(equalTo: containerView.heightAnchor, constant: 0).isActive = true

        self.tableFooterView = containerView
    }
    
    func addListErrorFooterView(with buttonHandler: Selector?) {
        // Prevent dupplicating
        if tableFooterView?.tag == listErrorFooterViewTag {
            return
        }
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: self.width, height: 44))
        containerView.tag = listErrorFooterViewTag
        let label = UILabel()
        label.numberOfLines = 0
        label.attributedText = NSMutableAttributedString().normal("Can not fetch next items".localized())
            .normal(". ")
            .bold("Try again".localized())
            .bold("?")
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        label.backgroundColor = .clear
        label.lineBreakMode = .byWordWrapping
        containerView.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 0).isActive = true
        label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 0).isActive = true
        label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16).isActive = true
        label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).isActive = true
        
        if let selector = buttonHandler {
            let tap = UITapGestureRecognizer(target: self, action: selector)
            label.isUserInteractionEnabled = true
            label.addGestureRecognizer(tap)
        }
        
        self.tableFooterView = containerView
    }
}
