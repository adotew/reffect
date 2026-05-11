//
//  CanvasView.swift
//  Reffect
//

import SwiftUI

struct CanvasView: View {
    let board: Board

    var body: some View {
        BoardCanvas(board: board)
            .navigationTitle(board.name)
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    CanvasView(board: Board(name: "Test"))
}
