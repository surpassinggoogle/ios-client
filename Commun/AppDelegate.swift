//
//  AppDelegate.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 14/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//
//  https://console.firebase.google.com/project/golos-5b0d5/notification/compose?campaignId=9093831260433778480&dupe=true
//

import UIKit
import Fabric
import Crashlytics
import CoreData
import Firebase
import FirebaseMessaging
import UserNotifications
import CyberSwift
@_exported import CyberSwift
import Reachability
import RxReachability
import RxSwift

let isDebugMode: Bool = true
let smsCodeDebug: UInt64 = isDebugMode ? 9999 : 0
let gcmMessageIDKey = "gcm.message_id"
var isTouchIdAvailable = false
var isFaceIdAvailable = false

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    // MARK: - Properties
    var window: UIWindow?
    var reachability: Reachability?
    
    static var reloadSubject = PublishSubject<Bool>()
    let notificationCenter = UNUserNotificationCenter.current()

    
    // MARK: - Class Functions
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Logger
        Logger.showEvents = [.error]
        
        // Sync iCloud key-value store
        NSUbiquitousKeyValueStore.default.synchronize()
        
        #warning("Reset keychain for testing only. Remove in production")
        // reset keychain
        if !UserDefaults.standard.bool(forKey: UIApplication.versionBuild) {
            try? KeychainManager.deleteUser()
            UserDefaults.standard.set(true, forKey: UIApplication.versionBuild)
        }
        
        // Hide constraint warning
        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        // Network monitoring
        reachability = Reachability()
        try? reachability?.startNotifier()
        
        _ = reachability?.rx.isReachable
            .filter {$0}
            .subscribe(onNext: {_ in
                if WebSocketManager.instance.isConnected {return}
                WebSocketManager.instance.connect()
            })
        
        // Handle websocket connection
        WebSocketManager.instance.completionIsConnected = {
            AppDelegate.reloadSubject.onNext(false)
            self.window?.makeKeyAndVisible()
            application.applicationIconBadgeNumber = 0
        }
        
        // Reload app
        _ = AppDelegate.reloadSubject
            .subscribe(onNext: {force in
                self.navigateWithRegistrationStep(force: force)
            })
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        
        // Register for remote notifications
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            self.requestAuthorization()
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()

        Messaging.messaging().delegate = self
        
        Fabric.with([Crashlytics.self])
        
        return true
    }
    
    func navigateWithRegistrationStep(force: Bool = false) {
        
        let step = KeychainManager.currentUser()?.registrationStep ?? .firstStep
        // Registered user
        if step == .registered {
            // If first setting is uncompleted
            let settingStep = KeychainManager.currentUser()?.settingStep ?? .setPasscode
            if settingStep != .completed {
                if !force,
                    let nc = self.window?.rootViewController as? UINavigationController,
                    nc.viewControllers.first is BoardingVC {
                    return
                }
                
                let boardingVC = controllerContainer.resolve(BoardingVC.self)!
                let nc = UINavigationController(rootViewController: boardingVC)
                
                changeRootVC(nc)
                return
            }
            
            // if all set
            _ = RestAPIManager.instance.rx.authorize()
                .subscribe(onSuccess: { (response) in
                    // show feed
                    if (!force && (self.window?.rootViewController is TabBarVC)) {return}
                    self.changeRootVC(controllerContainer.resolve(TabBarVC.self)!)
                }, onError: { (error) in
                    print(error)
                })
            
        // New user
        } else {
            if !force,
                let nc = self.window?.rootViewController as? UINavigationController,
                nc.viewControllers.first is WelcomeVC {
                return
            }
            
            let welcomeVC = controllerContainer.resolve(WelcomeVC.self)
            let welcomeNav = UINavigationController(rootViewController: welcomeVC!)
            changeRootVC(welcomeNav)
            
            let navigationBarAppearace = UINavigationBar.appearance()
            navigationBarAppearace.tintColor = #colorLiteral(red: 0.4156862745, green: 0.5019607843, blue: 0.9607843137, alpha: 1)
        }
    }
    
    func changeRootVC(_ rootVC: UIViewController) {
        if let currentVC = window?.rootViewController as? SplashViewController {
            currentVC.animateSplash {
                self.window?.rootViewController = rootVC
            }
        } else {
            self.window?.rootViewController = rootVC
        }
        
        // Animation
        rootVC.view.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            rootVC.view.alpha = 1
        })
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pau ]]]]]]]]se the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//        NetworkService.shared.disconnect()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
//        NetworkService.shared.connect()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    

    // MARK: - Custom Functions
    private func requestAuthorization() {
        self.notificationCenter.delegate = self
        
        self.notificationCenter.requestAuthorization(options:               [.alert, .sound, .badge],
                                                     completionHandler:     { (granted, error) in
                                                        Logger.log(message: "Permission granted: \(granted)", event: .debug)
                                                        guard granted else { return }
                                                        self.getNotificationSettings()
        })
    }
    
    private func getNotificationSettings() {
        self.notificationCenter.getNotificationSettings(completionHandler:  { (settings) in
            Logger.log(message: "Notification settings: \(settings)", event: .debug)
        })
    }

    private func scheduleLocalNotification(userInfo: [AnyHashable : Any]) {
        let notificationContent                 =   UNMutableNotificationContent()
        let categoryIdentifier                  =   userInfo["category"] as? String ?? "Commun"
        
        notificationContent.title               =   userInfo["title"] as? String ?? "Commun"
        notificationContent.body                =   userInfo["body"] as? String ?? "Commun"
        notificationContent.sound               =   userInfo["sound"] as? UNNotificationSound ?? UNNotificationSound.default
        notificationContent.badge               =   userInfo["badge"] as? NSNumber ?? 1
        notificationContent.categoryIdentifier  =   categoryIdentifier
        
        let trigger         =   UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let identifier      =   "Commun Local Notification"
        let request         =   UNNotificationRequest(identifier: identifier, content: notificationContent, trigger: trigger)
        
        self.notificationCenter.add(request) { (error) in
            if let error = error {
                Logger.log(message: "Error \(error.localizedDescription)", event: .error)
            }
        }
        
        let snoozeAction    =   UNNotificationAction(identifier: "ActionSnooze", title: "Snooze".localized(), options: [])
        let deleteAction    =   UNNotificationAction(identifier: "ActionDelete", title: "Delete".localized(), options: [.destructive])
        
        let category        =   UNNotificationCategory(identifier:          categoryIdentifier,
                                                       actions:             [snoozeAction, deleteAction],
                                                       intentIdentifiers:   [],
                                                       options:             [])
        
        self.notificationCenter.setNotificationCategories([category])
    }
    
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Commun")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}


