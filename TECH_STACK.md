# Reffect — Tech Stack

## Overview

Reffect is an infinite-canvas moodboard / collage app for iOS. It uses **SwiftUI** for chrome and navigation, **UIKit** (`UIScrollView` + `UIView`) for the infinite canvas, and simple JSON/filesystem persistence.

---

## Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **UI Framework** | SwiftUI | Board list, navigation, modals, toolbars (`BoardListView`, `CanvasView`, `ImageImporter`) |
| **Canvas** | UIKit (`UIScrollView` + `UIView`) | Infinite pan/zoom canvas. Each image is a real `UIView` subclass (`ItemView`) |
| **Image Picker** | `PHPickerViewController` | System photo picker for importing images |
| **Image Processing** | `ImageIO` (`CGImageSourceCreateThumbnailAtIndex`) | Downscales imported images to ~1500px max on a background queue. Memory-efficient streaming decode. |
| **Image Filters** | Core Image (`CIFilter`) | B&W (`CIPhotoEffectNoir`), blur (`CIGaussianBlur`), posterize (`CIColorPosterize`). Metal-backed automatically. |
| **Persistence** | JSON (`JSONEncoder/Decoder`) + Filesystem | `boards.json` stores board metadata; images saved as individual JPEGs in app documents |
| **State Management** | `@Observable` (Observation framework) | `AppStore` is the single source of truth, injected via SwiftUI environment |
| **Language** | Swift | 100% Swift |
| **Min iOS** | 17+ | Required for `@Observable` / Observation framework |

---

## Canvas Architecture

The canvas is a standard UIKit `UIScrollView` with a large `contentView` (7000 × 7000 pts, origin at top-left). The canvas coordinate system is offset by `canvasHalf` (3500) so `(0, 0)` is the visual center.

### Key Components

| Class | Role |
|-------|------|
| `BoardCanvas` | SwiftUI `UIViewRepresentable` bridge |
| `BoardCanvasView` | `UIScrollView` subclass. Handles zoom/pan natively. Hosts rotation gesture. |
| `ItemView` | `UIView` per `BoardItem`. Contains `UIImageView`, `SelectionOverlayView`, and gesture recognizers. |
| `SelectionOverlayView` | Blue border + 4 white resize handles. Scales handle size inversely with zoom. |
| `HandleView` | White square handle with shadow. Each has its own `UIPanGestureRecognizer`. |
| `Coordinator` | Bridges UIKit state back to SwiftUI (`@Binding`, `AppStore`). Debounces viewport saves. |

### Gestures

| Gesture | Target | Action |
|---------|--------|--------|
| **Tap** | `ItemView` | Select item, bring to front |
| **Pan (1 finger)** | `ItemView` | Move item |
| **Pan (on handle)** | `HandleView` | Resize from corner (aspect-locked, rotation-aware) |
| **Two-finger rotate** | `BoardCanvasView` | Rotate selected item |
| **Pinch / Pan (2 finger)** | `UIScrollView` | Zoom and pan the canvas natively |

### Transforms

- **Position**: `center` in `contentView` coordinates
- **Scale / Resize**: `bounds.size` changes
- **Rotation**: `UIView.transform = CGAffineTransform(rotationAngle:)`
- **Flip**: `UIView.transform` with `scaleBy(x: -1, y: 1)`

All transforms are applied to the `ItemView` itself — no manual matrix math.

---

## Memory Management

With 30–60 images per board, the app uses a two-tier strategy:

| Strategy | Implementation |
|----------|----------------|
| **Viewport Culling** | On every scroll/zoom, calculate the visible rect. Offscreen `ItemView`s set `imageView.image = nil`. Onscreen views reload from cache/disk. |
| **Image Cache** | `NSCache` with a cost limit (~50MB) stores decoded `UIImage`s. Purged automatically under memory pressure. Prevents disk thrashing when scrolling. |

This avoids the complexity of full view recycling (`UICollectionView` / cell reuse) while keeping memory usage flat.

---

## Data Model

```
Board
├── id: UUID
├── name: String
├── items: [BoardItem]
├── createdAt: Date
├── lastModified: Date
├── viewportTranslateX: Double?
├── viewportTranslateY: Double?
└── viewportScale: Double?

BoardItem
├── id: UUID
├── imageSource: String  (filename in documents)
├── x, y: Double         (canvas coords, origin at center)
├── width, height: Double
├── scale: Double
├── rotation: Double     (radians)
├── flipHorizontal: Bool
├── isBlackAndWhite: Bool
├── isBlurred: Bool
├── blurRadius: Double
├── isPosterized: Bool
└── posterizationLevels: Double
```

---

## Persistence

- **Boards**: `boards.json` in app documents directory
- **Images**: Individual JPEGs named with `UUID().uuidString + ".jpg"`
- **Writes**: Debounced 0.5s for item moves, 0.8s for viewport changes. Immediate for structural changes (add/delete/reorder board or item).
- **Threading**: JSON encoding and file I/O happen on a background queue (`DispatchQueue.global(qos: .utility)`). Only SwiftUI state updates remain on the main thread.

---

## Why Not Metal?

An earlier version used `MTKView` + custom Metal shaders for rendering images, dot grid, selection borders, and corner handles. While Metal is fast, it was the wrong choice for this app because:

- **Reinventing `UIScrollView`**: Manual viewport transforms, pinch-zoom math, content bounds, and bounce physics.
- **Dual state**: `renderer.items` vs `store.boards.items` caused race conditions during gestures.
- **Manual hit-testing**: ~100 lines of trigonometry to test rotated rects and handle taps. UIKit does this natively.
- **Gesture state machines**: Custom `GestureMode` enum + 4 gesture recognizers with fragile `shouldRecognizeSimultaneouslyWith` logic.

Switching to UIKit eliminated all of those bugs and reduced the canvas code by ~60%.

## Why Not Metal for Filters?

Core Image is the right choice for image filters because:

- **Metal-backed automatically**: `CIFilter` compiles to optimized Metal kernels under the hood on iOS 13+. You get Metal performance without writing Metal code.
- **Standard filters available**: B&W (`CIPhotoEffectNoir`), blur (`CIGaussianBlur`), and posterize (`CIColorPosterize`) are built-in. No custom shader code needed.
- **Chainable**: Apply posterize → B&W → blur in a single `CIImage` pipeline.
- **Works with `UIImageView`**: Set `UIImageView.image = UIImage(ciImage: ...)` or use a `CIImage`-backed `UIImage`. The canvas architecture stays unchanged.
