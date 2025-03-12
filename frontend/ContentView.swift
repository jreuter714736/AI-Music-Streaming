//
//  ContentView.swift
import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: SpotifyViewModel

    var body: some View {
        UnifiedView(
            title: "Music Match",
            subtitle: "Finde den Klang deiner Bilder",
            icon: "music.note",
            content: AnyView(
                VStack(spacing: 20) {
                    Button(action: {
                        viewModel.connect()
                    }) {
                        Text("Start")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 40)

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
            )
        )
    }
}

