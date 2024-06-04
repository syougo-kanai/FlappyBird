//
//  AppDelegate.swift
//  FlappyBird
//
//  Created by MTBS049 on 2024/05/31.
//

import UIKit
import AVFoundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func saveInitialNumbers() {
        // 初期の数値
        let items = [
            Item(score: 50, itemCount: 0),
            Item(score: 40, itemCount: 0),
            Item(score: 30, itemCount: 0),
            Item(score: 20, itemCount: 0),
            Item(score: 10, itemCount: 0)
        ]

        // UserDefaultsにデータが存在するかどうかを確認
           let userDefaults = UserDefaults.standard
           if let data = userDefaults.data(forKey: "items") {
               // デコードを試みる
               if let _ = try? JSONDecoder().decode([Item].self, from: data) {
                   // デコードが成功した場合、初期値はすでに保存されている
                   return
               }
           }

           // 初期値を保存
           print("初期値を保存します")
           let encoder = JSONEncoder()
           if let encoded = try? encoder.encode(items) {
               userDefaults.set(encoded, forKey: "items")
           }
       }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
               // 初期値を保存
               saveInitialNumbers()
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


}


