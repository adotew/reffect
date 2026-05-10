//
//  ContentView.swift
//  Reffect
//
//  Created by Adonai Tewolde on 10.05.26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Image(systemName: "square.grid.2x2")
                    .font(.system(size: 64))
                    .foregroundStyle(.secondary)
                Text("No Boards Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Create your first moodboard to get started.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Reffect")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
