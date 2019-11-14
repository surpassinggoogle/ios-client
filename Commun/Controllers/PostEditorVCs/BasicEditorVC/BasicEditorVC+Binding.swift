//
//  BasicEditorVC+Binding.swift
//  Commun
//
//  Created by Chung Tran on 10/8/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension BasicEditorVC {
    override func bindContentTextView() {
        super.bindContentTextView()
        
        // Parse link inside text
        contentTextView.rx.text
            .subscribe(onNext: { (text) in
                // ignore if one or more attachment existed
                if self._viewModel.attachments.value.count > 0 ||
                    self.link != nil
                {return}
                
                // get link in text
                guard let text = text,
                    !text.isEmpty
                else {
                    self.ignoredLinks = []
                    return
                }
                
                // detect link
                let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
                let matches = detector.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))

                if matches.count < 1 {return}
                let match = matches[0]
                guard let range = Range(match.range, in: text) else { return }
                let url = self.contentTextView.text[range]
                
                // check ignored
                if self.ignoredLinks.contains(String(url)) {
                    return
                }
                else {
                    self.ignoredLinks.append(String(url))
                }
                
                self.link = String(url)
                
                // parseLink
                self.parseLink(self.link!)
            })
            .disposed(by: disposeBag)
    }
    
    func bindAttachments() {
        _viewModel.attachments.skip(1)
            .subscribe(onNext: {[unowned self] (attachments) in
                // remove bottom constraint
                if let bottomConstraint = self.contentView.constraints.first(where: {$0.firstAttribute == .bottom && ($0.firstItem as? BasicEditorTextView) == self.contentTextView})
                {
                    self.contentView.removeConstraint(bottomConstraint)
                }
                
                self.attachmentsView.removeFromSuperview()
                self.attachmentsView.removeAllConstraints()
                
                // if no attachment is attached
                if attachments.count == 0 {
                    self.layoutBottomContentTextView()
                    return
                }
                
                // construct attachmentsView
                self.attachmentsView = AttachmentsView(forAutoLayout: ())
                self.attachmentsView.didRemoveAttachmentAtIndex = {[weak self] index in
                    if self?._viewModel.attachments.value[index].attributes?.url == self?.link {
                        self?.link = nil
                    }
                    self?._viewModel.removeAttachment(at: index)
                }
                self.contentView.addSubview(self.attachmentsView)
                self.attachmentsView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), excludingEdge: .top)
                self.attachmentsView.autoPinEdge(.top, to: .bottom, of: self.contentTextViewCountLabel, withOffset: 16)
                
                var height = self.view.bounds.width / 377 * 200
                if attachments.count > 2  {
                    height = height + height / 2
                }
                self.attachmentsView.autoSetDimension(.height, toSize: height)
                
                self.attachmentsView.setUp(with: attachments)
            })
            .disposed(by: disposeBag)
    }
    
    override func bindCommunity() {
        super.bindCommunity()
        viewModel.community
            .filter {$0 != nil}
            .subscribe(onNext: { _ in
                self.contentTextView.becomeFirstResponder()
            })
            .disposed(by: disposeBag)
    }
}
