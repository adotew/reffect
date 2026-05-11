//
//  ImageToolbar.swift
//  Reffect
//

import SwiftUI

struct ImageToolbar: View {
    let item: BoardItem?
    let onFlip: () -> Void
    let onToggleBW: () -> Void
    let onDuplicate: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 24) {
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
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
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
                .background(isActive ? Color.accentColor : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack {
        Spacer()
        ImageToolbar(
            item: BoardItem(imageSource: "test.jpg"),
            onFlip: {},
            onToggleBW: {},
            onDuplicate: {},
            onDelete: {}
        )
        .padding(.bottom, 32)
    }
}
