//
//  ItemView.swift
//  Reffect
//

import UIKit

final class ItemView: UIView {
    let item: BoardItem
    private let imageView = UIImageView()

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
    }

    private func loadImage() {
        let url = PersistenceManager.shared.imageURL(for: item.imageSource)
        if let image = UIImage(contentsOfFile: url.path) {
            imageView.image = image
        } else {
            imageView.backgroundColor = .systemGray5
        }
    }
}
