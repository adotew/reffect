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
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = UIColor(patternImage: makeTile())
        isUserInteractionEnabled = false
    }

    private func makeTile() -> UIImage {
        let size = CGSize(width: Self.spacing, height: Self.spacing)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.systemGray3.setFill()
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let dotRect = CGRect(
                x: center.x - Self.dotRadius,
                y: center.y - Self.dotRadius,
                width: Self.dotRadius * 2,
                height: Self.dotRadius * 2
            )
            context.cgContext.fillEllipse(in: dotRect)
        }
    }
}
