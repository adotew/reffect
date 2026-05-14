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
            .alert("Rename Board", isPresented: .init(
                get: { boardToRename != nil },
                set: { if !$0 { boardToRename = nil } }
            )) {
                TextField("Board name", text: $renameText)
                Button("Cancel", role: .cancel) {
                    boardToRename = nil
                }
                Button("Save") {
                    if let board = boardToRename {
                        store.renameBoard(id: board.id, to: renameText)
                    }
                    boardToRename = nil
                }
            } message: {
                Text("Enter a new name for this board.")
            }
        }
    }

    private func createAndNavigate() {
        let board = store.createBoard()
        navigationPath.append(board)
    }
}

struct BoardListView_Previews: PreviewProvider {
    static var previews: some View {
        BoardListView()
            .environment(AppStore())
    }
}
