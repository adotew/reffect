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
