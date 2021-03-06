//
//  SelectLanguageVC.swift
//  Commun
//
//  Created by Chung Tran on 11/1/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxDataSources
import RxCocoa
import Localize_Swift

class SelectInterfaceLanguageVC: BaseViewController {
    // MARK: - Properties
    let supportedLanguages = Language.supported.filter {$0.isSupportedInterfaceLanguage == true}
    
    // MARK: - Subviews
    let closeButton = UIButton.close()
    var tableView = UITableView(forAutoLayout: ())
    lazy var languages = BehaviorRelay<[Language]>(value: supportedLanguages)
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        view.backgroundColor = .appLightGrayColor
        title = "language".localized().uppercaseFirst
        setRightNavBarButton(with: closeButton)
        closeButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        
        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewSafeArea(with: UIEdgeInsets(top: 20, left: 10, bottom: 0, right: 10))
        tableView.register(LanguageCell.self, forCellReuseIdentifier: "LanguageCell")
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .clear
        
        // get current language
        chooseCurrentLanguage()
    }
    
    private func chooseCurrentLanguage() {
        let langs: [Language] = languages.value.map { lang in
            var lang = lang
            lang.isCurrentInterfaceLanguage = lang.code == Localize.currentLanguage()
            return lang
        }
        languages.accept(langs)
    }
    
    override func bind() {
        super.bind()
        let dataSource = MyRxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, Language>>(
            configureCell: { _, _, indexPath, item in
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "LanguageCell", for: indexPath) as! LanguageCell
                cell.setUp(with: item)
                
                cell.roundedCorner = []
                
                if indexPath.row == 0 {
                    cell.roundedCorner.insert([.topLeft, .topRight])
                }
                
                if indexPath.row == self.languages.value.count - 1 {
                    cell.separator.isHidden = true
                    cell.roundedCorner.insert([.bottomLeft, .bottomRight])
                }
                return cell
            }
        )
        
        languages.map {[AnimatableSectionModel<String, Language>](arrayLiteral: AnimatableSectionModel<String, Language>(model: "", items: $0))}
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Language.self)
            .subscribe(onNext: { (language) in
                if language.isCurrentInterfaceLanguage == true {return}
                self.showActionSheet(
                    title: "would you like to change the application's language to".localized().uppercaseFirst + " " + (language.name + " language").localized().uppercaseFirst + "?",
                    actions: [
                        UIAlertAction(
                            title: "change to".localized().uppercaseFirst + " " + (language.name + " language").localized().uppercaseFirst,
                            style: .default,
                            handler: { _ in
                                Localize.setCurrentLanguage(language.code)
                                self.chooseCurrentLanguage()
                                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                appDelegate.window?.rootViewController = SplashVC()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    appDelegate.tabBarVC = TabBarVC()
                                    appDelegate.changeRootVC(appDelegate.tabBarVC)
                                }
                            }
                        )
                    ])
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                }
            })
            .disposed(by: disposeBag)
    }
}
