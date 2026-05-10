//
//  BoardListView.swift
//  Reffect
//

import SwiftUI

struct BoardListView: View {
    @Environment(AppStore.self) private var store
    @State private var navigationPath = NavigationPath()
    @State private var boardToRename: Board?
    @State private var renameText = ""

    private let columns = [
        GridItem(.adaptive(minimum: 140, maximum: 160), spacing: 20)
    ]

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 24) {
                    ForEach(store.boards) { board in
                        BoardThumbnailView(board: board)
                            .onTapGesture {
                                navigationPath.append(board)
                            }
                            .contextMenu {
                                Button {
                                    boardToRename = board
                                    renameText = board.name
                                } label: {
                                    Label("Rename", systemImage: "pencil")
                                }

                                Button(role: .destructive) {
                                    store.deleteBoard(id: board.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .padding()
            }
            .navigationTitle("Reffect")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: createAndNavigate) {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(for: Board.self) { board in
                CanvasView(board: board)
            }
            .sheet(item: $boardToRename) { board in
                NavigationStack {
                    Form {
                        Section {
                            TextField("Board name", text: $renameText)
                        }
                    }
                    .navigationTitle("Rename Board")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                boardToRename = nil
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                store.renameBoard(id: board.id, to: renameText)
                                boardToRename = nil
                            }
                        }
                    }
                }
            }
        }
    }

    private func createAndNavigate() {
        let board = store.createBoard()
        navigationPath.append(board)
    }
}

#Preview {
    BoardListView()
        .environment(AppStore())
}
