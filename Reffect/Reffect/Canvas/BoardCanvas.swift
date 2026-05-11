//
//  BoardCanvas.swift
//  Reffect
//

import SwiftUI

struct BoardCanvas: UIViewRepresentable {
    let board: Board

    func makeUIView(context: Context) -> BoardCanvasView {
        BoardCanvasView()
    }

    func updateUIView(_ uiView: BoardCanvasView, context: Context) {
        // Step 4: no dynamic updates needed
    }
}
