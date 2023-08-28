//
//  CachedUser+CoreDataProperties.swift
//  Friendface
//
//  Created by Prakhar Trivedi on 28/8/23.
//
//

import Foundation
import CoreData


extension CachedUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedUser> {
        return NSFetchRequest<CachedUser>(entityName: "CachedUser")
    }

    @NSManaged public var id: String?
    @NSManaged public var isActive: Bool
    @NSManaged public var name: String?
    @NSManaged public var age: Int16
    @NSManaged public var company: String?
    @NSManaged public var email: String?
    @NSManaged public var address: String?
    @NSManaged public var about: String?
    @NSManaged public var registered: Date?
    @NSManaged public var tags: String?
    @NSManaged public var friends: NSSet?
    
    public var wrappedID: String {
        id ?? "Unknown ID"
    }
    
    public var wrappedName: String {
        name ?? "Unknown Name"
    }
    
    public var wrappedCompany: String {
        company ?? "Unknown Company"
    }
    
    public var wrappedEmail: String {
        email ?? "Unknown Email"
    }
    
    public var wrappedAddress: String {
        address ?? "Unknown Address"
    }
    
    public var wrappedAbout: String {
        about ?? "Unknown About"
    }
    
    public var wrappedRegistered: Date {
        registered ?? Date.now
    }
    
    public var wrappedTags: String {
        tags ?? "Unknown Tags"
    }
    
    public var wrappedFriends: [CachedFriend] {
        let set = friends as? Set<CachedFriend> ?? []
        
        return set.sorted { $0.wrappedName < $1.wrappedName }
    }
    
    func generateStandardUserObject() -> User {
        let safeFriends: [Friend] = wrappedFriends.map { $0.generateStandardFriendObject() }
        
        return User(
            id: wrappedID,
            isActive: isActive,
            name: wrappedName,
            age: Int(age),
            company: wrappedCompany,
            email: wrappedEmail,
            address: wrappedAddress,
            about: wrappedAbout,
            registered: wrappedRegistered,
            tags: wrappedTags.components(separatedBy: ","),
            friends: safeFriends
        )
    }
}

// MARK: Generated accessors for friends
extension CachedUser {

    @objc(addFriendsObject:)
    @NSManaged public func addToFriends(_ value: CachedFriend)

    @objc(removeFriendsObject:)
    @NSManaged public func removeFromFriends(_ value: CachedFriend)

    @objc(addFriends:)
    @NSManaged public func addToFriends(_ values: NSSet)

    @objc(removeFriends:)
    @NSManaged public func removeFromFriends(_ values: NSSet)

}

extension CachedUser : Identifiable {

}
