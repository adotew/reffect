//
//  CanvasView.swift
//  Reffect
//

import SwiftUI

struct CanvasView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let board: Board
    @State private var isImporting = false
    @State private var selectedItemID: UUID?

    private var liveBoard: Board {
        store.boards.first(where: { $0.id == board.id }) ?? board
    }

    private var selectedItem: BoardItem? {
        guard let id = selectedItemID else { return nil }
        return liveBoard.items.first(where: { $0.id == id })
    }

    var body: some View {
        ZStack {
            BoardCanvas(
                board: liveBoard,
                selectedItemID: $selectedItemID,
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
            .ignoresSafeArea()

            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }

                    Spacer()

                    Button {
                        isImporting = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Spacer()

                if selectedItemID != nil {
                    ImageToolbar(
                        item: selectedItem,
                        onFlip: {
                            if let id = selectedItemID {
                                store.toggleItemFlip(boardId: board.id, itemId: id)
                            }
                        },
                        onToggleBW: {
                            if let id = selectedItemID {
                                store.toggleItemBlackAndWhite(boardId: board.id, itemId: id)
                            }
                        },
                        onToggleBlur: {
                            if let id = selectedItemID {
                                store.toggleItemBlur(boardId: board.id, itemId: id)
                            }
                        },
                        onSetBlurRadius: { radius in
                            if let id = selectedItemID {
                                store.setItemBlurRadius(boardId: board.id, itemId: id, radius: radius)
                            }
                        },
                        onTogglePosterize: {
                            if let id = selectedItemID {
                                store.toggleItemPosterize(boardId: board.id, itemId: id)
                            }
                        },
                        onSetPosterizationLevels: { levels in
                            if let id = selectedItemID {
                                store.setItemPosterizationLevels(boardId: board.id, itemId: id, levels: levels)
                            }
                        },
                        onDuplicate: {
                            if let id = selectedItemID {
                                store.duplicateItem(boardId: board.id, itemId: id)
                            }
                        },
                        onDelete: {
                            if let id = selectedItemID {
                                store.deleteItem(boardId: board.id, itemId: id)
                                selectedItemID = nil
                            }
                        }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: selectedItemID)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationBarHidden(true)
        .statusBar(hidden: true)
        .sheet(isPresented: $isImporting) {
            ImageImporter { result in
                isImporting = false
                for filename in result.filenames {
                    _ = store.addImage(to: board.id, filename: filename)
                }
            }
        }
    }
}

struct CanvasView_Previews: PreviewProvider {
    static var previews: some View {
        CanvasView(board: Board(name: "Test"))
            .environment(AppStore())
    }
}
