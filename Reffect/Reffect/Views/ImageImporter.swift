//
//  ImageImporter.swift
//  Reffect
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct ImageImporter: UIViewControllerRepresentable {
    let onImagesImported: ([String]) -> Void

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
        Coordinator(onImagesImported: onImagesImported)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let onImagesImported: ([String]) -> Void

        init(onImagesImported: @escaping ([String]) -> Void) {
            self.onImagesImported = onImagesImported
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard !results.isEmpty else { return }

            Task {
                var filenames: [String] = []

                for result in results {
                    do {
                        let url = try await loadFileRepresentation(from: result.itemProvider)
                        let filename = try await ImageProcessor.processAndSaveImage(at: url)
                        filenames.append(filename)
                        try? FileManager.default.removeItem(at: url)
                    } catch {
                        print("Failed to process image: \(error)")
                    }
                }

                await MainActor.run {
                    self.onImagesImported(filenames)
                }
            }
        }

        private func loadFileRepresentation(from provider: NSItemProvider) async throws -> URL {
            try await withCheckedThrowingContinuation { continuation in
                provider.loadFileRepresentation(for: UTType.image) { url, _, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let url = url {
                        continuation.resume(returning: url)
                    } else {
                        continuation.resume(throwing: ImageProcessingError.sourceCreationFailed)
                    }
                }
            }
        }
    }
}
