//
//  ContentView.swift
//  Reffect
//

import SwiftUI

struct ContentView: View {
    @State private var boards: [Board] = []
    @State private var persistence = PersistenceManager.shared

    var body: some View {
        NavigationStack {
            List {
                ForEach(boards) { board in
                    VStack(alignment: .leading) {
                        Text(board.name)
                            .font(.headline)
                        Text("\(board.items.count) items")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Reffect")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: addTestBoard) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Load") {
                        boards = persistence.loadBoards()
                    }
                }
            }
            .onAppear {
                boards = persistence.loadBoards()
            }
        }
    }

    private func addTestBoard() {
        let newBoard = Board(name: "Board \(boards.count + 1)")
        boards.append(newBoard)
        Task {
            try? await persistence.saveBoards(boards)
        }
    }
}

#Preview {
    ContentView()
}
