//
//  ViewModel.swift
//  Friendface
//
//  Created by Prakhar Trivedi on 28/8/23.
//

import Foundation
import CoreData

class AppState: ObservableObject {
    @Published var users: [User] = []
    
    func loadSampleUsers() {
        users = [
            User(id: "sample", isActive: true, name: "Alan Walker", age: 24, company: "Pegasystems Inc", email: "alan@pega.com", address: "155 Santa Clara Boulevar, New Jersey, US", about: "I am a professional DJ with some tracks written and published online.", registered: Date.now, tags: ["DJ", "lorem", "ipsum", "dolor", "sit", "amet"], friends: [
                    Friend(id: "sample1", name: "Bob")
                ]
            ),
            User(id: "sample1", isActive: false, name: "Bob Trahan", age: 17, company: "Night Media", email: "bob@night.com", address: "579134 Singapore", about: "Friend to Alan Walker", registered: Date.now, tags: ["dolor", "sit"], friends: [
                    Friend(id: "sample", name: "Alan Walker")
                ]
            )
        ]
    }
}
