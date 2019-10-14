//
//  UILabel.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import PureLayout

extension UILabel {
    static func title(_ text: String?) -> UILabel {
        let label = UILabel(forAutoLayout: ())
        label.text = text
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        return label
    }
    
    static func descriptionLabel(_ text: String?) -> UILabel {
        let label = UILabel(forAutoLayout: ())
        label.text = text
        label.font = .systemFont(ofSize: 10, weight: .semibold)
        label.textColor = UIColor(hexString: "#A5A7BD")
        return label
    }
    
    static func with(text: String? = nil, textSize: CGFloat, weight: UIFont.Weight = .regular, textColor: UIColor = .black, numberOfLines: Int? = nil) -> UILabel {
        let label = UILabel(forAutoLayout: ())
        label.text = text
        label.font = .systemFont(ofSize: textSize, weight: weight)
        label.textColor = textColor
        if let numberOfLines = numberOfLines {
            label.numberOfLines = numberOfLines
        }
        return label
    }
}
