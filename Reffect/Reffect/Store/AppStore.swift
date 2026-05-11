//
//  AppStore.swift
//  Reffect
//

import Foundation
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
        let item = BoardItem(imageSource: filename)
        if let index = boards.firstIndex(where: { $0.id == boardId }) {
            var board = boards[index]
            board.items.append(item)
            board.lastModified = Date()
            boards[index] = board
            saveBoards()
        }
        return item
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

    private func saveBoards() {
        Task {
            try? await persistence.saveBoards(boards)
        }
    }
}
