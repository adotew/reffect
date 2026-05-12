//
//  GridView.swift
//  Reffect
//

import UIKit

final class GridView: UIView {
    static let spacing: CGFloat = 36
    static let dotRadius: CGFloat = 1.5

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        UIColor.systemGray3.setFill()

        let startX = floor(rect.minX / Self.spacing) * Self.spacing
        let startY = floor(rect.minY / Self.spacing) * Self.spacing

        var y = startY
        while y < rect.maxY {
            var x = startX
            while x < rect.maxX {
                let dotRect = CGRect(
                    x: x - Self.dotRadius,
                    y: y - Self.dotRadius,
                    width: Self.dotRadius * 2,
                    height: Self.dotRadius * 2
                )
                context.fillEllipse(in: dotRect)
                x += Self.spacing
            }
            y += Self.spacing
        }
    }
}
