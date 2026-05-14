//
//  ImageToolbar.swift
//  Reffect
//

import SwiftUI

struct ImageToolbar: View {
    let item: BoardItem?
    let onFlip: () -> Void
    let onToggleBW: () -> Void
    let onToggleBlur: () -> Void
    let onSetBlurRadius: (Double) -> Void
    let onTogglePosterize: () -> Void
    let onSetPosterizationLevels: (Double) -> Void
    let onDuplicate: () -> Void
    let onDelete: () -> Void

    @State private var adjustment: Adjustment?

    private enum Adjustment {
        case blur
        case posterize
    }

    var body: some View {
        HStack(spacing: adjustment == nil ? 24 : 12) {
            if let adjustment = adjustment {
                adjustmentContent(for: adjustment)
            } else {
                normalContent
            }
        }
        .frame(width: 320)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        .onChange(of: item?.id) { _, _ in
            self.adjustment = nil
        }
    }

    @ViewBuilder
    private var normalContent: some View {
        ToolbarButton(
            icon: "arrow.left.arrow.right",
            isActive: item?.flipHorizontal ?? false,
            action: onFlip
        )

        ToolbarButton(
            icon: "circle.righthalf.filled",
            isActive: item?.isBlackAndWhite ?? false,
            action: onToggleBW
        )

        EffectButton(
            icon: "drop.fill",
            isActive: item?.isBlurred ?? false,
            onTap: onToggleBlur,
            onLongPress: {
                if item?.isBlurred != true {
                    onToggleBlur()
                }
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.adjustment = .blur
                }
            }
        )

        EffectButton(
            icon: "camera.filters",
            isActive: item?.isPosterized ?? false,
            onTap: onTogglePosterize,
            onLongPress: {
                if item?.isPosterized != true {
                    onTogglePosterize()
                }
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.adjustment = .posterize
                }
            }
        )

        Menu {
            Button {
                onDuplicate()
            } label: {
                Label("Duplicate", systemImage: "doc.on.doc")
            }

            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
                .rotationEffect(.degrees(90))
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
    }

    @ViewBuilder
    private func adjustmentContent(for adjustment: Adjustment) -> some View {
        switch adjustment {
        case .blur:
            Slider(value: blurBinding, in: 0...20, step: 1)
                .tint(.white)
            Text("\(Int(item?.blurRadius ?? 0))")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .monospacedDigit()
                .frame(minWidth: 24)

        case .posterize:
            Slider(value: posterizeSliderBinding, in: 2...32, step: 1)
                .tint(.white)
            Text("\(Int(item?.posterizationLevels ?? 0))")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .monospacedDigit()
                .frame(minWidth: 24)
        }

        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                self.adjustment = nil
            }
        } label: {
            Image(systemName: "checkmark")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(Color.white.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }

    private var blurBinding: Binding<Double> {
        Binding(
            get: { item?.blurRadius ?? 5 },
            set: { onSetBlurRadius($0) }
        )
    }

    private var posterizeSliderBinding: Binding<Double> {
        Binding(
            get: { 34 - (item?.posterizationLevels ?? 4) },
            set: { onSetPosterizationLevels(34 - $0) }
        )
    }
}

private struct ToolbarButton: View {
    let icon: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(isActive ? .white : .primary)
                .frame(width: 44, height: 44)
                .background(isActive ? Color.white.opacity(0.10) : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}

private struct EffectButton: View {
    let icon: String
    let isActive: Bool
    let onTap: () -> Void
    let onLongPress: () -> Void

    @State private var didLongPress = false

    var body: some View {
        Button {
            if !didLongPress {
                onTap()
            }
            didLongPress = false
        } label: {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(isActive ? .white : .primary)
                .frame(width: 44, height: 44)
                .background(isActive ? Color.white.opacity(0.10) : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5)
                .onEnded { _ in
                    didLongPress = true
                    onLongPress()
                }
        )
    }
}

struct ImageToolbar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            ImageToolbar(
                item: BoardItem(imageSource: "test.jpg"),
                onFlip: {},
                onToggleBW: {},
                onToggleBlur: {},
                onSetBlurRadius: { _ in },
                onTogglePosterize: {},
                onSetPosterizationLevels: { _ in },
                onDuplicate: {},
                onDelete: {}
            )
            .padding(.bottom, 32)
        }
    }
}
