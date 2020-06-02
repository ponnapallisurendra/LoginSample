//
//  AppDelegate.swift
//  TestExample
//
//  Created by Japp Tech on 02/01/20.
//  Copyright © 2020 Japp Tech. All rights reserved.
//

import UIKit
import GoogleSignIn
import MSAL


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

//com.googleusercontent.apps.507336139821-iqg36a83h17k4mfubtjjam9s35goobk6
//507336139821-iqg36a83h17k4mfubtjjam9s35goobk6.apps.googleusercontent.com
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        MSALGlobalConfig.loggerConfig.setLogCallback { (logLevel, message, containsPII) in
          
                   if let displayableMessage = message {
                       if (!containsPII) {
                           #if DEBUG
                           print(displayableMessage)
                           #endif
                       }
                   }
               }
         GIDSignIn.sharedInstance().clientID = "507336139821-iqg36a83h17k4mfubtjjam9s35goobk6.apps.googleusercontent.com"
        return true
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
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        GIDSignIn.sharedInstance().handle(url)
        MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String)
      return true
    }

}

