//
//  CMActionSheet.swift
//  Commun
//
//  Created by Chung Tran on 8/12/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class CMActionSheet: SwipeDownDismissViewController {
    // MARK: - Nested type
    struct Action {
        var view: UIView
        var handle: (() -> Void)?
        var bottomMargin: CGFloat? = 0
        
        static func `default`(title: String, iconName: String, tintColor: UIColor = .appBlackColor, handle: (() -> Void)?, bottomMargin: CGFloat? = 10) -> Action {
            customLayout(height: 50, title: title, textSize: 15, textColor: tintColor, spacing: 10, iconName: iconName, iconSize: 24, iconTintColor: tintColor, showIconFirst: false, showNextButton: false, bottomMargin: bottomMargin, handle: handle)
        }
        
        static func iconFirst(title: String, iconName: String, handle: (() -> Void)?, bottomMargin: CGFloat? = nil, showNextButton: Bool = false) -> Action {
            customLayout(height: 65, title: title, textSize: 17, spacing: 10, iconName: iconName, iconSize: 35, showIconFirst: true, showNextButton: showNextButton, bottomMargin: bottomMargin, handle: handle)
        }
        
        static func customLayout(height: CGFloat = 50, padding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16), title: String, textSize: CGFloat = 15, textColor: UIColor = .appBlackColor, spacing: CGFloat = 10, showIcon: Bool = true, iconName: String? = nil, iconSize: CGFloat = 24, iconTintColor: UIColor? = nil, showIconFirst: Bool = false, showNextButton: Bool = false, bottomMargin: CGFloat? = nil, handle: (() -> Void)?) -> Action {
            let stackView = UIStackView(axis: .horizontal, spacing: spacing, alignment: .center, distribution: .fill)
            let label = UILabel.with(text: title, textSize: textSize, weight: .medium, textColor: textColor)
            let iconImageView = UIImageView(width: iconSize, height: iconSize, imageNamed: iconName)
            if let iconTintColor = iconTintColor {
                iconImageView.tintColor = iconTintColor
            }
            if !showIcon {stackView.addArrangedSubviews([label])}
            else if showIconFirst {stackView.addArrangedSubviews([iconImageView, label])}
            else {stackView.addArrangedSubviews([label, iconImageView])}
            
            if showNextButton {
                let nextButton = UIButton.circleGray(imageName: "cell-arrow", imageEdgeInsets: UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4))
                nextButton.isUserInteractionEnabled = false
                stackView.addArrangedSubview(nextButton)
            }
            
            let view = UIView(height: height, backgroundColor: .appWhiteColor)
            view.addSubview(stackView)
            stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
            return Action(view: view, handle: handle, bottomMargin: bottomMargin)
        }
    }
    
    class TapGesture: UITapGestureRecognizer {
        var action: Action?
    }
    
    // MARK: - Properties
    var backgroundColor: UIColor = .appLightGrayColor {
        didSet { view.backgroundColor = backgroundColor }
    }
    
    // MARK: - Subviews
    lazy var headerStackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
    lazy var closeButton: UIButton = {
        let button = UIButton.close(size: 30, backgroundColor: .appWhiteColor, tintColor: .appGrayColor)
        button.imageEdgeInsets = UIEdgeInsets(inset: 3)
        button.touchAreaEdgeInsets = UIEdgeInsets(inset: -7)
        button.addTarget(self, action: #selector(closeButtonDidTouch(_:)), for: .touchUpInside)
        return button
    }()
    var headerView: UIView {
        didSet { configureHeader() }
    }
    lazy var actionStackView = UIStackView(axis: .vertical, spacing: 0, alignment: .fill, distribution: .fill)
    var actions: [Action] {
        didSet { setUpActions() }
    }
    
    // MARK: - Initializer
    init(headerView: UIView?, title: String?, actions: [Action]) {
        self.actions = actions
        self.headerView = headerView ?? UILabel.with(text: title ?? "options".localized().uppercaseFirst, textSize: 15, weight: .bold, textAlignment: .center)
        super.init(nibName: nil, bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = .custom
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        
        view.backgroundColor = backgroundColor
        
        // set up header
        view.addSubview(headerStackView)
        headerStackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10), excludingEdge: .bottom)
        headerStackView.autoSetDimension(.height, toSize: 44)
        
        configureHeader()
        
        // set up action
        view.addSubview(actionStackView)
        actionStackView.autoPinEdge(.top, to: .bottom, of: headerStackView, withOffset: 10)
        actionStackView.autoPinEdge(toSuperviewEdge: .leading, withInset: 10)
        actionStackView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 10)
        actionStackView.autoPinBottomToSuperViewSafeAreaAvoidKeyboard(inset: 16)
        
        setUpActions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for (index, action) in actions.enumerated() {
            var roundingCorners = UIRectCorner()
            
            if index == 0 {
                roundingCorners.insert([.topLeft, .topRight])
            }
            
            if index == actions.count - 1 {
                roundingCorners.insert([.bottomLeft, .bottomRight])
            }
            
            if action.bottomMargin != nil {
                roundingCorners.insert([.bottomLeft, .bottomRight])
            }
            
            if let previousAction = actions[safe: index - 1], previousAction.bottomMargin != nil {
                roundingCorners.insert([.topLeft, .topRight])
            }
            
            action.view.roundCorners(roundingCorners, radius: 10)
        }
    }
    
    private func configureHeader() {
        headerStackView.removeArrangedSubviews()
        headerStackView.addArrangedSubviews([headerView, closeButton])
    }
    
    private func setUpActions() {
        actionStackView.removeArrangedSubviews()
        let views = actions.map {$0.view}
        actionStackView.addArrangedSubviews(views)
        
        for action in actions {
            actionStackView.setCustomSpacing(action.bottomMargin ?? 2, after: action.view)
        }
        
        actions.forEach { action in
            action.view.isUserInteractionEnabled = true
            let tapGesture = TapGesture(target: self, action: #selector(actionDidSelect(_:)))
            tapGesture.action = action
            action.view.addGestureRecognizer(tapGesture)
        }
    }
    
    // MARK: - Actions
    @objc func closeButtonDidTouch(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func actionDidSelect(_ gesture: TapGesture) {
        guard let action = gesture.action else {return}
        dismiss(animated: true) {
            action.handle?()
        }
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension CMActionSheet: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CMActionSheetPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor?.hasStarted == true ? interactor : nil
    }
}
