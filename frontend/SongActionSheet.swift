

//
//  SongActionSheet.swift
//  MusicMatch
//
//  Created by Jonathan Reuter on 29.01.25.
//

import SwiftUI

struct SongActionSheet: View {
    @EnvironmentObject var playlistManager: PlaylistManager
    var song: Song
    @Environment(\.presentationMode) var presentationMode

    // **Check, ob der Song bereits in den Lieblingssongs ist**
    private var isSongLiked: Bool {
        if let favorites = playlistManager.playlists.first(where: { $0.name == "Songs, die ich mag" }) {
            return favorites.songs.contains(where: { $0.title == song.title && $0.artist == song.artist })
        }
        return false
    }

    var body: some View {
        ZStack {
            // **Hintergrund auf Schwarz setzen**
            Color(red: 31/255, green: 31/255, blue: 31/255)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 10) {
                // **Song-Infos**
                HStack {
                    AsyncImage(url: URL(string: "https://via.placeholder.com/60")) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)

                    VStack(alignment: .leading) {
                        Text(song.title)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(song.artist)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)

                // **Trennlinie**
                Divider()
                    .background(Color.gray.opacity(0.6))

                // **Menüpunkte**
                VStack {
                    // **"Zu Lieblingssongs hinzufügen" nur anzeigen, wenn der Song noch nicht geliked wurde**
                    if !isSongLiked {
                        Button(action: {
                            playlistManager.addSongToLikedPlaylist(song: song)
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.white)
                                Text("Zu „Lieblingssongs“ hinzufügen")
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding()
                        }
                    }

                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "text.badge.plus")
                                .foregroundColor(.white)
                            Text("Zu Playlist hinzufügen")
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding()
                    }
                }
                .background(Color(red: 31/255, green: 31/255, blue: 31/255))
                .cornerRadius(12)

                Spacer()
            }
        }
        .presentationDetents([.medium, .large]) // **Menü startet auf halber Höhe, kann hochgezogen werden**
    }
}
