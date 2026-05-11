//
//  CanvasView.swift
//  Reffect
//

import SwiftUI

struct CanvasView: View {
    let board: Board
    @Environment(AppStore.self) private var store

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
    }
}

#Preview {
    CanvasView(board: Board(name: "Test"))
        .environment(AppStore())
}
