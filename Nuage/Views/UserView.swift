//
//  UserView.swift
//  Nuage
//
//  Created by Laurin Brandner on 03.01.21.
//

import SwiftUI
import Combine

struct UserView: View {
    
    @State private var user: User
    @State private var selection = 0
    @State private var subscriptions = Set<AnyCancellable>()
    
    var body: some View {
        VStack {
            HStack {
                RemoteImage(url: user.avatarURL, width: 50, height: 50, cornerRadius: 25)
                VStack(alignment: .leading) {
                    Text(user.username)
                        .bold()
                        .lineLimit(1)
                    Text(String(user.followerCount ?? 0))
                    if let description = user.description {
                        Text(description)
                    }
                }
            }
            Picker(selection: $selection, label: EmptyView()) {
                Text("Stream").tag(0)
                Text("Likes").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 400)

            stream(for: selection)
        }
        .onAppear {
            SoundCloud.shared.get(.user(with: user.id))
                .replaceError(with: user)
                .assign(to: \.user, on: self)
                .store(in: &subscriptions)
        }
    }
    
    @ViewBuilder private func stream(for selection: Int) -> some View {
        if selection == 1 {
            TrackList(for: SoundCloud.shared.get(.trackLikes(of: user)))
        }
        else {
            PostList(for: SoundCloud.shared.get(.stream(of: user)))
        }
    }
    
    init(user: User) {
        self._user = State(initialValue: user)
    }
    
}
