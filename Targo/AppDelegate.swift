//
//  AppDelegate.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 27/06/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import RealmSwift
import Timberjack
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // register for notifications
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil);
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        // register google maps
        GMSServices.provideAPIKey("AIzaSyBj0pr7Cxm3b4tsM9O1gyIXdguRHvMmeW0")
        
        
        //Loggin
        Timberjack.register()
        
        var config = Realm.Configuration()
        config.schemaVersion = 16
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
        
        
        if realm.objects(UserSession).first != nil {
            
            // User logged in
            // Open main controller
            self.window?.rootViewController = storyBoard.instantiateViewControllerWithIdentifier("TTabBar")
            self.window?.makeKeyAndVisible()
        }
        else {
            
            let defaults = NSUserDefaults.standardUserDefaults()
            
            if defaults.boolForKey(kTargoCodeSent) == true {
                
                let controller = storyBoard.instantiateViewControllerWithIdentifier("RegistrationCode")
                let navigation = UINavigationController(rootViewController: controller)
                
                self.window?.rootViewController = navigation
                self.window?.makeKeyAndVisible()
            }
            else {
                
                let controller = storyBoard.instantiateViewControllerWithIdentifier("RegistrationPhone")
                let navigation = UINavigationController(rootViewController: controller)
                
                self.window?.rootViewController = navigation
                self.window?.makeKeyAndVisible()
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.logoutAction), name: kTargoUserLoggedOutSuccessfully, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.loginAction), name: kTargoUserLoggedInSuccessfully, object: nil)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        
        NSHTTPCookieStorage.sharedHTTPCookieStorage().cookieAcceptPolicy = .Always
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        
        print("error: \(error)")
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if (defaults.objectForKey(kTargoDeviceToken) as? String) != nil {
            
            return
        }
        
        defaults.setObject(deviceToken.description, forKey: kTargoDeviceToken)
        defaults.synchronize()
    }
    
    func logoutAction() {
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        let controller = storyBoard.instantiateViewControllerWithIdentifier("RegistrationPhone")
        let navigation = UINavigationController(rootViewController: controller)
        self.changeRootViewController(navigation)
    }
    
    func loginAction() {
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        let viewController = storyBoard.instantiateViewControllerWithIdentifier("TTabBar")
        self.changeRootViewController(viewController)
    }
    
    func changeRootViewController(viewController: UIViewController) {
        
        UIView.transitionWithView(self.window!,
                                  duration: 0.5,
                                  options: .TransitionCrossDissolve,
                                  animations: {
                                    
                                    self.window?.rootViewController = viewController
                                    
            }, completion: nil)
    }
}

