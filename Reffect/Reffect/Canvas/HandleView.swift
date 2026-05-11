//
//  HandleView.swift
//  Reffect
//

import UIKit

final class HandleView: UIView {
    static let defaultSize: CGFloat = 12

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .white
        layer.cornerRadius = 1
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 2
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let hitTestInset: CGFloat = 26
        let hitRect = bounds.insetBy(dx: -hitTestInset, dy: -hitTestInset)
        return hitRect.contains(point)
    }
}
