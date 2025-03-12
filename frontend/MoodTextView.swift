//
//  MoodTextView.swift
//  MusicMatch
//
//  Created by Jonathan Reuter on 27.01.25.
//


import SwiftUI
import PhotosUI

struct MoodTextView: View {
    @State private var moodText = "" // Eingabe des Nutzers
    @State private var moodResponse = "" // Antwort von ChatGPT
    @State private var isStartedTypeWriter = false // Kontrolliert die Animation
    @State private var suggestedSongs: [(title: String, artist: String, image: String, uri: String)] = [] // Songs mit URI
    @EnvironmentObject var viewModel: SpotifyViewModel
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false

    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                
                // **Überschrift "Stimmungsanalyse"**
                HStack {
                    Text("Stimmungsanalyse")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 57)
                
                // ✅ Eingabefeld für Text & Bild als Anhang
                VStack(alignment: .leading) {
                    ZStack {
                        // 📝 Texteditor für Stimmungsbeschreibung
                        TextEditor(text: $moodText)
                            .padding(5)
                            .frame(height: 80)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.green, lineWidth: 1)
                            )
                        
                        // 🔹 Platzhalter-Text (wird nur angezeigt, wenn das Feld leer ist)
                        // 🔹 Platzhalter-Text (zentriert im Textfeld)
                        if moodText.isEmpty {
                            Text("😊 Wie fühlst du dich heute?")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading) // Links ausgerichtet
                                .padding(.leading, 25)
                                .padding(.vertical, 15) // ✅ Vertikal mittig platzieren
                        }


                        // ❌ X-Button zum Löschen des Textes (rechtsbündig)
                        if !moodText.isEmpty {
                            HStack {
                                Spacer() // Drückt das "X" nach rechts
                                
                                Button(action: {
                                    moodText = "" // ✅ Textfeld leeren
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .resizable()
                                        .frame(width: 20, height: 20) // Größe des Icons
                                        .foregroundColor(.gray)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                        .padding(.trailing, 10) // Abstand vom Rand
                                }
                            }
                            .padding(.trailing, 5)
                        }
                    }

                    // 📎 Falls ein Bild hochgeladen wurde, zeige es als Anhang mit X-Button
                    if let selectedImage = selectedImage {
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white, lineWidth: 1)
                                )

                            // ❌ X-Button zum Entfernen des Bildes
                            Button(action: {
                                DispatchQueue.main.async {
                                    self.selectedImage = nil
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.gray)
                                    .background(Color.white)
                                    .clipShape(Circle())
                            }
                            .offset(x: 10, y: -10) // Position des X-Icons für das Bild
                        }
                    }
                

                    
                    // ➕ Button für das Hinzufügen eines Bildes, in das Textfeld integriert
                    HStack {
                        // ➕ Button für das Hinzufügen eines Bildes, in das Textfeld integriert
                        Button(action: { showingImagePicker = true }) {
                            Image(systemName: "plus.circle.fill")
                                .resizable() // ✅ Macht das Icon skalierbar
                                .frame(width: 35, height: 35) // ✅ Größe direkt setzen
                                .foregroundColor(.green)
                            
                        }

                        Spacer()

                        // 🟢 Suchen-Button für die Analyse
                        Button(action: {
                            // ✅ Vor jeder Anfrage alles zurücksetzen
                            DispatchQueue.main.async {
                                moodResponse = "" // Antwortfeld leeren
                                suggestedSongs.removeAll() // Alte Songs entfernen
                                isStartedTypeWriter = false
                            }

                            if let image = selectedImage {
                                analyzeMoodFromImage(image)
                            } else {
                                analyzeMoodFromText(moodText)
                            }
                        }) {
                            Image(systemName: "paperplane.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.green)
                                .clipShape(Circle())
                        }

                    }
                    .frame(height: 30)
                    .offset(y: -10)
                }
                .sheet(isPresented: $showingImagePicker) {
                    ImagePicker(selectedImage: $selectedImage)
                }
                .padding(.horizontal)

                // ✅ GPT-Antwort mit Typewriter-Effekt
                TypeWriterView(text: $moodResponse, speed: 0.03, isStarted: $isStartedTypeWriter)
                    .foregroundColor(.white)
                    .padding(.top, 10)
                    .padding(.horizontal, 9) // 🔥 Einheitlicher Rand

                // ✅ Trennlinie zwischen GPT-Text und Songliste
                if !suggestedSongs.isEmpty {
                    Divider()
                        .background(Color.white.opacity(0.3))
                        .padding(.vertical, 10)
                        
                }

                // ✅ Spotify-Songliste unter der GPT-Antwort anzeigen
                if !suggestedSongs.isEmpty {
                    ScrollView(.vertical, showsIndicators: true) {
                        LazyVStack(spacing: 15) {
                            ForEach(suggestedSongs.indices, id: \.self) { index in
                                HStack(alignment: .center) {
                                    AsyncImage(url: URL(string: suggestedSongs[index].image)) { image in
                                        image
                                            .resizable()
                                            .frame(width: 60, height: 60)
                                            .cornerRadius(8)
                                            .padding(.trailing, 10)
                                    } placeholder: {
                                        Image(systemName: "photo")
                                            .resizable()
                                            .frame(width: 60, height: 60)
                                            .cornerRadius(8)
                                            .padding(.trailing, 10)
                                    }

                                    VStack(alignment: .leading) {
                                        Text(suggestedSongs[index].title)
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.white)

                                        Text(suggestedSongs[index].artist)
                                            .font(.system(size: 14))
                                            .foregroundColor(.white.opacity(0.8))

                                        Button(action: {
                                            viewModel.play(uri: suggestedSongs[index].uri) // 🎵 Direkt auf Spotify abspielen
                                        }) {
                                            Text("Play on Spotify")
                                                .font(.system(size: 14))
                                                .foregroundColor(.green)
                                        }
                                    }
                                    Spacer()
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.black.opacity(0.6))
                                )
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 1)
                    }
                }

                Spacer()
            }
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)
            .gesture(TapGesture().onEnded {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            })
        }
    }

    // Analysiert Text wie bisher
    private func analyzeMoodFromText(_ text: String) {
        ChatGPTService().analyzeMoodAndFetchSongs(userInput: text, viewModel: viewModel) { response, songs in
            DispatchQueue.main.async {
                moodResponse = response
                suggestedSongs = songs
                isStartedTypeWriter = true
            }
        }
    }

    // Analysiert ein Bild
    private func analyzeMoodFromImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            moodResponse = "❌ Fehler: Bild konnte nicht verarbeitet werden."
            return
        }

        ChatGPTService().analyzeMoodFromImage(imageData: imageData, viewModel: viewModel) { response, songs in
            DispatchQueue.main.async {
                print("🎭 Stimmung erkannt: \(response)") // Debugging
                moodResponse = response
                suggestedSongs = songs
                isStartedTypeWriter = true
            }
        }
    }
}
