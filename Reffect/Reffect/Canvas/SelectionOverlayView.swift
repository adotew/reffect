//
//  SelectionOverlayView.swift
//  Reffect
//

import UIKit

final class SelectionOverlayView: UIView {
    enum HandlePosition: Int {
        case topLeft, topRight, bottomLeft, bottomRight
    }

    private let borderLayer = CALayer()
    var onHandlePan: ((HandlePosition, UIPanGestureRecognizer) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        isUserInteractionEnabled = true
        clipsToBounds = false

        borderLayer.borderColor = UIColor.systemBlue.cgColor
        borderLayer.borderWidth = 2
        layer.addSublayer(borderLayer)

        let handleSize = HandleView.defaultSize
        let positions: [(HandlePosition, CGPoint)] = [
            (.topLeft, CGPoint(x: -handleSize / 2, y: -handleSize / 2)),
            (.topRight, CGPoint(x: bounds.width - handleSize / 2, y: -handleSize / 2)),
            (.bottomLeft, CGPoint(x: -handleSize / 2, y: bounds.height - handleSize / 2)),
            (.bottomRight, CGPoint(x: bounds.width - handleSize / 2, y: bounds.height - handleSize / 2))
        ]

        for (position, origin) in positions {
            let handle = HandleView(frame: CGRect(origin: origin, size: CGSize(width: handleSize, height: handleSize)))
            handle.tag = position.rawValue
            let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            handle.addGestureRecognizer(pan)
            addSubview(handle)
        }
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let handle = gesture.view as? HandleView,
              let position = HandlePosition(rawValue: handle.tag) else { return }
        onHandlePan?(position, gesture)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for subview in subviews.reversed() {
            let converted = subview.convert(point, from: self)
            if let hit = subview.hitTest(converted, with: event) {
                return hit
            }
        }
        return nil
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
