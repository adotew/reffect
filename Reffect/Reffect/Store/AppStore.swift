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

    private func saveBoards() {
        Task {
            try? await persistence.saveBoards(boards)
        }
    }
}
