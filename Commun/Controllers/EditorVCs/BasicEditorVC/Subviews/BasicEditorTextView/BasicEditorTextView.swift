//
//  BasicEditorTextView.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift

class BasicEditorTextView: ContentTextView {
    override var defaultTypingAttributes: [NSAttributedString.Key : Any] {
        return [.font: UIFont.systemFont(ofSize: 17)]
    }
    
    override var draftKey: String { "BasicEditorTextView.draftKey" }
    
    override var acceptedPostType: String {
        return "basic"
    }
    
    override var canContainAttachments: Bool {
        return false
    }
    
    override func getContentBlock(postTitle: String? = nil) -> Single<ContentBlock> {
        // spend id = 1 for PostBlock, so id starts from 1
        var id: UInt = 1
        
        // child blocks of post block
        var contentBlocks = [Single<ContentBlock>]()
        
        // separate blocks by \n
        let components = attributedString.components(separatedBy: "\n")
        
        for component in components {
            if let block = component.toParagraphContentBlock(id: &id) {
                contentBlocks.append(.just(block))
            }
        }
        
        return Single.zip(contentBlocks)
            .map {contentBlocks -> ContentBlock in
                return ContentBlock(
                    id: 1,
                    type: "post",
                    attributes: ContentBlockAttributes(
                        title: postTitle,
                        type: self.acceptedPostType,
                        version: "1.0"
                    ),
                    content: .array(contentBlocks))
        }
    }
}
