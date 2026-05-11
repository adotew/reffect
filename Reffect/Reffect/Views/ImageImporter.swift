//
//  ImageImporter.swift
//  Reffect
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct ImportResult: Identifiable {
    let id = UUID()
    let successful: Int
    let failed: Int
    let total: Int
}

struct ImageImporter: UIViewControllerRepresentable {
    let onBatchComplete: (ImportResult) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 0
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onBatchComplete: onBatchComplete)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let onBatchComplete: (ImportResult) -> Void

        init(onBatchComplete: @escaping (ImportResult) -> Void) {
            self.onBatchComplete = onBatchComplete
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard !results.isEmpty else { return }

            Task {
                let result = await processBatch(results)
                await MainActor.run {
                    self.onBatchComplete(result)
                }
            }
        }

        private func processBatch(_ results: [PHPickerResult]) async -> ImportResult {
            let fm = FileManager.default
            let sessionDir = fm.temporaryDirectory.appendingPathComponent("ImageImport-\(UUID().uuidString)")
            try? fm.createDirectory(at: sessionDir, withIntermediateDirectories: true)

            defer {
                try? fm.removeItem(at: sessionDir)
            }

            var successfulFilenames: [String] = []
            var failedCount = 0

            for result in results {
                var copyURL: URL?

                do {
                    copyURL = try await loadAndCopy(from: result.itemProvider, to: sessionDir)

                    guard let url = copyURL else {
                        throw ImageProcessingError.sourceCreationFailed
                    }

                    let filename = try await ImageProcessor.processAndSaveImage(at: url)
                    successfulFilenames.append(filename)
                } catch {
                    print("Failed to import image: \(error)")
                    failedCount += 1
                }

                if let url = copyURL {
                    try? fm.removeItem(at: url)
                }
            }

            return ImportResult(
                successful: successfulFilenames.count,
                failed: failedCount,
                total: results.count
            )
        }

        private func loadAndCopy(from provider: NSItemProvider, to directory: URL) async throws -> URL {
            try await withCheckedThrowingContinuation { continuation in
                provider.loadFileRepresentation(for: UTType.image) { url, _, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }

                    guard let sourceURL = url else {
                        continuation.resume(throwing: ImageProcessingError.sourceCreationFailed)
                        return
                    }

                    let copyURL = directory.appendingPathComponent(UUID().uuidString)

                    do {
                        try FileManager.default.copyItem(at: sourceURL, to: copyURL)
                        continuation.resume(returning: copyURL)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
}
