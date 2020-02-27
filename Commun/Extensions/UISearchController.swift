//
//  UISearchController.swift
//  Commun
//
//  Created by Chung Tran on 1/29/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

extension UISearchController {
    static func `default`(
        placeholder: String = "search".localized().uppercaseFirst
    ) -> UISearchController {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchBar.searchBarStyle = .minimal
        sc.searchBar.tintColor = .appMainColor
        sc.setStyle(placeholder: placeholder)
        return sc
    }
    
    func setStyle(placeholder: String = "search".localized().uppercaseFirst) {
        let searchTextField: UITextField

        if #available(iOS 13, *) {
            searchTextField = searchBar.searchTextField
        } else {
            searchTextField = (searchBar.value(forKey: "searchField") as? UITextField) ?? UITextField()
        }

        // change bg color
        searchTextField.backgroundColor = .appLightGrayColor

        // remove top tinted black view
        let backgroundView = searchTextField.subviews.first
        backgroundView?.subviews.forEach({ $0.removeFromSuperview() })

        // change icon color
        if let iconView = searchTextField.leftView as? UIImageView {
            iconView.image = iconView.image?.withRenderingMode(.alwaysTemplate)
            iconView.tintColor = .appGrayColor
        }

        // change placeholder color (add new label)
        if let systemPlaceholderLabel = searchTextField.value(forKey: "placeholderLabel") as? UILabel {
            searchBar.placeholder = " "

            let placeholderLabel = UILabel(frame: .zero)

            placeholderLabel.text = placeholder
            placeholderLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .regular)
            placeholderLabel.textColor = .appGrayColor

            systemPlaceholderLabel.addSubview(placeholderLabel)

            // Layout label to be a "new" placeholder
            placeholderLabel.leadingAnchor.constraint(equalTo: systemPlaceholderLabel.leadingAnchor).isActive = true
            placeholderLabel.topAnchor.constraint(equalTo: systemPlaceholderLabel.topAnchor).isActive = true
            placeholderLabel.bottomAnchor.constraint(equalTo: systemPlaceholderLabel.bottomAnchor).isActive = true
            placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
            placeholderLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        } else {
            searchBar.placeholder = placeholder
        }

        hidesNavigationBarDuringPresentation = false
        obscuresBackgroundDuringPresentation = false
    }
    
    func roundCorner(cornerRadius: CGFloat? = nil) {
        searchBar.textField?.cornerRadius = cornerRadius ?? ((searchBar.textField?.height ?? 0) / 2)
    }
}
