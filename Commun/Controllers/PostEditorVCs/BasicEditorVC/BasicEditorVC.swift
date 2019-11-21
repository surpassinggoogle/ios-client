//
//  BasicEditorVC.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import PureLayout
import RxCocoa
import RxSwift

class BasicEditorVC: PostEditorVC {
    // MARK: - Constants
    let attachmentHeight: CGFloat = 300
    let attachmentDraftKey = "BasicEditorVC.attachmentDraftKey"
    
    // MARK: - Properties
    var link: String? {
        didSet {
            if link == nil {
                if let indexOfAddArticle = tools.value.firstIndex(of: .addArticle)
                {
                    insertTool(.addPhoto, at: indexOfAddArticle)
                }
                else {
                    appendTool(.addPhoto)
                }

            }
            else {
                removeTool(.addPhoto)
            }
        }
    }
    
    var ignoredLinks = [String]()
    
    // MARK: - Subviews
    var _contentTextView = BasicEditorTextView(forExpandable: ())
    override var contentTextView: ContentTextView {
        return _contentTextView
    }
    var attachmentsView = AttachmentsView(forAutoLayout: ())
    
    // MARK: - Override
    override var contentCombined: Observable<Void> {
        Observable.merge(
            super.contentCombined,
            contentTextView.rx.text.orEmpty.map {_ in ()}
        )
    }
    
    override var isContentValid: Bool {
        let content = contentTextView.text ?? ""
        
        // both title and content are not empty
        let contentAreNotEmpty = !content.isEmpty
        
        // content inside limit
        let contentInsideLimit = (content.count <= contentLettersLimit)
        
        // compare content
        let contentChanged = (self.contentTextView.attributedText != self.contentTextView.originalAttributedString)
        
        // reassign result
        return super.isContentValid && contentAreNotEmpty && contentInsideLimit && contentChanged
    }
    
    override var postTitle: String? {
        return nil
    }
    
    var _viewModel = BasicEditorViewModel()
    override var viewModel: PostEditorViewModel {
        return _viewModel
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setUp() {
        super.setUp()
        #warning("add Article later")
//        if viewModel.postForEdit == nil {
//            appendTool(EditorToolbarItem.addArticle)
//        }
    }
    
    override func setUp(with post: ResponseAPIContentGetPost) {
        super.setUp(with: post)
        // download image && parse attachments
        var singles = [Single<TextAttachment>]()
        for attachment in post.attachments {
            // get image url or thumbnail (for website or video)
            var imageURL = attachment.content.stringValue ?? attachment.attributes?.url
            if attachment.attributes?.type == "video" || attachment.attributes?.type == "website" {
                imageURL = attachment.attributes?.thumbnail_url
            }
            // return a downloadSingle
            if let urlString = imageURL,
                let url = URL(string: urlString) {
                let downloadImage = NetworkService.shared.downloadImage(url)
                    .catchErrorJustReturn(UIImage(named: "image-not-available")!)
                    .map {TextAttachment(attributes: attachment.attributes, localImage: $0, size: CGSize(width: self.view.size.width, height: self.attachmentHeight))}
                singles.append(downloadImage)
            }
                // return an error image if thumbnail not found
            else {
                singles.append(
                    Single<UIImage>.just(UIImage(named: "image-not-available")!)
                        .map{TextAttachment(attributes: attachment.attributes, localImage: $0, size: CGSize(width: self.view.size.width, height: self.attachmentHeight))}
                )
            }
        }
        
        guard singles.count > 0 else {return}

        showIndetermineHudWithMessage("parsing attachments".localized().uppercaseFirst)
        
        Single.zip(singles)
            .subscribe(onSuccess: { [weak self] (attachments) in
                self?._viewModel.attachments.accept(attachments)
                self?.hideHud()
            })
            .disposed(by: disposeBag)
    }
    
    override func bind() {
        super.bind()
        
        bindAttachments()
    }
    
    // MARK: - GetContentBlock
    override func getContentBlock() -> Single<ResponseAPIContentBlock> {
        // TODO: - Attachments
        var block: ResponseAPIContentBlock?
        var id: UInt64!
        return super.getContentBlock()
            .flatMap {contentBlock -> Single<[ResponseAPIContentBlock]> in
                block = contentBlock
                // transform attachments to contentBlock
                id = (contentBlock.maxId ?? 100) + 1
                var childId = id!
                
                return Single.zip(self._viewModel.attachments.value.compactMap { (attachment) -> Single<ResponseAPIContentBlock>? in
                    return attachment.toSingleContentBlock(id: &childId)
                })
            }
            .map {contentBlocks -> ResponseAPIContentBlock in
                guard var childs = block?.content.arrayValue,
                    contentBlocks.count > 0
                else {return block!}
                childs.append(ResponseAPIContentBlock(id: id, type: "attachments", attributes: nil, content: .array(contentBlocks)))
                block!.content = .array(childs)
                
                return block!
            }
    }
}
