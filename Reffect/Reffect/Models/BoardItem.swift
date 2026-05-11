//
//  BoardItem.swift
//  Reffect
//

import Foundation

struct BoardItem: Codable, Identifiable, Hashable {
    let id: UUID
    var imageSource: String
    var x: Double
    var y: Double
    var width: Double
    var height: Double
    var scale: Double
    var rotation: Double
    var flipHorizontal: Bool
    var isBlackAndWhite: Bool
    var isBlurred: Bool
    var blurRadius: Double
    var isPosterized: Bool
    var posterizationLevels: Double

    init(id: UUID = UUID(), imageSource: String, x: Double = 0, y: Double = 0, width: Double = 200, height: Double = 200, scale: Double = 1.0, rotation: Double = 0, flipHorizontal: Bool = false, isBlackAndWhite: Bool = false, isBlurred: Bool = false, blurRadius: Double = 5.0, isPosterized: Bool = false, posterizationLevels: Double = 4.0) {
        self.id = id
        self.imageSource = imageSource
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.scale = scale
        self.rotation = rotation
        self.flipHorizontal = flipHorizontal
        self.isBlackAndWhite = isBlackAndWhite
        self.isBlurred = isBlurred
        self.blurRadius = blurRadius
        self.isPosterized = isPosterized
        self.posterizationLevels = posterizationLevels
    }
}
