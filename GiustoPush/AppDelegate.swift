//
//  AppDelegate.swift
//  GiustoPush
//
//  Created by Randall Mardus on 3/23/16.
//  Copyright © 2016 Randall Mardus. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        registerForPushNotifications(application)

        Fabric.with([Crashlytics.self])
        
        KCSClient.sharedClient().initializeKinveyServiceForAppKey(
            "kid_byIN6_PrbZ", //this is actually the app ID from Kinvey, not the app key, in case it is rejected
            withAppSecret: "8edda00ce47f472ab7ed4f6dae3ff432",
            usingOptions: nil
        )
        //the following line will contact the backend and verify that the library can communicate with GiustoPush; not necessary to keep while in production
        KCSPing.pingKinveyWithBlock { (result: KCSPingResult!) -> Void in
            if result.pingWasSuccessful {
                NSLog("Kinvey Ping Success")
            } else {
                NSLog("Kinvey Ping Failed")
            }
        }
        // Check if launched from notification
        // 1
        if let notification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? [String: AnyObject] {
            // 2
            let aps = notification["aps"] as! [String: AnyObject]
            createNewNewsItem(aps)
            // 3
            (window?.rootViewController as? UITabBarController)?.selectedIndex = 1
        }
        
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
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    //steps & code for push notifications came from https://www.raywenderlich.com/123862/push-notifications-tutorial?utm_source=raywenderlich.com+Weekly&utm_campaign=db2b4f7f1b-raywenderlich_com_Weekly3_08_2016&utm_medium=email&utm_term=0_83b6edc87f-db2b4f7f1b-415671397
    
    func registerForPushNotifications(application: UIApplication) {
        let viewAction = UIMutableUserNotificationAction()
        viewAction.identifier = "VIEW_IDENTIFIER"
        viewAction.title = "View"
        viewAction.activationMode = .Foreground
        
        let newsCategory = UIMutableUserNotificationCategory()
        newsCategory.identifier = "NEWS_CATEGORY"
        newsCategory.setActions([viewAction], forContext: .Default)
        
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: [newsCategory])
        
        application.registerUserNotificationSettings(notificationSettings)
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != .None {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for i in 0..<deviceToken.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        print("Device Token:", tokenString)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Failed to register:", error)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        let aps = userInfo["aps"] as! [String: AnyObject]
        
        // 1
        if (aps["content-available"] as? NSString)?.integerValue == 1 {
            // Refresh Podcast; change Podcast references to GPush ones; the Podcast is a reference to the original Wenderlich tutorial
            // 2
            let podcastStore = PodcastStore.sharedStore
            podcastStore.refreshItems { didLoadNewItems in
                // 3
                completionHandler(didLoadNewItems ? .NewData : .NoData)
            }
        } else  {
            // News
            // 4
            createNewNewsItem(aps)
            completionHandler(.NewData)
        }
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        // 1
        let aps = userInfo["aps"] as! [String: AnyObject]
        
        // 2
        if let newsItem = createNewNewsItem(aps) {
            (window?.rootViewController as? UITabBarController)?.selectedIndex = 1
            
            // 3
            if identifier == "VIEW_IDENTIFIER", let url = NSURL(string: newsItem.link) {
                let safari = SFSafariViewController(URL: url)
                window?.rootViewController?.presentViewController(safari, animated: true, completion: nil)
            }
        }
        
        // 4
        completionHandler()
    }


}

