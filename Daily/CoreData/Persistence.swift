//
//  Persistence.swift
//  Daily
//
//  Created by kasoly on 2022/3/22.
//
import SwiftUI
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        Topic.insert(in: viewContext)?.update(of: ["id":1,"name":"car","icon":"car"])
        return result
    }()

    @AppStorage("icloud_sync") var icloudSync = false
    let container: NSPersistentCloudKitContainer


    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "App")
      
        let storeDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let localUrl = storeDirectory.appendingPathComponent("local.sqlite")
        let local = NSPersistentStoreDescription(url: localUrl)
        local.configuration = "Local"

        let cloudUrl = storeDirectory.appendingPathComponent("cloud.sqlite")
        let cloud = NSPersistentStoreDescription(url: cloudUrl)
        cloud.configuration = "Cloud"
        if icloudSync {
           cloud.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.daliy.zkep.com")
        } else {
           cloud.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
           cloud.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        }
        
        container.persistentStoreDescriptions = [cloud,local]
        
        guard container.persistentStoreDescriptions.first != nil else {
           fatalError("###\(#function): Failed to retrieve a persistent store description.")
        }
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        do {
            try container.viewContext.setQueryGenerationFrom(.current)
        } catch {
             fatalError("Failed to pin viewContext to the current generation:\(error)")
        }
    }
    
}
