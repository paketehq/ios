//
//  AppDelegate.swift
//  Pakete
//
//  Created by Royce Albert Dy on 12/03/2016.
//  Copyright © 2016 Pakete. All rights reserved.
//

import UIKit
import Keys
import Mixpanel
import Fabric
import Crashlytics
import TwitterKit
import Appirater
import Siren

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        let keys = PaketeKeys()
        // Smooch
        Smooch.initWithSettings(SKTSettings(appToken: keys.smoochAppTokenKey()))
        // Mixpanel
        Mixpanel.sharedInstanceWithToken(keys.mixpanelTokenKey(), launchOptions: launchOptions)
        // Crashlytics
        Fabric.with([Crashlytics.self, Twitter.self])
        // Appirater
        Appirater.setAppId("1112831205")
        Appirater.setDaysUntilPrompt(10)
        Appirater.setUsesUntilPrompt(10)
        Appirater.appLaunched(true)
        // Siren. we force users to update for now
        Siren.sharedInstance.alertType = .Force
        Siren.sharedInstance.checkVersion(.Daily)
        
        UINavigationBar.appearance().barStyle = .Black
        UINavigationBar.appearance().setBackgroundImage(UIImage(color: ColorPalette.Matisse), forBarMetrics: UIBarMetrics.Default)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        UINavigationBar.appearance().translucent = false
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: .Normal)
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.tintColor = .whiteColor()
        self.window?.rootViewController = UINavigationController(rootViewController: PackagesViewController())
        self.window?.makeKeyAndVisible()
        
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
        Siren.sharedInstance.checkVersion(.Immediately)
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        IAPHelper.verifyReceipt()
        Siren.sharedInstance.checkVersion(.Daily)
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

