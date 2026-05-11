//
//  ItemView.swift
//  Reffect
//

import UIKit

final class ItemView: UIView {
    let item: BoardItem
    private let imageView = UIImageView()
    private var selectionOverlay: SelectionOverlayView?
    private var panStartCenter: CGPoint = .zero
    private var resizeAnchor: CGPoint = .zero
    private var resizeOriginalSize: CGSize = .zero
    private var resizeStartDistance: CGFloat = 0

    var onPositionChanged: ((Double, Double) -> Void)?
    var onSizeChanged: ((Double, Double, Double, Double) -> Void)?

    var isSelected: Bool = false {
        didSet {
            guard isSelected != oldValue else { return }
            isUserInteractionEnabled = isSelected
            if isSelected {
                showSelectionOverlay()
                superview?.bringSubviewToFront(self)
            } else {
                hideSelectionOverlay()
            }
        }
    }

    init(item: BoardItem) {
        self.item = item
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .clear
        clipsToBounds = false
        isUserInteractionEnabled = false

        let size = CGSize(width: item.width, height: item.height)
        bounds.size = size
        center = CGPoint(
            x: BoardCanvasView.canvasHalf + item.x,
            y: BoardCanvasView.canvasHalf + item.y
        )

        imageView.frame = bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        addSubview(imageView)

        loadImage()

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        addGestureRecognizer(pan)
    }

    private func loadImage() {
        let url = PersistenceManager.shared.imageURL(for: item.imageSource)
        if let image = UIImage(contentsOfFile: url.path) {
            imageView.image = image
        } else {
            imageView.backgroundColor = .systemGray5
        }
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if isSelected {
            if bounds.contains(point) { return true }
            let threshold: CGFloat = 32
            let corners = [
                CGPoint(x: imageRect.minX, y: imageRect.minY),
                CGPoint(x: imageRect.maxX, y: imageRect.minY),
                CGPoint(x: imageRect.minX, y: imageRect.maxY),
                CGPoint(x: imageRect.maxX, y: imageRect.maxY),
            ]
            for corner in corners {
                if hypot(point.x - corner.x, point.y - corner.y) <= threshold {
                    return true
                }
            }
        }
        return super.point(inside: point, with: event)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            panStartCenter = center
        case .changed:
            let translation = gesture.translation(in: superview)
            center = CGPoint(
                x: panStartCenter.x + translation.x,
                y: panStartCenter.y + translation.y
            )
        case .ended, .cancelled:
            let newX = Double(center.x - BoardCanvasView.canvasHalf)
            let newY = Double(center.y - BoardCanvasView.canvasHalf)
            onPositionChanged?(newX, newY)
        default:
            break
        }
    }

    private var imageRect: CGRect {
        guard let image = imageView.image, image.size.width > 0, image.size.height > 0 else {
            return bounds
        }
        let viewSize = bounds.size
        let imageSize = image.size
        let imageAspect = imageSize.width / imageSize.height
        let viewAspect = viewSize.width / viewSize.height
        var rect: CGRect
        if imageAspect > viewAspect {
            let height = viewSize.width / imageAspect
            rect = CGRect(x: 0, y: (viewSize.height - height) / 2, width: viewSize.width, height: height)
        } else {
            let width = viewSize.height * imageAspect
            rect = CGRect(x: (viewSize.width - width) / 2, y: 0, width: width, height: viewSize.height)
        }
        return rect
    }

    private func showSelectionOverlay() {
        guard selectionOverlay == nil else { return }
        let overlay = SelectionOverlayView(frame: imageRect)
        overlay.autoresizingMask = []
        overlay.onHandlePan = { [weak self] position, gesture in
            self?.handleResize(from: position, gesture: gesture)
        }
        addSubview(overlay)
        selectionOverlay = overlay
    }

    private func hideSelectionOverlay() {
        selectionOverlay?.removeFromSuperview()
        selectionOverlay = nil
    }

    private func anchorPoint(for position: SelectionOverlayView.HandlePosition) -> CGPoint {
        switch position {
        case .topLeft:
            return CGPoint(x: center.x + bounds.width / 2, y: center.y + bounds.height / 2)
        case .topRight:
            return CGPoint(x: center.x - bounds.width / 2, y: center.y + bounds.height / 2)
        case .bottomLeft:
            return CGPoint(x: center.x + bounds.width / 2, y: center.y - bounds.height / 2)
        case .bottomRight:
            return CGPoint(x: center.x - bounds.width / 2, y: center.y - bounds.height / 2)
        }
    }

    private func handleResize(from position: SelectionOverlayView.HandlePosition, gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            resizeAnchor = anchorPoint(for: position)
            resizeOriginalSize = bounds.size
            let handleCenter = CGPoint(
                x: center.x + handleOffsetX(for: position),
                y: center.y + handleOffsetY(for: position)
            )
            let vector = CGPoint(x: handleCenter.x - resizeAnchor.x, y: handleCenter.y - resizeAnchor.y)
            resizeStartDistance = hypot(vector.x, vector.y)
        case .changed:
            let fingerLocation = gesture.location(in: superview)
            let vector = CGPoint(x: fingerLocation.x - resizeAnchor.x, y: fingerLocation.y - resizeAnchor.y)
            let currentDistance = hypot(vector.x, vector.y)
            guard resizeStartDistance > 0 else { return }
            let scale = currentDistance / resizeStartDistance
            let newWidth = max(50, resizeOriginalSize.width * scale)
            let newHeight = max(50, resizeOriginalSize.height * scale)

            let signX: CGFloat = (position == .topLeft || position == .bottomLeft) ? -1 : 1
            let signY: CGFloat = (position == .topLeft || position == .topRight) ? -1 : 1

            bounds.size = CGSize(width: newWidth, height: newHeight)
            center = CGPoint(
                x: resizeAnchor.x + signX * newWidth / 2,
                y: resizeAnchor.y + signY * newHeight / 2
            )

            imageView.frame = bounds

            CATransaction.begin()
            CATransaction.setDisableActions(true)
            selectionOverlay?.frame = imageRect
            selectionOverlay?.layoutIfNeeded()
            CATransaction.commit()
        case .ended, .cancelled:
            let newX = Double(center.x - BoardCanvasView.canvasHalf)
            let newY = Double(center.y - BoardCanvasView.canvasHalf)
            let newWidth = Double(bounds.width)
            let newHeight = Double(bounds.height)
            onSizeChanged?(newWidth, newHeight, newX, newY)
        default:
            break
        }
    }

    private func handleOffsetX(for position: SelectionOverlayView.HandlePosition) -> CGFloat {
        switch position {
        case .topLeft, .bottomLeft: return -bounds.width / 2
        case .topRight, .bottomRight: return bounds.width / 2
        }
    }

    private func handleOffsetY(for position: SelectionOverlayView.HandlePosition) -> CGFloat {
        switch position {
        case .topLeft, .topRight: return -bounds.height / 2
        case .bottomLeft, .bottomRight: return bounds.height / 2
        }
    }
}
