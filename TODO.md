# Reffect — TODO

A living document. Tick off steps as they are completed.

---

## Phase 1: Foundation

- [x] **Step 1 — Project Setup**
  - Create Xcode project, folder structure, SwiftUI app entry point, `ContentView`
  - *Test:* App launches, shows "Hello Reffect" or empty list placeholder

- [x] **Step 2 — Data Models & Persistence**
  - `Board`, `BoardItem`, `PersistenceManager`. JSON + filesystem. Image helpers.
  - *Test:* Create a board in memory, save, kill app, relaunch — board loads back

- [x] **Step 3 — AppStore & Board List**
  - `@Observable AppStore`, inject via environment. `BoardListView`: create, rename (long-press), delete (long-press) boards.
  - *Test:* Create 3 boards, rename one, delete one, relaunch — state persists

---

## Phase 2: Canvas Shell

- [x] **Step 4 — Empty Infinite Canvas**
  - `BoardCanvas` (UIViewRepresentable), `BoardCanvasView` (UIScrollView). 7000×7000 content view, centered origin. Pinch zoom + pan.
  - *Test:* Tap a board → canvas opens. Can pinch zoom and pan freely

- [x] **Step 5 — Viewport Persistence**
  - Save/restore `contentOffset` and `zoomScale` per board. Debounced writes.
  - *Test:* Pan/zoom canvas, go back to list, reopen board — viewport restores exactly

---

## Phase 3: Images

- [x] **Step 6 — Image Import**
  - `PHPickerViewController` wrapper. ImageIO downsampling to ~1500px. Save JPEG.
  - *Test:* Import an image → file appears in app documents directory, ≤1500px

- [x] **Step 7 — Place Images on Canvas**
  - `ItemView` with `UIImageView`. Load from disk, position at (0,0). Display on canvas.
  - *Test:* Import image → appears on canvas. Can import multiple, all visible

---

## Phase 4: Interactions

- [x] **Step 8 — Selection**
  - Tap `ItemView` to select (blue border + 4 handles). Tap canvas to deselect. Bring to front.
  - *Test:* Tap image → blue border + handles appear. Tap empty canvas → deselects

- [x] **Step 9 — Move & Delete**
  - Pan `ItemView` to move. Toolbar "..." menu → Delete and Duplicate actions.
  - *Test:* Drag image to new position. Delete via menu → gone. Duplicate → copy appears offset

- [x] **Step 10 — Resize**
  - `HandleView` corners. Pan handle = resize, aspect-locked, rotation-aware. Handle size scales inversely with zoom.
  - *Test:* Drag corner handle → image resizes, aspect ratio preserved

- [x] **Step 11 — Flip**
  - Toolbar flip button.
  - *Test:* Tap flip button → image mirrors horizontally

- [x] **Step 12 — Image Filters (B&W)**
  - Bottom toolbar with toggle button: B&W (desaturation via `CIColorControls`)
  - Blur and Posterize removed from UI — deferred to future step
  - Uses Core Image (`CIFilter`) — Metal-backed automatically
  - *Test:* Tap B&W → image turns grayscale. Filters persist.

---

## Phase 5: Performance & Polish

- [ ] **Step 13 — Memory Management**
  - Viewport culling (nil images offscreen). `NSCache` (~50MB).
  - *Test:* Add 20 images, zoom in on one, scroll far away → memory stays flat (Instruments or sim memory gauge)

- [ ] **Step 14 — Polish**
  - Error handling, empty states, missing image files, performance tuning.
  - *Test:* Delete image file from disk externally → app shows placeholder, doesn't crash. Empty board shows "Add images" hint.
