//
//  ItemView.swift
//  Reffect
//

import UIKit

final class ItemView: UIView {
    let item: BoardItem
    private let imageView = UIImageView()
    private var selectionOverlay: SelectionOverlayView?

    var onSelect: (() -> Void)?

    var isSelected: Bool = false {
        didSet {
            guard isSelected != oldValue else { return }
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

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }

    private func loadImage() {
        let url = PersistenceManager.shared.imageURL(for: item.imageSource)
        if let image = UIImage(contentsOfFile: url.path) {
            imageView.image = image
        } else {
            imageView.backgroundColor = .systemGray5
        }
    }

    @objc private func handleTap() {
        onSelect?()
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