// MARK: - Firebase Cloud Messaging (FCM)
extension AppDelegate {
    func application(_ application:                             UIApplication,
                     didReceiveRemoteNotification userInfo:     [AnyHashable: Any]) {
        if let messageID = userInfo[gcmMessageIDKey] {
            Logger.log(message: "Message ID: \(messageID)", event: .severe)
        }
        
        // Print full message.
        Logger.log(message: "userInfo: \(userInfo)", event: .severe)
    }
    
    func application(_ application:                             UIApplication,
                     didReceiveRemoteNotification userInfo:     [AnyHashable: Any],
                     fetchCompletionHandler completionHandler:  @escaping (UIBackgroundFetchResult) -> Void) {
        if let messageID = userInfo[gcmMessageIDKey] {
            Logger.log(message: "Message ID: \(messageID)", event: .severe)
        }
        
        // Print full message.
        Logger.log(message: "userInfo: \(userInfo)", event: .severe)

        completionHandler(UIBackgroundFetchResult.newData)
    }
   
    func application(_ application:                                             UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error:    Error) {
        Logger.log(message: "Unable to register for remote notifications: \(error.localizedDescription)", event: .error)
    }
    
    func application(_ application:                                                 UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken:  Data) {
        Logger.log(message: "APNs token retrieved: \(deviceToken)", event: .severe)
        
        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }
}


// MARK: - UNUserNotificationCenterDelegate
@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    // Receive push-message when App is active/in background
    func userNotificationCenter(_ center:                                   UNUserNotificationCenter,
                                willPresent notification:                   UNNotification,
                                withCompletionHandler completionHandler:    @escaping (UNNotificationPresentationOptions) -> Void) {
        // Display Local Notification
        let notificationContent = notification.request.content
        
        // Print full message.
        Logger.log(message: "UINotificationContent: \(notificationContent)", event: .debug)

        completionHandler([.alert, .sound])
        
        UIApplication.shared.applicationIconBadgeNumber = Int(truncating: notificationContent.badge ?? 1)
    }
    
    // Tap on push message
    func userNotificationCenter(_ center:                                   UNUserNotificationCenter,
                                didReceive response:                        UNNotificationResponse,
                                withCompletionHandler completionHandler:    @escaping () -> Void) {
        let notificationContent = response.notification.request.content
        
        if response.notification.request.identifier == "Local Notification" {
            Logger.log(message: "Handling notifications with the Local Notification Identifier", event: .debug)
        }

        // Print full message.
        Logger.log(message: "UINotificationContent: \(notificationContent)", event: .debug)

        completionHandler()
    }
}


// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging:                             Messaging,
                   didReceiveRegistrationToken fcmToken:    String) {
        Logger.log(message: "FCM registration token: \(fcmToken)", event: .severe)
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)

        UserDefaults.standard.set(fcmToken, forKey: "fcmToken")

        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }

    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        Logger.log(message: "Received data message: \(remoteMessage.appData)", event: .severe)
    }
}
