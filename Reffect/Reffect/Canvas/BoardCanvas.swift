//
//  BoardCanvas.swift
//  Reffect
//

import SwiftUI

struct BoardCanvas: UIViewRepresentable {
    let board: Board
    let onViewportChange: (Double, Double, Double) -> Void
    let onItemPositionChanged: (UUID, Double, Double) -> Void

    func makeUIView(context: Context) -> BoardCanvasContainer {
        let container = BoardCanvasContainer()
        let scrollView = container.scrollView

        scrollView.initialViewport = board.savedViewport
        scrollView.onViewportChange = { offset, scale in
            context.coordinator.scheduleViewportUpdate(
                translateX: Double(offset.x),
                translateY: Double(offset.y),
                scale: Double(scale)
            )
        }
        scrollView.onItemPositionChanged = { itemID, x, y in
            context.coordinator.handleItemPositionChanged(itemID: itemID, x: x, y: y)
        }
        scrollView.setItems(board.items)

        return container
    }

    func updateUIView(_ uiView: BoardCanvasContainer, context: Context) {
        uiView.scrollView.setItems(board.items)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onViewportChange: onViewportChange, onItemPositionChanged: onItemPositionChanged)
    }

    class Coordinator {
        private let onViewportChange: (Double, Double, Double) -> Void
        private let onItemPositionChanged: (UUID, Double, Double) -> Void
        private var debounceWorkItem: DispatchWorkItem?
        private let debounceInterval: TimeInterval = 0.8

        init(
            onViewportChange: @escaping (Double, Double, Double) -> Void,
            onItemPositionChanged: @escaping (UUID, Double, Double) -> Void
        ) {
            self.onViewportChange = onViewportChange
            self.onItemPositionChanged = onItemPositionChanged
        }

        func scheduleViewportUpdate(translateX: Double, translateY: Double, scale: Double) {
            debounceWorkItem?.cancel()
            let workItem = DispatchWorkItem { [weak self] in
                self?.onViewportChange(translateX, translateY, scale)
            }
            debounceWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + debounceInterval, execute: workItem)
        }

        func handleItemPositionChanged(itemID: UUID, x: Double, y: Double) {
            onItemPositionChanged(itemID, x, y)
        }
    }
}
