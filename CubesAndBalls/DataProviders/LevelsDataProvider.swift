//
//  LevelsDataProvider.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 01.05.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import UIKit
import CoreData

class LevelsDataProvider {
    static let shared = LevelsDataProvider()
    
    var appDelegate: AppDelegate
    var context: NSManagedObjectContext
    var currentUserLevel: Int16? {
        UserDefaults.standard.value(forKey: "currentLevel") as? Int16
    }
    
    private init() {
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
    }
    
    func setLevelsFromFile() throws {
        guard let levels = try? getAllLevels() else { throw DataProviderError.coreDataError }
        
        guard let path = Bundle.main.path(forResource: "DefaultLevels", ofType: "plist"),
            let dataArray = NSArray(contentsOfFile: path) else { return }
        
        guard dataArray.count != levels.count else { return }
        
        levels.forEach{ context.delete($0) }
        
        for dictionary in dataArray {
            guard let entity = NSEntityDescription.entity(forEntityName: "Level", in: context),
                let level = NSManagedObject(entity: entity, insertInto: context) as? Level,
                let levelsDict = dictionary as? NSDictionary,
                let ballsCount = levelsDict["ballsCount"] as? Int16,
                let cubesCount = levelsDict["cubesCount"] as? Int16, 
                let number = levelsDict["number"] as? Int16,
                let timeLimit = levelsDict["timeLimit"] as? Int16,
                let levelType = levelsDict["levelType"] as? Int16
                else {
                    print("Error while getting entity from DefaultLevels")
                    continue
            }
            
            level.ballsCount = ballsCount
            level.cubesCount = cubesCount
            level.number = number
            level.timeLimit = timeLimit
            level.levelType = levelType
        }
        
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func setDefaultCurrentLevel() {
        UserDefaults.standard.setValue(Int16(1), forKey: "currentLevel")
    }
    
    func getAllLevels() throws -> [Level] {
        let fetchRequest: NSFetchRequest<Level> = Level.fetchRequest()
        
        do {
            let items = try context.fetch(fetchRequest)
            return items
        } catch {
            print("CoreData failed: \(error)")
            throw DataProviderError.coreDataError
        }
    }
    
    func getLevel(withNumber number: Int16) throws -> Level {
        let fetchRequest: NSFetchRequest<Level> = Level.fetchRequest()

        fetchRequest.predicate = NSPredicate(format: "number == \(number)")
        
        do {
            if let result = try context.fetch(fetchRequest).first {
                return result
            }
        } catch {
            print("Fetch failed: \(error)")
        }
        throw DataProviderError.coreDataError
    }
    
    func getCurrentLevel() throws -> Level {
        guard let number = currentUserLevel else { return try getLevel(withNumber: 1) }
        
        if let level = try? getLevel(withNumber: number) {
            return level
        } else {
            return try getAllLevels().sorted(by: { $0.number < $1.number }).last!
        }
    }
    
    func levelUp() {
        guard let currentUserLevel = currentUserLevel,
            let levelsCount = try? context.count(for: Level.fetchRequest())
            else {
                setDefaultCurrentLevel()
                return
        }
        
        if currentUserLevel == levelsCount {
            return
        }
        
        UserDefaults.standard.setValue(currentUserLevel + 1, forKey: "currentLevel")
    }
}
