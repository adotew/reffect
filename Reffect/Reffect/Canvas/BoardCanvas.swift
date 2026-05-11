//
//  BoardCanvas.swift
//  Reffect
//

import SwiftUI

struct BoardCanvas: UIViewRepresentable {
    let board: Board
    @Binding var selectedItemID: UUID?
    let onViewportChange: (Double, Double, Double) -> Void
    let onItemPositionChanged: (UUID, Double, Double) -> Void
    let onItemSizeChanged: (UUID, Double, Double, Double, Double) -> Void

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
        scrollView.onItemSizeChanged = { itemID, width, height, x, y in
            context.coordinator.handleItemSizeChanged(itemID: itemID, width: width, height: height, x: x, y: y)
        }
        scrollView.onSelectionChanged = { itemID in
            context.coordinator.handleSelectionChanged(itemID: itemID)
        }
        scrollView.setItems(board.items)

        return container
    }

    func updateUIView(_ uiView: BoardCanvasContainer, context: Context) {
        uiView.scrollView.setItems(board.items)
        if uiView.scrollView.selectedItemID != selectedItemID {
            uiView.scrollView.selectedItemID = selectedItemID
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
            selectedItemID: $selectedItemID,
            onViewportChange: onViewportChange,
            onItemPositionChanged: onItemPositionChanged,
            onItemSizeChanged: onItemSizeChanged
        )
    }

    class Coordinator {
        @Binding var selectedItemID: UUID?
        private let onViewportChange: (Double, Double, Double) -> Void
        private let onItemPositionChanged: (UUID, Double, Double) -> Void
        private let onItemSizeChanged: (UUID, Double, Double, Double, Double) -> Void
        private var debounceWorkItem: DispatchWorkItem?
        private let debounceInterval: TimeInterval = 0.8

        init(
            selectedItemID: Binding<UUID?>,
            onViewportChange: @escaping (Double, Double, Double) -> Void,
            onItemPositionChanged: @escaping (UUID, Double, Double) -> Void,
            onItemSizeChanged: @escaping (UUID, Double, Double, Double, Double) -> Void
        ) {
            self._selectedItemID = selectedItemID
            self.onViewportChange = onViewportChange
            self.onItemPositionChanged = onItemPositionChanged
            self.onItemSizeChanged = onItemSizeChanged
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

        func handleItemSizeChanged(itemID: UUID, width: Double, height: Double, x: Double, y: Double) {
            onItemSizeChanged(itemID, width, height, x, y)
        }

        func handleSelectionChanged(itemID: UUID?) {
            selectedItemID = itemID
        }
    }
}
