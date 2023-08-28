//
//  DataController.swift
//  Friendface
//
//  Created by Prakhar Trivedi on 28/8/23.
//

import Foundation
import CoreData

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "FriendfaceDataModel")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
            
            self.container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        }
    }
}

// Sample Implementation in SwiftUI Top-Level App File:
//struct MyApp: App {
//    @StateObject private var dataController = DataController()
//
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//                .environment(\.managedObjectContext, dataController.container.viewContext)
//        }
//    }
//}
