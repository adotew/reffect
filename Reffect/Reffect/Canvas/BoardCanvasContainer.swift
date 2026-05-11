//
//  BoardCanvasContainer.swift
//  Reffect
//

import UIKit

final class BoardCanvasContainer: UIView {
    let scrollView = BoardCanvasView()
    private let gridView = GridView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .systemBackground

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)

        gridView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(gridView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            gridView.topAnchor.constraint(equalTo: topAnchor),
            gridView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gridView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gridView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
