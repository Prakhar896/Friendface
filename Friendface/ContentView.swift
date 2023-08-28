//
//  ContentView.swift
//  Friendface
//
//  Created by Prakhar Trivedi on 28/8/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var appState: AppState = AppState()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(appState.users, id: \.id) { user in
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
            .navigationTitle("Friendface")
            .task {
                await appState.fetch()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
