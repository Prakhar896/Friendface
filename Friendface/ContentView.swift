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
                
                var allFriendsAndOrigins: [String: Friend] = [:]
                for fetchedUser in fetchedUsers {
                    for friend in fetchedUser.friends {
                        allFriendsAndOrigins[fetchedUser.id] = friend
                    }
                }
                
                for origin in allFriendsAndOrigins.keys {
                    let targetFriend = allFriendsAndOrigins[origin]!
                    let targetUser = (fetchedUsers.first { $0.id == origin })!
                    
                    let cacheFriend = CachedFriend(context: moc)
                    cacheFriend.id = targetFriend.id
                    cacheFriend.name = targetFriend.name
                    
                    cacheFriend.origin = CachedUser(context: moc)
                    cacheFriend.origin?.id = targetUser.id
                    cacheFriend.origin?.about = targetUser.about
                    cacheFriend.origin?.address = targetUser.address
                    cacheFriend.origin?.age = Int16(targetUser.age)
                    cacheFriend.origin?.company = targetUser.company
                    cacheFriend.origin?.email = targetUser.email
                    cacheFriend.origin?.isActive = targetUser.isActive
                    cacheFriend.origin?.name = targetUser.name
                    cacheFriend.origin?.registered = targetUser.registered
                    cacheFriend.origin?.tags = targetUser.tags.joined(separator: ",")
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
