//
//  PlaylistView.swift
//  MusicMatch
//
//  Created by Jonathan Reuter on 20.01.25.
//

import SwiftUI

struct PlaylistView: View {
    @EnvironmentObject var playlistManager: PlaylistManager
    @State private var newPlaylistName: String = ""
    @State private var showingAddPlaylistAlert = false

    var body: some View {
        NavigationView {
            VStack {
                // **Überschrift "Mediathek"**
                HStack {
                    Text("Mediathek")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)

                // **Tabs für Playlists, Titel, Alben, Künstler**
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        TabButton(title: "Playlists")
                        TabButton(title: "Titel")
                        TabButton(title: "Alben")
                        TabButton(title: "Künstler")
                    }
                    .padding(.horizontal)
                }

                // **Liste der Playlists**
                // **Liste der Playlists**
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach($playlistManager.playlists) { $playlist in
                            NavigationLink(destination: PlaylistDetailView(playlist: $playlist)) {
                                PlaylistRow(playlist: playlist)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // **Neuer Playlist-Button**
                Button(action: {
                    showingAddPlaylistAlert = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Neu")
                    }
                    .font(.headline)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                }
                .padding()
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .alert("Neue Playlist erstellen", isPresented: $showingAddPlaylistAlert, actions: {
                TextField("Playlist-Name", text: $newPlaylistName)
                Button("Erstellen") {
                    if !newPlaylistName.isEmpty {
                        let newPlaylist = Playlist(name: newPlaylistName, songs: [])
                        playlistManager.playlists.append(newPlaylist)
                        newPlaylistName = ""
                    }
                }
                Button("Abbrechen", role: .cancel, action: {})
            }, message: {
                Text("Gib einen Namen für die Playlist ein.")
            })
        }
    }
}

// **Tab-Button für Kategorien (Playlists, Titel, etc.)**
struct TabButton: View {
    var title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
    }
}

// **Playlist-Element in der Liste**
struct PlaylistRow: View {
    var playlist: Playlist
    
    var body: some View {
        HStack {
            // **Platzhalter für Cover**
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "music.note.list")
                    .foregroundColor(.white.opacity(0.8))
            }

            // **Titel & Anzahl der Songs**
            VStack(alignment: .leading) {
                Text(playlist.name)
                    .font(.headline)
                    .foregroundColor(.white)
                Text("\(playlist.songs.count) Titel")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding(.vertical, 8)
    }
}

