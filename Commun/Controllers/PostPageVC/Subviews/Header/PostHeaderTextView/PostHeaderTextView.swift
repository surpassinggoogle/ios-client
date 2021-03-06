//
//  PostHeaderTextView.swift
//  Commun
//
//  Created by Chung Tran on 10/16/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit

class PostHeaderTextView: MySubviewAttachingTextView {
    static let attachmentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    
    lazy var attachmentSize: CGSize = {
        let width = size.width
        return CGSize(width: width, height: 270)
    }()
   
    let defaultFont = UIFont.systemFont(ofSize: 17)
    
    var defaultAttributes: [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 8
        return [
            .font: defaultFont,
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor.appBlackColor
        ]
    }
    
    override func commonInit() {
        super.commonInit()
        
        textContainerInset = UIEdgeInsets(
            top: 10,
            left: PostHeaderTextView.attachmentInset.left,
            bottom: 10,
            right: PostHeaderTextView.attachmentInset.right)
        
        textContainer.lineFragmentPadding = 0
        isEditable = false
    }
}
