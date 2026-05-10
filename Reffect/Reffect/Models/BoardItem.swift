//
//  BoardItem.swift
//  Reffect
//

import Foundation

struct BoardItem: Codable, Identifiable {
    let id: UUID
    var imageSource: String
    var x: Double
    var y: Double
    var width: Double
    var height: Double
    var scale: Double
    var rotation: Double
    var flipHorizontal: Bool

    init(id: UUID = UUID(), imageSource: String, x: Double = 0, y: Double = 0, width: Double = 200, height: Double = 200, scale: Double = 1.0, rotation: Double = 0, flipHorizontal: Bool = false) {
        self.id = id
        self.imageSource = imageSource
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.scale = scale
        self.rotation = rotation
        self.flipHorizontal = flipHorizontal
    }
}
