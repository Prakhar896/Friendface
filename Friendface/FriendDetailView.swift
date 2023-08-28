//
//  FriendDetailView.swift
//  Friendface
//
//  Created by Prakhar Trivedi on 28/8/23.
//

import SwiftUI

struct UserDetailDisplayView: View {
    let parameter: String
    let value: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(parameter)
                    .font(.title3)
                    .bold()
                Text(value)
                    .padding(.top, 3)
                    .textSelection(.enabled)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

struct FriendDetailView: View {
    @ObservedObject var appState: AppState
    
    var givenUserID: String
    
    var user: User? {
        appState.users.first(where: { $0.id == givenUserID })
    }
    
    var specialMaxWidth: CGFloat {
        UIScreen.main.bounds.width * 0.9
    }
    
    var notFoundError: some View {
        VStack {
            Text("User not found.")
                .font(.title)
                .bold()
                .padding()
            Text("The user you tried to view details for could not be fetched. \nPlease try again.")
                .multilineTextAlignment(.center)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if let user = user {
                ScrollView {
                    Spacer()
                    
                    ZStack {
                        if user.isActive {
                            Color.green.opacity(0.8)
                                .frame(maxWidth: specialMaxWidth)
                                .cornerRadius(10)
                        }
                        
                        VStack(alignment: .center, spacing: 10) {
                            Text(user.name)
                                .font(.title)
                                .bold()
                            Text("\(user.company) ﹒ \(user.isActive ? "Active Now": "Not Active")")
                                .font(.subheadline)
                        }
                        .frame(maxWidth: specialMaxWidth)
                        .padding(.vertical, 20)
                        .shadow(radius: 10)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    VStack(alignment: .leading, spacing: 15) {
                        UserDetailDisplayView(parameter: "Email", value: user.email)
                        UserDetailDisplayView(parameter: "Address", value: user.address)
                        UserDetailDisplayView(parameter: "About", value: user.about)
                        UserDetailDisplayView(parameter: "Registration Date", value: user.registered.formatted())
                        
                        // Tags
                        Text("Tags")
                            .font(.title3)
                            .bold()
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(user.tags, id: \.self) { tag in
                                    HStack {
                                        Text(tag)
                                    }
                                    .padding(10)
                                    .background(.gray.opacity(0.4))
                                    .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Friends
                    }
                    .frame(maxWidth: specialMaxWidth)
                    .padding(.vertical, 20)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            } else {
                notFoundError
            }
        }
        .navigationTitle("Details")
    }
}

struct FriendDetailView_Previews: PreviewProvider {
    static var appState = AppState()
    
    static var previews: some View {
        NavigationView {
            FriendDetailView(appState: appState, givenUserID: "sample")
                .task {
                    await appState.fetch(true)
                }
        }
    }
}
