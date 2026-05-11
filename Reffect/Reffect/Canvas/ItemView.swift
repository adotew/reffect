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

    var onPositionChanged: ((Double, Double) -> Void)?

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

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4

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

    private func showSelectionOverlay() {
        guard selectionOverlay == nil else { return }
        let overlay = SelectionOverlayView(frame: bounds)
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(overlay)
        selectionOverlay = overlay
    }

    private func hideSelectionOverlay() {
        selectionOverlay?.removeFromSuperview()
        selectionOverlay = nil
    }
}
