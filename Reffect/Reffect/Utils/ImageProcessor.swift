//
//  ImageProcessor.swift
//  Reffect
//

import Foundation
import ImageIO
import UniformTypeIdentifiers

enum ImageProcessingError: Error {
    case sourceCreationFailed
    case thumbnailCreationFailed
    case destinationCreationFailed
    case writeFailed
}

enum ImageProcessor {
    static let maxDimension: CGFloat = 1500
    static let compressionQuality: CGFloat = 0.9

    static func processAndSaveImage(at sourceURL: URL) async throws -> String {
        try PersistenceManager.shared.ensureImagesDirectoryExists()

        let filename = UUID().uuidString + ".jpg"
        let destinationURL = PersistenceManager.shared.imagesDirectoryURL.appendingPathComponent(filename)

        guard let source = CGImageSourceCreateWithURL(sourceURL as CFURL, nil) else {
            throw ImageProcessingError.sourceCreationFailed
        }

        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimension,
            kCGImageSourceCreateThumbnailWithTransform: true
        ]

        guard let thumbnail = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            throw ImageProcessingError.thumbnailCreationFailed
        }

        guard let destination = CGImageDestinationCreateWithURL(
            destinationURL as CFURL,
            UTType.jpeg.identifier as CFString,
            1,
            nil
        ) else {
            throw ImageProcessingError.destinationCreationFailed
        }

        let properties: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: compressionQuality
        ]

        CGImageDestinationAddImage(destination, thumbnail, properties as CFDictionary)

        guard CGImageDestinationFinalize(destination) else {
            throw ImageProcessingError.writeFailed
        }

        return filename
    }
}
