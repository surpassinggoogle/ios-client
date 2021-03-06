//
//  ContentTextView.swift
//  Commun
//
//  Created by Chung Tran on 9/23/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import CyberSwift

class ContentTextView: UITextView {
    // MARK: - Nested types
    enum CTVError: Error {
        case parsingError(message: String)
        var localizedDescription: String {
            switch self {
            case .parsingError(let message):
                return message
            }
        }
    }
    
    struct TextStyle: Equatable {
        var isBold = false
        var isItalic = false
        // if format is unpersisted alongside selection
        var isMixed = false
        var textColor: UIColor = .appBlackColor
        var urlString: String?
        
        static var `default`: TextStyle {
            return TextStyle(isBold: false, isItalic: false, isMixed: false, textColor: .appBlackColor, urlString: nil)
        }
        
        /// Return new TextStyle by modifying current TextStyle
        func setting(isBool: Bool? = nil, isItalic: Bool? = nil, isMixed: Bool? = nil, textColor: UIColor? = nil, urlString: String? = nil) -> TextStyle {
            let isBool = isBool ?? self.isBold
            let isItalic = isItalic ?? self.isItalic
            let isMixed = isMixed ?? self.isMixed
            let textColor = textColor ?? self.textColor
            let urlString = urlString ?? self.urlString
            return TextStyle(isBold: isBool, isItalic: isItalic, isMixed: isMixed, textColor: textColor, urlString: urlString)
        }
    }
    
    // MARK: - Properties
    var addLinkDidTouch: (() -> Void)?
    
    // Must override!!!
    var defaultTypingAttributes: [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 8
        return [.paragraphStyle: paragraphStyle]
    }
    
    var acceptedPostType: String {
        fatalError("Must override")
    }
    
    var draftKey: String {
        fatalError("Must override")
    }
    
    var canContainAttachments: Bool {
        fatalError("Must override")
    }
    
    var contextMenuItems: [UIMenuItem] {
        return [
            UIMenuItem(
                title: "𝐁",
                action: #selector(self.toggleBold)
            ),
            UIMenuItem(
                title: "𝐼",
                action: #selector(self.toggleItalic)
            ),
            UIMenuItem(
                title: "🔗".localized().uppercaseFirst,
                action: #selector(self.addLink)
            ),
            UIMenuItem(
                title: "color".localized().uppercaseFirst,
                action: #selector(self.setColorMenu)
            ),
            UIMenuItem(
                title: "clear formatting".localized().uppercaseFirst,
                action: #selector(self.clearFormatting)
            )
        ]
    }
    
    let disposeBag = DisposeBag()
    var originalAttributedString: NSAttributedString?
    
    var currentTextStyle = BehaviorRelay<TextStyle>(value: TextStyle(isBold: false, isItalic: false, isMixed: false, textColor: .appBlackColor, urlString: nil))
    
    // MARK: - Class Initialization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    func commonInit() {
        backgroundColor = .clear
        isScrollEnabled = false
        typingAttributes = defaultTypingAttributes
        textContainer.lineFragmentPadding = 0
        bind()
    }
    
    func bind() {
        rx.didChange
            .subscribe(onNext: {
                self.resolveMentions()
                self.resolveHashTags()
                self.resolveLinks()
                
                // reset
                if self.attributedText.length == 0 {
                    self.clearFormatting()
                }
            })
            .disposed(by: disposeBag)
        
        rx.didChangeSelection
            .subscribe(onNext: {
                // get TextStyle at current selectedRange
                self.setCurrentTextStyle()
                
                self.modifyContextMenu()
            })
            .disposed(by: disposeBag)
    }
    
    private func modifyContextMenu() {
        // menuItems
        UIMenuController.shared.menuItems = contextMenuItems
    }
    
    @objc private func addLink() {
        addLinkDidTouch?()
    }
    
    @objc private func setColorMenu() {
        let vc = ColorPickerViewController()
        vc.modalPresentationStyle = .popover
        
        /* 3 */
        if let popoverPresentationController = vc.popoverPresentationController {
            popoverPresentationController.permittedArrowDirections = .any
            popoverPresentationController.sourceView = self
            let selectionRange = selectedTextRange
            let selectionStartRect = caretRect(for: selectionRange!.start)
            let selectionEndRect = caretRect(for: selectionRange!.end)
            let selectionCenterPoint = CGPoint(x: (selectionStartRect.origin.x + selectionEndRect.origin.x) / 2, y: (selectionStartRect.origin.y + selectionStartRect.size.height / 2))
            popoverPresentationController.sourceRect = CGRect(x: selectionCenterPoint.x, y: selectionCenterPoint.y, width: 0, height: 0)
            popoverPresentationController.delegate = self
            parentViewController?.present(vc, animated: true, completion: nil)
            
            vc.didSelectColor = {color in
                self.setColor(color)
            }
        }
    }
    
    @objc func clearFormatting() {
        if selectedRange.length == 0 {
            typingAttributes = defaultTypingAttributes
            setCurrentTextStyle()
        } else {
            textStorage.enumerateAttributes(in: selectedRange, options: []) { (attrs, range, _) in
                if let link = attrs[.link] as? String {
                    if link.isLinkToTag || link.isLinkToMention {
                        return
                    }
                }
                textStorage.setAttributes(defaultTypingAttributes, range: range)
            }
            currentTextStyle.accept(.default)
        }
    }
    
    func shouldChangeCharacterInRange(_ range: NSRange, replacementText text: String) -> Bool {
        // Disable link effect after non-allowed-in-name character
        // Check if text is not a part of tag or mention
        let regex = "^" + String(NSRegularExpression.nameRegexPattern.dropLast()) + "$"
        
        if !text.matches(regex) {
            // if appended
            if range.length == 0 {
                // get range of last character
                let lastLocation = range.location - 1
                
                if lastLocation < 0 {
                    return true
                }
                
                // get last link attribute
                let attr = textStorage.attributes(at: lastLocation, effectiveRange: nil)
                
                if attr.has(key: .link) {
                    typingAttributes = defaultTypingAttributes
                }
            }
            // if inserted
        }
        
        // Remove link
        if text == "", range.length > 0, range.location > 0 {
            removeLink()
        }
        
        return true
    }
    
    func removeLink() {
        if selectedRange.length > 0 {
            textStorage.removeAttribute(.link, range: selectedRange)
        } else if selectedRange.length == 0 {
            let attr = typingAttributes
            if let link = attr[.link] as? String,
                link.isLink {
                textStorage.enumerateAttribute(.link, in: NSRange(location: 0, length: textStorage.length), options: []) { (currentLink, range, _) in
                    if currentLink as? String == link,
                        range.contains(selectedRange.location - 1) {
                        textStorage.removeAttribute(.link, range: range)
                    }
                }
            }
        }
    }
    
    func insertTextWithDefaultAttributes(_ text: String, at index: Int) {
        textStorage.insert(NSAttributedString(string: text, attributes: defaultTypingAttributes), at: index)
    }
    
    // MARK: - Draft
    /// For parsing attachments only, if attachments are not allowed, leave an empty Completable
    func parseAttachments() -> Completable {
        return .empty()
    }
    
    // MARK: - ContentBlock
    func getContentBlock() -> Single<ResponseAPIContentBlock> {
        fatalError("Must override")
    }
}

// MARK: - UIPopoverPresentationControllerDelegate
extension ContentTextView: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
