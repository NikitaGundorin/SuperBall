//
//  AppDelegate.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 21.04.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        checkCurrentLevel()
        checkLevelsExist()
        
        return true
    }
    
    private func checkCurrentLevel() {
        guard let _ = LevelsDataProvider.shared.currentUserLevel else {
            LevelsDataProvider.shared.setDefaultCurrentLevel()
            return
        }
    }
    
    private func checkLevelsExist() {
        do {
            try LevelsDataProvider.shared.setLevelsFromFile()
        }
        catch {
            print(error.localizedDescription)
        }
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CubesAndBalls")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print(error.localizedDescription)
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
                let nserror = error as NSError
                print(nserror.localizedDescription)
            }
        }
    }
}
