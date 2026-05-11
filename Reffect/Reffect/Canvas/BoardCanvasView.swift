//
//  BoardCanvasView.swift
//  Reffect
//

import UIKit

final class BoardCanvasView: UIScrollView {
    static let canvasSize: CGFloat = 7000
    static let canvasHalf: CGFloat = 3500

    private let contentContainerView = UIView()
    private var didSetInitialOffset = false
    private var isRestoringViewport = false
    private var currentItems: [BoardItem] = []
    private var panStartCenter: CGPoint = .zero

    var onViewportChange: ((CGPoint, CGFloat) -> Void)?
    var onItemPositionChanged: ((UUID, Double, Double) -> Void)?
    var initialViewport: (translateX: Double, translateY: Double, scale: Double)?

    var selectedItemID: UUID? {
        didSet {
            guard selectedItemID != oldValue else { return }
            updateSelectionState()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCanvas()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCanvas()
    }

    private func setupCanvas() {
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        bounces = true
        alwaysBounceVertical = true
        alwaysBounceHorizontal = true
        minimumZoomScale = 0.1
        maximumZoomScale = 5.0
        delegate = self

        contentSize = CGSize(width: Self.canvasSize, height: Self.canvasSize)

        contentContainerView.frame = CGRect(
            x: 0,
            y: 0,
            width: Self.canvasSize,
            height: Self.canvasSize
        )
        addSubview(contentContainerView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        contentContainerView.addGestureRecognizer(tap)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        pan.delegate = self
        contentContainerView.addGestureRecognizer(pan)
    }

    func setItems(_ items: [BoardItem]) {
        let newIDs = Set(items.map(\.id))
        let currentIDs = Set(currentItems.map(\.id))

        guard newIDs != currentIDs else { return }

        contentContainerView.subviews
            .compactMap { $0 as? ItemView }
            .forEach { $0.removeFromSuperview() }

        for item in items {
            let itemView = ItemView(item: item)
            contentContainerView.addSubview(itemView)
        }

        currentItems = items
        updateSelectionState()
    }

    private func updateSelectionState() {
        for subview in contentContainerView.subviews {
            guard let itemView = subview as? ItemView else { continue }
            itemView.isSelected = (itemView.item.id == selectedItemID)
        }
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: contentContainerView)

        if let tappedItemView = itemView(at: point) {
            selectedItemID = tappedItemView.item.id
        } else {
            selectedItemID = nil
        }
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let selectedID = selectedItemID,
              let itemView = contentContainerView.subviews
                  .compactMap({ $0 as? ItemView })
                  .first(where: { $0.item.id == selectedID }) else { return }

        switch gesture.state {
        case .began:
            panStartCenter = itemView.center
        case .changed:
            let translation = gesture.translation(in: contentContainerView)
            itemView.center = CGPoint(
                x: panStartCenter.x + translation.x,
                y: panStartCenter.y + translation.y
            )
        case .ended, .cancelled:
            let newX = Double(itemView.center.x - Self.canvasHalf)
            let newY = Double(itemView.center.y - Self.canvasHalf)
            onItemPositionChanged?(selectedID, newX, newY)
        default:
            break
        }
    }

    private func itemView(at point: CGPoint) -> ItemView? {
        for subview in contentContainerView.subviews.reversed() {
            guard let itemView = subview as? ItemView else { continue }
            if itemView.frame.contains(point) {
                return itemView
            }
        }
        return nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard bounds.width > 0, bounds.height > 0, !didSetInitialOffset else { return }

        isRestoringViewport = true
        defer { isRestoringViewport = false }

        if let viewport = initialViewport {
            zoomScale = CGFloat(viewport.scale)
            contentOffset = CGPoint(x: CGFloat(viewport.translateX), y: CGFloat(viewport.translateY))
        } else {
            let offsetX = (Self.canvasSize - bounds.width) / 2
            let offsetY = (Self.canvasSize - bounds.height) / 2
            contentOffset = CGPoint(x: max(0, offsetX), y: max(0, offsetY))
        }
        didSetInitialOffset = true
    }
}

extension BoardCanvasView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        contentContainerView
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isRestoringViewport else { return }
        notifyViewportChange()
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        guard !isRestoringViewport else { return }
        notifyViewportChange()
    }

    private func notifyViewportChange() {
        onViewportChange?(contentOffset, zoomScale)
    }
}

extension BoardCanvasView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer is UIPanGestureRecognizer {
            return selectedItemID != nil
        }
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
