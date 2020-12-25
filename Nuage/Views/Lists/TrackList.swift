//
//  TrackList.swift
//  Nuage
//
//  Created by Laurin Brandner on 23.12.19.
//  Copyright © 2019 Laurin Brandner. All rights reserved.
//

import SwiftUI
import Combine
import SDWebImageSwiftUI
import SoundCloud

struct TrackList<Element: Decodable&Identifiable&Filterable>: View {
    
    var publisher: InfinitePublisher<Element>
    private var transform: (Element) -> Track
    
    @EnvironmentObject private var player: StreamPlayer
    
    var body: some View {
        InfinteList(publisher: publisher) { elements, idx -> AnyView in
            let track = transform(elements[idx])
            
            let toggleLikeCurrentTrack = {
                toggleLike(track)
            }
            let repostCurrentTrack = {
//                onRepost(track)
            }
            let onPlay = {
                let tracks = elements.map(transform)
                play(tracks, from: idx, on: player)
            }

            return AnyView(VStack(alignment: .leading) {
                TrackRow(track: track, onLike: toggleLikeCurrentTrack, onReblog: repostCurrentTrack)
                Divider()
            }
            .onTapGesture(count: 2, perform: onPlay)
            .trackContextMenu(track: track, onPlay: onPlay))
        }
    }
    
}

extension TrackList where Element == Track {
    
    init(for publisher: AnyPublisher<Slice<Track>, Error>) {
        self.init(publisher: .slice(publisher)) { $0 }
    }
    
    init(for arrayPublisher: AnyPublisher<[Int], Error>,
         slice slicePublisher: @escaping ([Int]) -> AnyPublisher<[Track], Error>) {
        self.init(publisher: .array(arrayPublisher, slicePublisher), transform: { $0 })
    }
    
}

extension TrackList where Element == Like<Track> {
    
    init(for publisher: AnyPublisher<Slice<Like<Track>>, Error>) {
        self.init(publisher: .slice(publisher)) { $0.item }
    }
    
}

extension TrackList where Element == HistoryItem {
    
    init(for publisher: AnyPublisher<Slice<HistoryItem>, Error>) {
        self.init(publisher: .slice(publisher)) { $0.track }
    }
    
}

//struct TrackList_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackList(publisher: previewTrackPublisher.collect().eraseToAnyPublisher())
//    }
//}