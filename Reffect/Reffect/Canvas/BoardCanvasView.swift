//
//  BoardCanvasView.swift
//  Reffect
//

import UIKit

final class BoardCanvasView: UIScrollView {
    static let canvasWidth: CGFloat = 2732
    static let canvasHeight: CGFloat = 2048
    static let canvasHalfX: CGFloat = canvasWidth / 2
    static let canvasHalfY: CGFloat = canvasHeight / 2

    private let contentContainerView = UIView()
    private var didSetInitialOffset = false
    private var isRestoringViewport = false
    private var currentItems: [BoardItem] = []

    var onViewportChange: ((CGPoint, CGFloat) -> Void)?
    var onItemPositionChanged: ((UUID, Double, Double) -> Void)?
    var onItemSizeChanged: ((UUID, Double, Double, Double, Double) -> Void)?
    var onSelectionChanged: ((UUID?) -> Void)?
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
        contentInsetAdjustmentBehavior = .never
        maximumZoomScale = 5.0
        delegate = self

        contentSize = CGSize(width: Self.canvasWidth, height: Self.canvasHeight)

        contentContainerView.frame = CGRect(
            x: 0,
            y: 0,
            width: Self.canvasWidth,
            height: Self.canvasHeight
        )
        addSubview(contentContainerView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        contentContainerView.addGestureRecognizer(tap)
    }

    func setItems(_ items: [BoardItem]) {
        let newIDs = Set(items.map(\.id))
        let currentIDs = Set(currentItems.map(\.id))

        if newIDs == currentIDs {
            // Only properties may have changed; update existing views
            for item in items {
                guard let view = itemView(for: item.id) else { continue }
                view.configure(with: item)
            }
            currentItems = items
            return
        }

        // Remove deleted
        contentContainerView.subviews
            .compactMap { $0 as? ItemView }
            .filter { !newIDs.contains($0.item.id) }
            .forEach { $0.removeFromSuperview() }

        // Update existing and add new
        for item in items {
            if let view = itemView(for: item.id) {
                view.configure(with: item)
            } else {
                let itemView = ItemView(item: item)
                itemView.onPositionChanged = { [weak self] x, y in
                    self?.onItemPositionChanged?(item.id, x, y)
                }
                itemView.onSizeChanged = { [weak self] width, height, x, y in
                    self?.onItemSizeChanged?(item.id, width, height, x, y)
                }
                contentContainerView.addSubview(itemView)
            }
        }

        currentItems = items
        updateSelectionState()
    }

    private func itemView(for id: UUID) -> ItemView? {
        for subview in contentContainerView.subviews {
            if let itemView = subview as? ItemView, itemView.item.id == id {
                return itemView
            }
        }
        return nil
    }

    private func updateSelectionState() {
        for subview in contentContainerView.subviews {
            guard let itemView = subview as? ItemView else { continue }
            let isItemSelected = (itemView.item.id == selectedItemID)
            itemView.isSelected = isItemSelected
        }
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: contentContainerView)

        if let tappedItemView = itemView(at: point) {
            selectedItemID = tappedItemView.item.id
        } else {
            selectedItemID = nil
        }
        onSelectionChanged?(selectedItemID)
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

        guard bounds.width > 0, bounds.height > 0 else { return }

        let minScale = min(
            bounds.width / contentSize.width,
            bounds.height / contentSize.height
        )
        minimumZoomScale = minScale

        guard !didSetInitialOffset else {
            updateContentInset()
            return
        }

        isRestoringViewport = true
        defer { isRestoringViewport = false }

        if let viewport = initialViewport {
            zoomScale = CGFloat(viewport.scale)
            contentOffset = CGPoint(
                x: CGFloat(viewport.translateX), y: CGFloat(viewport.translateY))
        } else {
            let offsetX = (Self.canvasWidth - bounds.width) / 2
            let offsetY = (Self.canvasHeight - bounds.height) / 2
            contentOffset = CGPoint(x: max(0, offsetX), y: max(0, offsetY))
        }
        didSetInitialOffset = true
        updateContentInset()
    }

    private func updateContentInset() {
        let boundsSize = bounds.size
        let contentFrame = contentContainerView.frame

        var inset = UIEdgeInsets.zero

        let deltaX = boundsSize.width - contentFrame.size.width
        if deltaX > 0.5 {
            inset.left = deltaX / 2
            inset.right = deltaX / 2
        }

        let deltaY = boundsSize.height - contentFrame.size.height
        if deltaY > 0.5 {
            inset.top = deltaY / 2
            inset.bottom = deltaY / 2
        }

        contentInset = inset
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
        updateContentInset()
        notifyViewportChange()
    }

    private func notifyViewportChange() {
        onViewportChange?(contentOffset, zoomScale)
    }
}
