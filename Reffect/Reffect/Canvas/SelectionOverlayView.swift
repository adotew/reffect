//
//  SelectionOverlayView.swift
//  Reffect
//

import UIKit

final class SelectionOverlayView: UIView {
    private let borderLayer = CALayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        isUserInteractionEnabled = false
        clipsToBounds = false

        borderLayer.borderColor = UIColor.systemBlue.cgColor
        borderLayer.borderWidth = 2
        layer.addSublayer(borderLayer)

        let handleSize = HandleView.defaultSize
        let positions: [CGPoint] = [
            CGPoint(x: -handleSize / 2, y: -handleSize / 2),
            CGPoint(x: bounds.width - handleSize / 2, y: -handleSize / 2),
            CGPoint(x: -handleSize / 2, y: bounds.height - handleSize / 2),
            CGPoint(x: bounds.width - handleSize / 2, y: bounds.height - handleSize / 2)
        ]

        for position in positions {
            let handle = HandleView(frame: CGRect(origin: position, size: CGSize(width: handleSize, height: handleSize)))
            addSubview(handle)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        borderLayer.frame = bounds

        let handleSize = HandleView.defaultSize
        let positions: [CGPoint] = [
            CGPoint(x: -handleSize / 2, y: -handleSize / 2),
            CGPoint(x: bounds.width - handleSize / 2, y: -handleSize / 2),
            CGPoint(x: -handleSize / 2, y: bounds.height - handleSize / 2),
            CGPoint(x: bounds.width - handleSize / 2, y: bounds.height - handleSize / 2)
        ]

        for (index, handle) in subviews.compactMap({ $0 as? HandleView }).enumerated() {
            guard index < positions.count else { break }
            handle.frame = CGRect(origin: positions[index], size: CGSize(width: handleSize, height: handleSize))
        }
    }
}
