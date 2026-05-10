//
//  CanvasView.swift
//  Reffect
//

import SwiftUI

struct CanvasView: View {
    let board: Board

    var body: some View {
        VStack {
            Text(board.name)
                .font(.title)
                .padding()
            Spacer()
            Text("Canvas placeholder — Step 4")
                .foregroundStyle(.secondary)
            Spacer()
        }
        .navigationTitle(board.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    CanvasView(board: Board(name: "Test"))
}
