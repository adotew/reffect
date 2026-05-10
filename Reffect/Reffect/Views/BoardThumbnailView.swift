//
//  BoardThumbnailView.swift
//  Reffect
//

import SwiftUI

struct BoardThumbnailView: View {
    let board: Board

    private var gradientColors: [Color] {
        let colors: [Color] = [.blue, .purple, .pink, .orange, .green, .teal, .indigo, .red]
        let hash = abs(board.id.uuidString.hashValue)
        let start = colors[hash % colors.count]
        let end = colors[(hash + 3) % colors.count]
        return [start, end]
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: gradientColors),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                    .overlay(
                        Group {
                            if board.items.isEmpty {
                                Image(systemName: "square.grid.2x2")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.white.opacity(0.6))
                            } else {
                                Text("\(board.items.count)")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                    )
            }

            Text(board.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)
                .foregroundStyle(.primary)
        }
        .frame(width: 140)
    }
}

#Preview {
    BoardThumbnailView(board: Board(name: "Moodboard"))
}
