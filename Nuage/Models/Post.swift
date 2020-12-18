//
//  Post.swift
//  Nuage
//
//  Created by Laurin Brandner on 10.11.20.
//  Copyright © 2020 Laurin Brandner. All rights reserved.
//

import Foundation

struct Post: SoundCloudIdentifiable {
    
    enum Kind {
        case track(Track)
        case trackRepost(Track)
        case playlist(Playlist)
        case playlistRepost(Playlist)
    }
    
    var id: Int
    var date: Date
    var caption: String?
    
    var kind: Kind
    var user: User
    
}

struct UndefinedPostTypeError: Error {
    
    let type: String
    
}

extension Post: Decodable {

    enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case date = "created_at"
        case caption
        case type
        case track
        case playlist
        case user
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let uuid = try container.decode(String.self, forKey: .id)
        id = uuid.hashValue
        date = try container.decode(Date.self, forKey: .date)
        caption = try container.decodeIfPresent(String.self, forKey:.caption)
        
        user = try container.decode(User.self, forKey: .user)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "track":
            let track = try container.decode(Track.self, forKey: .track)
            kind = .track(track)
        case "track-repost":
            let track = try container.decode(Track.self, forKey: .track)
            kind = .trackRepost(track)
        case "playlist":
            let playlist = try container.decode(Playlist.self, forKey: .playlist)
            kind = .playlist(playlist)
        case "playlist-repost":
            let playlist = try container.decode(Playlist.self, forKey: .playlist)
            kind = .playlistRepost(playlist)
        default:
            throw UndefinedPostTypeError(type: type)
        }
    }
    
}