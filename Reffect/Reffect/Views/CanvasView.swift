//
//  CanvasView.swift
//  Reffect
//

import SwiftUI

struct CanvasView: View {
    let board: Board
    @Environment(AppStore.self) private var store
    @State private var isImporting = false

    var body: some View {
        BoardCanvas(
            board: board,
            onViewportChange: { translateX, translateY, scale in
                store.updateViewport(
                    id: board.id,
                    translateX: translateX,
                    translateY: translateY,
                    scale: scale
                )
            }
        )
        .navigationTitle(board.name)
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
            ImageImporter { filenames in
                for filename in filenames {
                    store.addImage(to: board.id, filename: filename)
                }
            }
        }
    }
}

#Preview {
    CanvasView(board: Board(name: "Test"))
        .environment(AppStore())
}
