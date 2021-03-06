//
//  LocalAuthVC.swift
//  Commun
//
//  Created by Chung Tran on 7/29/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit
import THPinViewController
import CyberSwift
import RxSwift
import LocalAuthentication

class LocalAuthVC: THPinViewController {
    var canIgnore = false
    var remainingPinEntries = 3
    var completion: (() -> Void)?
    var reason: String?
    
    init() {
        super.init(delegate: nil)
        delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup views
        backgroundColor = .appWhiteColor
        promptColor = .appBlackColor
        view.tintColor = .appBlackColor
        promptTitle = "enter passcode".localized().uppercaseFirst
        
        // face id, touch id button
        if LABiometryType.isEnabled {
            let button = UIButton(frame: .zero)
            let biometryType = LABiometryType.current
            button.setImage(biometryType.icon, for: .normal)
            leftBottomButton = button
            leftBottomButton?.widthAnchor.constraint(equalToConstant: 50).isActive = true
            leftBottomButton?.widthAnchor.constraint(equalTo: leftBottomButton!.heightAnchor).isActive = true
            leftBottomButton?.addTarget(self, action: #selector(authWithBiometric), for: .touchUpInside)
            authWithBiometric(isAuto: true)
        }
        
        // Add cancel button on bottom
        if !canIgnore {
            navigationController?.setNavigationBarHidden(true, animated: false)
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "close".localized().uppercaseFirst, style: .plain, target: self, action: #selector(cancelButtonDidTouch))
        }
    }
    
    @objc func authWithBiometric(isAuto: Bool = false) {
        let myContext = LAContext()
        let myReason = reason?.localized() ?? "confirm it's you".localized().uppercaseFirst
        var authError: NSError?
        if myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            if let error = authError {
                print(error)
                return
            }
            myContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: myReason) { (success, _) in
                DispatchQueue.main.sync {
                    if success {
                        self.completion?()
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        } else {
            if !isAuto {
                showAlert(title: "warning".localized().uppercaseFirst, message: LABiometryType.current.stringValue + " " + "was turned off".localized() + "\n" + "do you want to turn it on?".localized().uppercaseFirst, buttonTitles: ["turn on".localized().uppercaseFirst, "cancel".localized().uppercaseFirst], highlightedButtonIndex: 0) { (index) in
                    
                    if index == 0 {
                        if let url = URL.init(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }
            }
        }
    }
    
    @objc func cancelButtonDidTouch() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

}

extension LocalAuthVC: THPinViewControllerDelegate {
    func pinLength(for pinViewController: THPinViewController) -> UInt {
        return 4
    }
    
    func pinViewController(_ pinViewController: THPinViewController, isPinValid pin: String) -> Bool {
        guard let correctPin = Config.currentUser?.passcode else {return false}
        if pin == correctPin {return true} else {
            remainingPinEntries -= 1
            return false
        }
    }
    
    func userCanRetry(in pinViewController: THPinViewController) -> Bool {
        return remainingPinEntries > 0
    }
    
    func pinViewControllerDidDismiss(afterPinEntryWasSuccessful pinViewController: THPinViewController) {
        completion?()
    }
    
    func pinViewControllerDidDismiss(afterPinEntryWasUnsuccessful pinViewController: THPinViewController) {
        
    }
}
