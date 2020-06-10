//
//  AppDelegate.swift
//  AroundMe
//
//  Created by Javad Rahimipour Anaraki on 2020-05-20.
//  Copyright © 2020 Holland Bloorview Kids Rehabilitation Hospital. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var hasAlreadyLaunched :Bool!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //retrieve value from local store, if value doesn't exist then false is returned
        hasAlreadyLaunched = UserDefaults.standard.bool(forKey: "hasAlreadyLaunched")//check first launched
        if (hasAlreadyLaunched)
        {
            hasAlreadyLaunched = true
            
        } else {
            UserDefaults.standard.set(true, forKey: "hasAlreadyLaunched")
        }
        
        return true
    }
    
    func sethasAlreadyLaunched() {
        hasAlreadyLaunched = true
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

