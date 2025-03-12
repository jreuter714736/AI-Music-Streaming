//
//  PlaylistView.swift
//  MusicMatch
//
//  Created by Jonathan Reuter on 20.01.25.
//

import SwiftUI

struct PlaylistDetailView: View {
    @Binding var playlist: Playlist
    @State private var newSongTitle: String = ""
    @State private var newSongArtist: String = ""
    @State private var showingAddSongAlert = false
    @StateObject private var spotifyViewModel = SpotifyViewModel()
    @State private var coverImage: UIImage? = nil
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // **Playlist-Cover & Name**
                ZStack(alignment: .bottomLeading) {
                    if let coverImage = coverImage {
                        Image(uiImage: coverImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 300)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.3)]), startPoint: .top, endPoint: .bottom))
                            .frame(height: 300)
                    }
                    
                    VStack(alignment: .leading) {
                        Spacer()
                        Text(playlist.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                .frame(height: 300)
                .onAppear {
                    let testPlaylistURI = "spotify:playlist:37i9dQZF1DXcBWIGoYBM5M" // Beispiel-ID
                    spotifyViewModel.fetchPlaylistImage(playlistURI: testPlaylistURI) { imageURL in
                        print("🎵 Geladene Test-Bild-URL: \(imageURL ?? "Keine URL gefunden")")
                        if let imageURL = imageURL, let url = URL(string: imageURL) {
                            DispatchQueue.global().async {
                                if let data = try? Data(contentsOf: url), let uiImage = UIImage(data: data) {
                                    DispatchQueue.main.async {
                                        self.coverImage = uiImage
                                    }
                                }
                            }
                        }
                    }
                }

                
                // **Liste der Songs**
                VStack(spacing: 15) {
                    ForEach(playlist.songs) { song in
                        HStack {
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
                    }
                }
                .padding(.top, 10)
            }
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.2)]), startPoint: .top, endPoint: .bottom)
                        .edgesIgnoringSafeArea(.all))
    }
}
