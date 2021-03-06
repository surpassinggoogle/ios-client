//
//  NSAttributedString.swift
//  Commun
//
//  Created by Chung Tran on 15/04/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import CyberSwift

extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String, font: UIFont = UIFont.systemFont(ofSize: 15, weight: .bold), color: UIColor = .appBlackColor) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: font]
        let boldString = NSAttributedString(string: text, attributes: attrs).colored(with: color)
        append(boldString)
        return self
    }

    @discardableResult func semibold(_ text: String, font: UIFont = UIFont.systemFont(ofSize: 15, weight: .semibold), color: UIColor = .appBlackColor) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: font]
        let boldString = NSAttributedString(string: text, attributes: attrs).colored(with: color)
        append(boldString)
        return self
    }

    @discardableResult func normal(_ text: String, font: UIFont = UIFont.systemFont(ofSize: 15), color: UIColor = .appBlackColor) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: font,
                                                    .backgroundColor: UIColor.clear]
        let normal = NSAttributedString(string: text, attributes: attrs).colored(with: color)
        append(normal)
        return self
    }

    @discardableResult func text(_ text: String, size: CGFloat = 15, weight: UIFont.Weight = .regular, color: UIColor = .appBlackColor) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: size, weight: weight),
            .foregroundColor: color
        ]
        let normal = NSAttributedString(string: text, attributes: attrs)
        append(normal)
        return self
    }
    
    @discardableResult func link(_ url: String, placeholder: String? = nil, font: UIFont = .systemFont(ofSize: 15)) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [
            .link: url,
            .font: font
        ]
        let attrString = NSAttributedString(string: placeholder ?? url, attributes: attrs)
        append(attrString)
        return self
    }

    @discardableResult func withParagraphStyle(minimumLineHeight: CGFloat? = nil, alignment: NSTextAlignment? = nil, lineSpacing: CGFloat? = nil, paragraphSpacingBefore: CGFloat? = nil, paragraphSpacing: CGFloat? = nil) -> NSMutableAttributedString {

        let paragraphStyle = NSMutableParagraphStyle()
        if let minimumLineHeight = minimumLineHeight {
            paragraphStyle.minimumLineHeight = minimumLineHeight
        }
        if let alignment = alignment {
            paragraphStyle.alignment = alignment
        }
        if let lineSpacing = lineSpacing {
            paragraphStyle.lineSpacing = lineSpacing
        }
        if let paragraphSpacingBefore = paragraphSpacingBefore {
            paragraphStyle.paragraphSpacingBefore = paragraphSpacingBefore
        }
        if let paragraphSpacing = paragraphSpacing {
            paragraphStyle.paragraphSpacing = paragraphSpacing
        }
        let attrs: [NSAttributedString.Key: Any] = [.paragraphStyle: paragraphStyle]
        addAttributes(attrs, range: NSRange(location: 0, length: self.length))
        return self
    }

    @discardableResult func gray(_ text: String, font: UIFont = UIFont.systemFont(ofSize: 15)) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: font]
        let normal = NSAttributedString(string: text, attributes: attrs).colored(with: UIColor.gray)
        append(normal)
        return self
    }

    @discardableResult func underline(_ text: String, font: UIFont = UIFont.systemFont(ofSize: 15)) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: font, .underlineStyle: NSUnderlineStyle.single]
        let normal = NSAttributedString(string: text, attributes: attrs)
        append(normal)
        return self
    }

    /**
        Override current font with another font in entire attributedString
        - Parameters:
            - font: replacement font
            - keepSymbolicTraits: keep current symbolic traits or not
    */
    func overrideFont(replacementFont font: UIFont, keepSymbolicTraits: Bool = false) {
        enumerateAttributes(in: NSRange(location: 0, length: length), options: []) { (attributes, range, _) in
            guard let currentFont = attributes[.font] as? UIFont else {return}
            var font = font
            if keepSymbolicTraits {
                let symbolicTraits = currentFont.fontDescriptor.symbolicTraits
                font = UIFont(
                    descriptor: font.fontDescriptor.withSymbolicTraits(symbolicTraits)!,
                    size: font.fontDescriptor.pointSize)
            }
            addAttribute(.font, value: font, range: range)
        }
    }

    func resolveTags() {
        if let regex = try? NSRegularExpression(pattern: NSRegularExpression.tagRegexPattern, options: .caseInsensitive) {
            let matches = regex.matchedStrings(in: string)
            for match in matches {
                let range = nsRangeOfText(match)
                addAttribute(.link, value: URL.appURL + "/" + match, range: range)
            }
        }
    }

    func resolveMentions() {
        if let regex = try? NSRegularExpression(pattern: NSRegularExpression.mentionRegexPattern, options: .caseInsensitive) {
            let matches = regex.matchedStrings(in: string)
            for match in matches {
                let range = nsRangeOfText(match)
                addAttribute(.link, value: URL.appURL + "/" + match, range: range)
            }
        }
    }
}
