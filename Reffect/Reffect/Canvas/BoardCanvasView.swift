//
//  BoardCanvasView.swift
//  Reffect
//

import UIKit

final class BoardCanvasView: UIScrollView {
    static let canvasSize: CGFloat = 7000
    static let canvasHalf: CGFloat = 3500

    private let contentContainerView = UIView()
    private var didSetInitialOffset = false
    private var isRestoringViewport = false

    var onViewportChange: ((CGPoint, CGFloat) -> Void)?
    var initialViewport: (translateX: Double, translateY: Double, scale: Double)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCanvas()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCanvas()
    }

    private func setupCanvas() {
        backgroundColor = .systemBackground

        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        bounces = true
        alwaysBounceVertical = true
        alwaysBounceHorizontal = true
        minimumZoomScale = 0.1
        maximumZoomScale = 5.0
        delegate = self

        contentSize = CGSize(width: Self.canvasSize, height: Self.canvasSize)

        contentContainerView.frame = CGRect(
            x: 0,
            y: 0,
            width: Self.canvasSize,
            height: Self.canvasSize
        )
        addSubview(contentContainerView)

        let patternImage = createGridPatternImage()
        contentContainerView.backgroundColor = UIColor(patternImage: patternImage)
    }

    private func createGridPatternImage() -> UIImage {
        let spacing: CGFloat = 50
        let size = CGSize(width: spacing, height: spacing)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let dotRadius: CGFloat = 1.5
            let rect = CGRect(
                x: spacing / 2 - dotRadius,
                y: spacing / 2 - dotRadius,
                width: dotRadius * 2,
                height: dotRadius * 2
            )
            UIColor.systemGray3.setFill()
            context.cgContext.fillEllipse(in: rect)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard bounds.width > 0, bounds.height > 0, !didSetInitialOffset else { return }

        isRestoringViewport = true
        defer { isRestoringViewport = false }

        if let viewport = initialViewport {
            zoomScale = CGFloat(viewport.scale)
            contentOffset = CGPoint(x: CGFloat(viewport.translateX), y: CGFloat(viewport.translateY))
        } else {
            let offsetX = (Self.canvasSize - bounds.width) / 2
            let offsetY = (Self.canvasSize - bounds.height) / 2
            contentOffset = CGPoint(x: max(0, offsetX), y: max(0, offsetY))
        }
        didSetInitialOffset = true
    }
}

extension BoardCanvasView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        contentContainerView
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isRestoringViewport else { return }
        notifyViewportChange()
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        guard !isRestoringViewport else { return }
        notifyViewportChange()
    }

    private func notifyViewportChange() {
        onViewportChange?(contentOffset, zoomScale)
    }
}
