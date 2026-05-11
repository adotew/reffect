# Reffect — Agent Notes

iOS infinite-canvas moodboard app. Xcode project nested at `Reffect/Reffect.xcodeproj`; source lives under `Reffect/Reffect/`.

## Build & Test

- **No package managers** — no SPM, CocoaPods, or Carthage dependencies.
- Build from CLI (example):
  ```bash
  xcodebuild -project Reffect/Reffect.xcodeproj -scheme Reffect -destination 'platform=iOS Simulator,name=iPhone 16'
  ```
- Run tests (uses **Swift Testing**, not XCTest):
  ```bash
  xcodebuild test -project Reffect/Reffect.xcodeproj -scheme Reffect -destination 'platform=iOS Simulator,name=iPhone 16'
  ```
- No shared `.xcscheme` files; scheme name matches the target (`Reffect`).

## Project Settings

- **Language**: Swift 5.0
- **Deployment target**: `IPHONEOS_DEPLOYMENT_TARGET = 26.4` (build config); `TECH_STACK.md` claims iOS 17+ but trust the project file.
- **Concurrency**: `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` and `SWIFT_APPROACHABLE_CONCURRENCY = YES` are enabled.
- **Build scripts sandboxing**: `ENABLE_USER_SCRIPT_SANDBOXING = YES`.

## Architecture

- **UI**: SwiftUI for navigation and chrome; planned UIKit canvas (`UIScrollView` + `UIView`) per `TECH_STACK.md`.
- **Entry point**: `ReffectApp.swift` → `BoardListView()` with `@Observable AppStore` injected via `.environment(store)`.
- **State**: `AppStore` is the single source of truth. It loads boards synchronously in `init` and fires saves in unstructured `Task { try? await ... }`.
- **Persistence**: `PersistenceManager` (an **actor**). `boards.json` in documents; images as JPEGs in `images/` subdirectory.
  - Call `PersistenceManager` methods with `await`.
  - `loadBoards()` is `nonisolated`; `saveBoards(_:)` is isolated.
- **Canvas status**: `CanvasView.swift` is a **placeholder**. `Canvas/` and `Utils/` directories exist but are empty. `TODO.md` shows Steps 1–3 done, Steps 4–14 not yet implemented.

## Code Conventions

- Group files by layer: `Models/`, `Store/`, `Views/`, `Canvas/`, `Utils/`.
- Standard Xcode file headers are used.
- No linter/formatter config found (e.g., no `.swiftlint.yml`, no `swift-format`).
- Prefer readable and maintainable code over clever one-liners or premature optimization.

## Docs & Plans

- `TECH_STACK.md` — architecture decisions (e.g., why UIKit over Metal for canvas, Core Image for filters).
- `TODO.md` — phased roadmap; many features are design-only at this stage.

## Warnings

- `AppStore.saveBoards()` uses `Task { try? await ... }` and silently ignores errors.
- `PersistenceManager.loadBoards()` prints and returns `[]` on any decode failure.
- `Canvas/` and `Utils/` are reserved for upcoming UIKit canvas code; do not place SwiftUI views there unless intentional.
