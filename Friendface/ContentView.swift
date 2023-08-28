//
//  ContentView.swift
//  Friendface
//
//  Created by Prakhar Trivedi on 28/8/23.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.name)
    ]) var localUsers: FetchedResults<CachedUser>
    
    @StateObject var appState: AppState = AppState()
    
    @State private var showingFetchErrorAlert: Bool = false
    @State private var fetching = true
    
    var debugMode: Bool = false
    
    var body: some View {
        NavigationView {
            Group {
                if !fetching {
                    List {
                        ForEach(appState.users, id: \.id) { user in
                            NavigationLink {
                                FriendDetailView(appState: appState, givenUserID: user.id)
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: user.isActive ? "circle.fill": "circle")
                                        .foregroundColor(user.isActive ? .green: .gray)
                                    
                                    VStack(alignment: .leading) {
                                        Text(user.name)
                                            .font(.headline)
                                        Text(user.company)
                                            .font(.subheadline)
                                    }
                                }
                                .padding(3)
                            }
                        }
                    }
                    .refreshable {
                        await fetch(inDebug: debugMode, force: true)
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Friendface")
            .task {
                await fetch(inDebug: debugMode)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await fetch(inDebug: debugMode, force: true)
                        }
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                }
            }
            .alert("Could Not Fetch Latest Data", isPresented: $showingFetchErrorAlert) {
                Button("OK") {}
            } message: {
                Text("Failed to fetch the latest user data from the Internet. You may not be connected to the Internet or may have poor Internet connection. \n\nThe app will display a local backup of the last fetched users. Try fetching again by hitting the refresh button at the top-right.")
            }
        }
    }
    
    func fetch(inDebug debugMode: Bool, force: Bool = false) async {
        if debugMode {
            appState.loadSampleUsers()
            return
        } else if !(appState.users.isEmpty || force) {
            return
        }
        
        do {
            let (data, _) = try await URLSession(configuration: .ephemeral).data(from: URL(string: "https://www.hackingwithswift.com/samples/friendface.json")!)
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let fetchedUsers = try decoder.decode([User].self, from: data)
            
            print("FETCH REQUEST: Data fetch request complete.")
            
            await MainActor.run {
                appState.users = fetchedUsers.sorted { $0.name < $1.name }
                print("FETCH REQUEST: Fetched data has replaced in-memory data.")
                
                var usersAndFriendsMapped: [String: [Friend]] = [:]
                for fetchedUser in fetchedUsers {
                    usersAndFriendsMapped[fetchedUser.id] = fetchedUser.friends
                }
                
                for userID in usersAndFriendsMapped.keys {
                    let targetUser = (fetchedUsers.first { $0.id == userID })!
                    
                    let cacheUser = CachedUser(context: moc)
                    cacheUser.id = userID
                    cacheUser.about = targetUser.about
                    cacheUser.address = targetUser.address
                    cacheUser.age = Int16(targetUser.age)
                    cacheUser.company = targetUser.company
                    cacheUser.email = targetUser.email
                    cacheUser.isActive = targetUser.isActive
                    cacheUser.name = targetUser.name
                    cacheUser.registered = targetUser.registered
                    cacheUser.tags = targetUser.tags.joined(separator: ",")
                    
                    for friend in usersAndFriendsMapped[userID]! {
                        let cacheFriend = CachedFriend(context: moc)
                        cacheFriend.id = friend.id
                        cacheFriend.name = friend.name
                        
                        cacheUser.addToFriends(cacheFriend)
                    }
                }
                
                try? moc.save()
                
                print("FETCH REQUEST: Fetched data has been backed up to persistent stores.")
            }
        } catch {
            print("FETCH REQUEST: Error occured in fetch: \(error.localizedDescription)")
            print("FETCH REQUEST: Will recover by adopting backup in persistent stores.")
            
            appState.users = localUsers.map { $0.generateStandardUserObject() }
            showingFetchErrorAlert = true
        }
        
        fetching = false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(debugMode: true)
    }
}
