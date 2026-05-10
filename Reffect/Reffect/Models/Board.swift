//
//  Board.swift
//  Reffect
//

import Foundation

struct Board: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var items: [BoardItem]
    let createdAt: Date
    var lastModified: Date
    var viewportTranslateX: Double?
    var viewportTranslateY: Double?
    var viewportScale: Double?

    init(id: UUID = UUID(), name: String, items: [BoardItem] = [], createdAt: Date = Date(), lastModified: Date = Date(), viewportTranslateX: Double? = nil, viewportTranslateY: Double? = nil, viewportScale: Double? = nil) {
        self.id = id
        self.name = name
        self.items = items
        self.createdAt = createdAt
        self.lastModified = lastModified
        self.viewportTranslateX = viewportTranslateX
        self.viewportTranslateY = viewportTranslateY
        self.viewportScale = viewportScale
    }
}
