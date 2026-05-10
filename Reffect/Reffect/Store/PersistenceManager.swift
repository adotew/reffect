//
//  PersistenceManager.swift
//  Reffect
//

import Foundation

enum PersistenceError: Error {
    case encodeFailed(Error)
    case decodeFailed(Error)
    case writeFailed(Error)
    case directoryCreationFailed(Error)
}

actor PersistenceManager {
    static let shared = PersistenceManager()

    private let boardsFilename = "boards.json"
    private let imagesDirectoryName = "images"

    nonisolated private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    nonisolated private var boardsURL: URL {
        documentsDirectory.appendingPathComponent(boardsFilename)
    }

    nonisolated var imagesDirectoryURL: URL {
        documentsDirectory.appendingPathComponent(imagesDirectoryName)
    }

    private init() {}

    func ensureImagesDirectoryExists() throws {
        let fm = FileManager.default
        if !fm.fileExists(atPath: imagesDirectoryURL.path) {
            do {
                try fm.createDirectory(at: imagesDirectoryURL, withIntermediateDirectories: true)
            } catch {
                throw PersistenceError.directoryCreationFailed(error)
            }
        }
    }

    nonisolated func loadBoards() -> [Board] {
        let fm = FileManager.default
        guard fm.fileExists(atPath: boardsURL.path) else {
            return []
        }
        do {
            let data = try Data(contentsOf: boardsURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let boards = try decoder.decode([Board].self, from: data)
            return boards
        } catch {
            print("Failed to load boards: \(error)")
            return []
        }
    }

    func saveBoards(_ boards: [Board]) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        do {
            let data = try encoder.encode(boards)
            try data.write(to: boardsURL, options: [.atomic])
        } catch let error as EncodingError {
            throw PersistenceError.encodeFailed(error)
        } catch {
            throw PersistenceError.writeFailed(error)
        }
    }

    func imageURL(for filename: String) -> URL {
        imagesDirectoryURL.appendingPathComponent(filename)
    }

    func deleteImage(filename: String) {
        let url = imageURL(for: filename)
        try? FileManager.default.removeItem(at: url)
    }
}
