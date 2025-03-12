//
//  SpotifySearchView.swift
//  MusicMatch
//
//  Created by Jonathan Reuter on 17.12.24.
//

import SwiftUI

struct SpotifySearchView: View {
    @EnvironmentObject var viewModel: SpotifyViewModel
    @EnvironmentObject var playlistManager: PlaylistManager

    @State private var searchText = ""
    @State private var searchResults: [(title: String, artist: String, imageURL: String, uri: String)] = []
    @FocusState private var isSearchFieldFocused: Bool
    @State private var isSearching: Bool = false // Zusätzlicher Status für aktive Suche
    @State private var currentlyPlayingURI: String? = nil // Aktuell gespielter Song
    @State private var showingPlaylistSelection = false
    @State private var selectedSong: Song?
    @State private var showingActionSheet = false

    

    private let genres: [(name: String, color: Color, imageName: String?)] = [
        ("Musik", Color(red: 18/255, green: 38/255, blue: 50/255), "music"),
        ("Für dich", Color(red: 25/255, green: 114/255, blue: 96/255), "foryyou"),
        ("Live", Color(red: 5/255, green: 76/255, blue: 62/255), "live"),
        ("Neu", Color(red: 109/255, green: 13/255, blue: 126/255), "newcomer"),
        ("Dance", Color(red: 218/255, green: 20/255, blue: 138/255), "techno"),
        ("Podcasts", Color(red: 163/255, green: 95/255, blue: 136/255), "podcast"),
        ("Rock", Color(red: 95/255, green: 129/255, blue: 8/255), "rock-cover"),
        ("Country", Color(red: 115/255, green: 101/255, blue: 40/255), "country-cover"),
        ("Reggae", Color(red: 86/255, green: 126/255, blue: 147/255), "reggae-cover"),
        ("Hip-Hop", Color(red: 218/255, green: 20/255, blue: 138/255), "hiphop-cover"),
        ("Pop", Color(red: 50/255, green: 68/255, blue: 176/255), "pop-cover"),
        ("RnB", Color(red: 35/255, green: 49/255, blue: 96/255), "RnB-cover"),
        ("Blues", Color(red: 136/255, green: 104/255, blue: 167/255), "blues"),
        ("Jazz", Color(red: 214/255, green: 51/255, blue: 52/255), "jazz"),
        ("Classical", Color(red: 163/255, green: 95/255, blue: 136/255), "classic")
    ]


    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // **Suchleiste**
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)

                    TextField("Was möchtest du hören?", text: $searchText)
                        .focused($isSearchFieldFocused)
                        .foregroundColor(isSearchFieldFocused || isSearching ? .white : .black)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .onChange(of: searchText) { newValue in
                            guard !newValue.isEmpty else {
                                searchResults = []
                                return
                            }

                            viewModel.searchSpotify(for: newValue) { results in
                                DispatchQueue.main.async {
                                    searchResults = results.map { ($0.title, $0.artist, $0.imageURL, $0.uri) }
                                }
                            }
                        }


                    if isSearchFieldFocused || isSearching {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                resetSearch()
                            }
                        }) {
                            Text("Abbrechen")
                                .foregroundColor(.gray)
                                .font(.system(size: 16, weight: .medium))
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSearchFieldFocused || isSearching ? Color.black.opacity(0.8) : Color.white)
                        .animation(.easeInOut(duration: 0.2), value: isSearchFieldFocused || isSearching)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSearchFieldFocused || isSearching ? Color.gray : Color.clear, lineWidth: 1.5)
                        .animation(.easeInOut(duration: 0.2), value: isSearchFieldFocused || isSearching)
                )
                .padding(.horizontal)
                .padding(.top, 8)

                // **Entscheidung zwischen Suchansicht und Standardansicht**
                if isSearching || isSearchFieldFocused {
                    // **Suchmodus: Suchergebnisse oder Verlauf anzeigen**
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            if searchText.isEmpty {
                                // **Suchverlauf anzeigen**
                                if !viewModel.searchHistory.isEmpty {
                                    Text("Letzte Suchanfragen")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal)

                                    ForEach(viewModel.searchHistory, id: \.title) { query in
                                        HStack {
                                            AsyncImage(url: URL(string: query.imageURL)) { image in
                                                image.resizable()
                                                    .scaledToFit()
                                            } placeholder: {
                                                ProgressView()
                                            }
                                            .frame(width: 50, height: 50)
                                            .cornerRadius(8)

                                            VStack(alignment: .leading) {
                                                Text(query.title)
                                                    .font(.headline)
                                                    .foregroundColor(.white)
                                                Text(query.artist)
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                            }
                                            Spacer()
                                            Button(action: {
                                                viewModel.removeFromSearchHistory(query.title)
                                            }) {
                                                Image(systemName: "xmark")
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        .padding(.horizontal)
                                        .padding(.vertical, 4)
                                    }
                                } else {
                                    Text("Keine Einträge im Suchverlauf")
                                        .font(.title3)
                                        .foregroundColor(.gray)
                                        .padding(.horizontal)
                                }
                            } else if !searchResults.isEmpty {
                                // **Suchergebnisse anzeigen**
                                Text("Suchergebnisse")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)

                                ForEach(searchResults, id: \.uri) { result in
                                    Button(action: {
                                        viewModel.play(uri: result.uri)
                                        viewModel.addToSearchHistory((title: result.title, artist: result.artist, imageURL: result.imageURL, uri: result.uri))

                                    }) {
                                        HStack {
                                            // **Song Bild**
                                            AsyncImage(url: URL(string: result.imageURL)) { image in
                                                image.resizable().scaledToFit()
                                            } placeholder: {
                                                ProgressView()
                                            }
                                            .frame(width: 50, height: 50)
                                            .cornerRadius(8)

                                            // **Song-Infos**
                                            VStack(alignment: .leading) {
                                                Text(result.title)
                                                    .font(.headline)
                                                    .foregroundColor(.white)
                                                Text(result.artist)
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                            }
                                            Spacer()

                                            // **Drei-Punkte-Menü-Button**
                                            Button(action: {
                                                selectedSong = Song(title: result.title, artist: result.artist)
                                                
                                                // **NEU: Verzögertes Öffnen, um weißen Bildschirm zu vermeiden**
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                    showingActionSheet = true
                                                }
                                            }) {
                                                Image(systemName: "ellipsis")
                                                    .foregroundColor(.white)
                                                    .padding()
                                            }

                            }
                            .background(Color.black.edgesIgnoringSafeArea(.all))
                            .navigationBarTitle("Suche", displayMode: .inline)

                            // **NEU: Sheet für das Menü**
                            .sheet(item: $selectedSong) { song in
                                SongActionSheet(song: song)
                                    .environmentObject(playlistManager)
                                    .presentationDetents([.medium, .large]) // Standardmäßig halber Bildschirm
                            }

                                        .padding(.horizontal)
                                        .padding(.vertical, 4)
                                    }
                                }
                            } else {
                                // **Keine Ergebnisse gefunden**
                                Text("Keine Suchergebnisse")
                                    .font(.title3)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                            }
                        }
                    }
                } else {
                    // **Standardzustand mit Cards**
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Alles durchsuchen")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(genres, id: \.name) { genre in
                                    NavigationLink(destination: GenreChartsView(genre: genre.name).environmentObject(viewModel)) {
                                        ZStack(alignment: .topLeading) {
                                            RoundedRectangle(cornerRadius: 5)
                                                .fill(genre.color)
                                                .frame(width: 167, height: 100)

                                            if let imageName = genre.imageName {
                                                Image(imageName)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .clipped()
                                                    .frame(width: 280, height: 280)
                                                    .clipShape(Circle())
                                                    .position(x: 125, y: 50)
                                            }

                                            Text(genre.name)
                                                .font(.headline)
                                                .foregroundColor(.white)
                                                .padding([.leading, .bottom], 10)
                                                .padding(.top, 13)
                                        }
                                    }
                                    .frame(height: 100)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top)
                    }
                }
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .navigationBarTitle("Suche", displayMode: .inline)
        }
    }

    private func resetSearch() {
        searchText = ""
        searchResults = []
        isSearchFieldFocused = false
        isSearching = false
    }
}


