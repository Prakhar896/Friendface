//
//  CachedFriend+CoreDataProperties.swift
//  Friendface
//
//  Created by Prakhar Trivedi on 28/8/23.
//
//

import Foundation
import CoreData


extension CachedFriend {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedFriend> {
        return NSFetchRequest<CachedFriend>(entityName: "CachedFriend")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var origin: CachedUser?

    public var wrappedID: String {
        id ?? "Unknown ID"
    }
    
    public var wrappedName: String {
        name ?? "Unknown Name"
    }
    
    func generateStandardFriendObject() -> Friend {
        return Friend(id: wrappedID, name: wrappedName)
    }
}

extension CachedFriend : Identifiable {

}
