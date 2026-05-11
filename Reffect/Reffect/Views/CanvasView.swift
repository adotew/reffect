//
//  CanvasView.swift
//  Reffect
//

import SwiftUI

struct CanvasView: View {
    let board: Board
    @Environment(AppStore.self) private var store
    @State private var isImporting = false
    @State private var importResult: ImportResult?
    @State private var selectedItemID: UUID?

    private var liveBoard: Board {
        store.boards.first(where: { $0.id == board.id }) ?? board
    }

    var body: some View {
        BoardCanvas(
            board: liveBoard,
            onViewportChange: { translateX, translateY, scale in
                store.updateViewport(
                    id: board.id,
                    translateX: translateX,
                    translateY: translateY,
                    scale: scale
                )
            },
            onItemPositionChanged: { itemID, x, y in
                store.updateItemPosition(
                    boardId: board.id,
                    itemId: itemID,
                    x: x,
                    y: y
                )
            },
            onItemSizeChanged: { itemID, width, height, x, y in
                store.updateItemSize(
                    boardId: board.id,
                    itemId: itemID,
                    width: width,
                    height: height,
                    x: x,
                    y: y
                )
            }
        )
        .navigationTitle(liveBoard.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isImporting = true
                } label: {
                    Image(systemName: "photo.badge.plus")
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        if let itemID = selectedItemID {
                            store.duplicateItem(boardId: board.id, itemId: itemID)
                        }
                    } label: {
                        Label("Duplicate", systemImage: "doc.on.doc")
                    }
                    .disabled(selectedItemID == nil)

                    Button(role: .destructive) {
                        if let itemID = selectedItemID {
                            store.deleteItem(boardId: board.id, itemId: itemID)
                            selectedItemID = nil
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .disabled(selectedItemID == nil)
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $isImporting) {
            ImageImporter { result in
                isImporting = false
                importResult = result
                for filename in result.filenames {
                    store.addImage(to: board.id, filename: filename)
                }
            }
        }
        .alert(item: $importResult) { result in
            if result.failed > 0 {
                return Alert(
                    title: Text("Import Complete"),
                    message: Text("\(result.successful) of \(result.total) images imported. \(result.failed) failed."),
                    dismissButton: .default(Text("OK"))
                )
            } else {
                return Alert(
                    title: Text("Import Complete"),
                    message: Text("\(result.successful) images imported successfully."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

#Preview {
    CanvasView(board: Board(name: "Test"))
        .environment(AppStore())
}
