//
//  AppDelegate.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 27/06/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import RealmSwift
import GoogleMaps
import Alamofire
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // register for notifications
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil);
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        // Firebase configure
        FIRApp.configure()
        
        // register google maps
        GMSServices.provideAPIKey("AIzaSyBj0pr7Cxm3b4tsM9O1gyIXdguRHvMmeW0")
        
        var config = Realm.Configuration()
        config.schemaVersion = 20
        config.migrationBlock = { (migration: Migration, oldSchemaVersion: UInt64) in
        
            if oldSchemaVersion < 1 {
                
            }
        }
        
        Realm.Configuration.defaultConfiguration = config;
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        let realm = try! Realm()
        
//        Api.sharedInstance.userLogut().onSuccess(callback: { success in
//            
//            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kTargoUserLoggedOutSuccessfully, object: nil))
//            
//        }).onFailure(callback: { error in
//            
//            print("User logout error: \(error)")
//        })
        
//        let sessions = realm.objects(UserSession)
//
//        let users = realm.objects(User)
//        
//        realm.beginWrite()
//        realm.delete(sessions)
//        realm.delete(users)
//        
//        do {
//            
//            try realm.commitWrite()
//        }
//        catch {
//            
//            print("Caught an error when was trying to make commit to Realm")
//        }
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        if realm.objects(UserSession.self).first != nil {
            
            // User logged in
            // Open main controller
            
            loadHistoryOrders()
            
            self.window?.rootViewController = storyBoard.instantiateViewController(withIdentifier: "TTabBar")
            self.window?.makeKeyAndVisible()
        }
        else {
            
            let defaults = UserDefaults.standard
            if let _ = defaults.object(forKey: kTargoNeedIntro) as? Bool {
                
                // temporary solution
                let controller = storyBoard.instantiateViewController(withIdentifier: "RegistrationPhone")
                let navigation = UINavigationController(rootViewController: controller)
                
                self.window?.rootViewController = navigation
                self.window?.makeKeyAndVisible()
            }
            else {
                
//                let controller = TIntroContainerViewController.controllerInstance()
//                let navigation = UINavigationController(rootViewController: controller)
                
                self.window?.rootViewController = TIntroContainerViewController.controllerInstance()
                self.window?.makeKeyAndVisible()
                
                UIApplication.shared.statusBarStyle = .default
            }
            
//            if defaults.boolForKey(kTargoCodeSent) == true {
//                
//                let controller = storyBoard.instantiateViewControllerWithIdentifier("RegistrationCode")
//                let navigation = UINavigationController(rootViewController: controller)
//                
//                self.window?.rootViewController = navigation
//                self.window?.makeKeyAndVisible()
//            }
//            else {
//                
//                let controller = storyBoard.instantiateViewControllerWithIdentifier("RegistrationPhone")
//                let navigation = UINavigationController(rootViewController: controller)
//                
//                self.window?.rootViewController = navigation
//                self.window?.makeKeyAndVisible()
//            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.logoutAction), name: Notification.Name(rawValue: kTargoUserLoggedOutSuccessfully), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.loginAction), name: Notification.Name(rawValue: kTargoUserLoggedInSuccessfully), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.introEnded), name: Notification.Name(rawValue: kTargoIntroHasEndedNotification), object: nil)
        
        application.applicationIconBadgeNumber = 0
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        HTTPCookieStorage.shared.cookieAcceptPolicy = .always
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print("error: \(error)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let token =  deviceToken.map { String(format: "%02.2hhx", arguments: [$0]) }.joined()
        
        let defaults = UserDefaults.standard
        
        guard (defaults.object(forKey: kTargoDeviceToken) as? String) == nil else {
            
            return
        }
        
        defaults.set(token, forKey: kTargoDeviceToken)
        defaults.synchronize()
    }
    
    func introEnded() {
        
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: kTargoNeedIntro)
        defaults.synchronize()
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: "RegistrationPhone")
        let navigation = UINavigationController(rootViewController: controller)
        self.changeRootViewController(navigation)
    }
    
    func logoutAction() {
        
        let realm = try! Realm()
        
        try! realm.write({ 
            
            realm.deleteAll()
        })
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: "RegistrationPhone")
        let navigation = UINavigationController(rootViewController: controller)
        self.changeRootViewController(navigation)
    }
    
    func loadHistoryOrders() {
        
        let realm = try! Realm()
        
        if realm.objects(TOrderLoaderCookie.self).first == nil {
            
            TOrderLoader().loadOrders()
        }
    }
    
    func loginAction() {
        
        loadHistoryOrders()
        
//        let storage = HTTPCookieStorage.shared
//        
//        if let cookies = storage.cookies(for: URL(string: "targo.club")!) {
//            
//            for cookie in cookies {
//                
//                
//            }
//        }
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        let viewController = storyBoard.instantiateViewController(withIdentifier: "TTabBar")
        self.changeRootViewController(viewController)
    }
    
    func changeRootViewController(_ viewController: UIViewController) {
        
        UIView.transition(with: self.window!,
                                  duration: 0.5,
                                  options: .transitionCrossDissolve,
                                  animations: {
                                    
                                    let oldState = UIView.areAnimationsEnabled
                                    UIView.setAnimationsEnabled(false)
                                    self.window?.rootViewController = viewController
                                    UIView.setAnimationsEnabled(oldState)
                                    
            }, completion: nil)
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
//    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
//        
//        print(userInfo["id"])
//        print(userInfo["payment_status"])
//    }
//    
//    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
//        
//        print(userInfo)
//    }
//    
//    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
//        
//        
//    }
//    
//    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
//        
//        return true
//    }
}

