//
//  AppStore.swift
//  Reffect
//

import Foundation
import ImageIO
import Observation

@Observable
class AppStore {
    var boards: [Board] = []
    private let persistence = PersistenceManager.shared

    init() {
        boards = persistence.loadBoards()
    }

    @discardableResult
    func createBoard(name: String = "Untitled") -> Board {
        let board = Board(name: name)
        boards.append(board)
        saveBoards()
        return board
    }

    func renameBoard(id: UUID, to newName: String) {
        if let index = boards.firstIndex(where: { $0.id == id }) {
            boards[index].name = newName
            boards[index].lastModified = Date()
            saveBoards()
        }
    }

    func deleteBoard(id: UUID) {
        if let index = boards.firstIndex(where: { $0.id == id }) {
            let board = boards[index]
            for item in board.items {
                persistence.deleteImage(filename: item.imageSource)
            }
            boards.remove(at: index)
            saveBoards()
        }
    }

    func addImage(to boardId: UUID, filename: String) -> BoardItem {
        let url = PersistenceManager.shared.imageURL(for: filename)
        var naturalWidth: CGFloat = 200
        var naturalHeight: CGFloat = 200
        if let source = CGImageSourceCreateWithURL(url as CFURL, nil) {
            let props = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
            if let w = props?[kCGImagePropertyPixelWidth] as? CGFloat,
               let h = props?[kCGImagePropertyPixelHeight] as? CGFloat,
               w > 0, h > 0 {
                let maxDim: CGFloat = 200
                let scale = min(maxDim / w, maxDim / h)
                naturalWidth = w * scale
                naturalHeight = h * scale
            }
        }
        let item = BoardItem(imageSource: filename, width: Double(naturalWidth), height: Double(naturalHeight))
        if let index = boards.firstIndex(where: { $0.id == boardId }) {
            var board = boards[index]
            board.items.append(item)
            board.lastModified = Date()
            boards[index] = board
            saveBoards()
        }
        return item
    }

    func updateItemPosition(boardId: UUID, itemId: UUID, x: Double, y: Double) {
        if let boardIndex = boards.firstIndex(where: { $0.id == boardId }) {
            var board = boards[boardIndex]
            if let itemIndex = board.items.firstIndex(where: { $0.id == itemId }) {
                board.items[itemIndex].x = x
                board.items[itemIndex].y = y
                board.lastModified = Date()
                boards[boardIndex] = board
                saveBoards()
            }
        }
    }

    func deleteItem(boardId: UUID, itemId: UUID) {
        if let boardIndex = boards.firstIndex(where: { $0.id == boardId }) {
            var board = boards[boardIndex]
            board.items.removeAll(where: { $0.id == itemId })
            board.lastModified = Date()
            boards[boardIndex] = board
            saveBoards()
        }
    }

    func duplicateItem(boardId: UUID, itemId: UUID) {
        if let boardIndex = boards.firstIndex(where: { $0.id == boardId }) {
            var board = boards[boardIndex]
            if let item = board.items.first(where: { $0.id == itemId }) {
                let copy = BoardItem(
                    imageSource: item.imageSource,
                    x: item.x + 20,
                    y: item.y + 20,
                    width: item.width,
                    height: item.height,
                    scale: item.scale,
                    rotation: item.rotation,
                    flipHorizontal: item.flipHorizontal,
                    isBlackAndWhite: item.isBlackAndWhite,
                    isBlurred: item.isBlurred,
                    blurRadius: item.blurRadius,
                    isPosterized: item.isPosterized,
                    posterizationLevels: item.posterizationLevels
                )
                board.items.append(copy)
                board.lastModified = Date()
                boards[boardIndex] = board
                saveBoards()
            }
        }
    }

    func updateItemSize(boardId: UUID, itemId: UUID, width: Double, height: Double, x: Double, y: Double) {
        if let boardIndex = boards.firstIndex(where: { $0.id == boardId }) {
            var board = boards[boardIndex]
            if let itemIndex = board.items.firstIndex(where: { $0.id == itemId }) {
                board.items[itemIndex].width = width
                board.items[itemIndex].height = height
                board.items[itemIndex].x = x
                board.items[itemIndex].y = y
                board.lastModified = Date()
                boards[boardIndex] = board
                saveBoards()
            }
        }
    }

    func updateViewport(id: UUID, translateX: Double, translateY: Double, scale: Double) {
        if let index = boards.firstIndex(where: { $0.id == id }) {
            boards[index].viewportTranslateX = translateX
            boards[index].viewportTranslateY = translateY
            boards[index].viewportScale = scale
            boards[index].lastModified = Date()
            saveBoards()
        }
    }

    // MARK: - Image Transformations

    func toggleItemFlip(boardId: UUID, itemId: UUID) {
        if let boardIndex = boards.firstIndex(where: { $0.id == boardId }) {
            var board = boards[boardIndex]
            if let itemIndex = board.items.firstIndex(where: { $0.id == itemId }) {
                board.items[itemIndex].flipHorizontal.toggle()
                board.lastModified = Date()
                boards[boardIndex] = board
                saveBoards()
            }
        }
    }

    func toggleItemBlackAndWhite(boardId: UUID, itemId: UUID) {
        if let boardIndex = boards.firstIndex(where: { $0.id == boardId }) {
            var board = boards[boardIndex]
            if let itemIndex = board.items.firstIndex(where: { $0.id == itemId }) {
                board.items[itemIndex].isBlackAndWhite.toggle()
                board.lastModified = Date()
                boards[boardIndex] = board
                saveBoards()
            }
        }
    }

    func toggleItemBlur(boardId: UUID, itemId: UUID) {
        if let boardIndex = boards.firstIndex(where: { $0.id == boardId }) {
            var board = boards[boardIndex]
            if let itemIndex = board.items.firstIndex(where: { $0.id == itemId }) {
                board.items[itemIndex].isBlurred.toggle()
                board.lastModified = Date()
                boards[boardIndex] = board
                saveBoards()
            }
        }
    }

    func setItemBlurRadius(boardId: UUID, itemId: UUID, radius: Double) {
        if let boardIndex = boards.firstIndex(where: { $0.id == boardId }) {
            var board = boards[boardIndex]
            if let itemIndex = board.items.firstIndex(where: { $0.id == itemId }) {
                board.items[itemIndex].blurRadius = radius
                board.lastModified = Date()
                boards[boardIndex] = board
                saveBoards()
            }
        }
    }

    func toggleItemPosterize(boardId: UUID, itemId: UUID) {
        if let boardIndex = boards.firstIndex(where: { $0.id == boardId }) {
            var board = boards[boardIndex]
            if let itemIndex = board.items.firstIndex(where: { $0.id == itemId }) {
                board.items[itemIndex].isPosterized.toggle()
                board.lastModified = Date()
                boards[boardIndex] = board
                saveBoards()
            }
        }
    }

    func setItemPosterizationLevels(boardId: UUID, itemId: UUID, levels: Double) {
        if let boardIndex = boards.firstIndex(where: { $0.id == boardId }) {
            var board = boards[boardIndex]
            if let itemIndex = board.items.firstIndex(where: { $0.id == itemId }) {
                board.items[itemIndex].posterizationLevels = levels
                board.lastModified = Date()
                boards[boardIndex] = board
                saveBoards()
            }
        }
    }

    private func saveBoards() {
        Task {
            try? await persistence.saveBoards(boards)
        }
    }
}
