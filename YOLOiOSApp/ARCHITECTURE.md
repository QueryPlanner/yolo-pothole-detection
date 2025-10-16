# Pothole Detection App - Architecture

## Design Philosophy

This app is built with **maximum clarity and minimal cognitive load** as the primary goal. Every design decision prioritizes developer understanding over architectural sophistication.

### Core Principles

1. **Explicit Over Clever** - Code is written for human reading, not to impress
2. **Local Over Distributed** - All processing happens on-device, no network calls
3. **Focused Over General** - Built specifically for pothole detection, not a generic detection framework
4. **Real-Time Over Batch** - Live camera feed processing with immediate visual feedback

## Application Structure

```
┌─────────────────────────────────────────────────────┐
│              iOS Application Layer                   │
│                                                       │
│  ViewController (Camera Management & UI Events)     │
│         ↓                                             │
│  Main.storyboard (UI Layout & Constraints)          │
│         ↓                                             │
│  AppDelegate/SceneDelegate (Lifecycle)              │
└─────────────────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────────────────┐
│         YOLO Framework Layer (Package)               │
│                                                       │
│  YOLO (Model Loading & Inference)                   │
│    ├── ObjectDetector (Detection-specific logic)    │
│    ├── BasePredictor (Common predictor interface)   │
│    ├── YOLOView (Camera + Visualization)            │
│    ├── YOLOResult (Detection output format)         │
│    └── Box (Individual detection structure)         │
└─────────────────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────────────────┐
│       Apple System Frameworks                        │
│                                                       │
│  AVFoundation (Camera Management)                   │
│  Vision (ML Model Inference)                        │
│  CoreML (Model Format & Compilation)                │
│  UIKit (UI Components)                              │
└─────────────────────────────────────────────────────┘
```

## Data Flow

### 1. Initialization
```
App Launch
    ↓
AppDelegate/SceneDelegate
    ↓
ViewController.viewDidLoad()
    ↓
setupUI() → Create labels, buttons, sliders
    ↓
loadPotholeDetectionModel() → Load best.mlmodel from DetectModels
    ↓
YOLOView initializes camera feed
    ↓
Model ready, FPS counter shows "Ready"
```

### 2. Detection Loop
```
Camera Frame Captured (30 FPS typical)
    ↓
YOLOView sends to YOLO inference
    ↓
YOLO.callAsFunction(image) → ObjectDetector processes
    ↓
Vision Framework executes CoreML model
    ↓
Extract bounding boxes with confidence scores
    ↓
Apply confidence threshold (default: 0.5)
    ↓
Apply IoU threshold for duplicate suppression (default: 0.45)
    ↓
Return YOLOResult with boxes array
    ↓
YOLOView renders boxes with colors
    ↓
ViewController updates FPS label
    ↓
Frame displayed on screen
```

### 3. User Interaction
```
User adjusts Confidence slider
    ↓
thresholdChanged() called
    ↓
YOLO.setConfidenceThreshold(value)
    ↓
ObjectDetector updates internal threshold
    ↓
Next frame uses new threshold
    ↓
Detection results immediately reflect change
```

## Key Components

### ViewController.swift

**Responsibility:** Orchestrate app lifecycle, UI management, user input handling

**Main Functions:**
- `viewDidLoad()` - Initialize all UI and load model
- `setupUI()` - Configure labels, buttons, threshold controls
- `setupThresholdControls()` - Create and layout slider controls
- `loadPotholeDetectionModel()` - Load best.mlmodel from bundle
- `shareButtonTapped()` - Capture and share current frame
- `settingsButtonTapped()` - Show settings menu
- `resetThresholds()` - Return to default values

**Constants:**
```swift
static let modelFileName = "best"
static let defaultConfidenceThreshold = 0.5
static let defaultIouThreshold = 0.45
```

### Main.storyboard

**Structure:**
- Root view: Black background
- YOLOView: Full-screen camera feed
- Top controls: Title, FPS, loading spinner (centered)
- Bottom buttons: Share and Settings (equal width, side by side)

**Layout Strategy:**
- YOLOView fills entire screen (camera feed underneath UI)
- Top controls fixed at top (60pt from top)
- Bottom buttons fixed at bottom (44pt)
- All margins: 16-20pt for visual consistency

### YOLO Framework (External Package)

**Used Classes:**
- `YOLO` - Main inference class
  - `.init(modelPathOrName:task:completion:)` - Load model
  - `callAsFunction(UIImage)` - Run inference
  - `setConfidenceThreshold()` - Update threshold
  - `setIouThreshold()` - Update IoU threshold

- `YOLOView` - Camera + visualization
  - `.yolo` - Reference to YOLO instance
  - `.delegate` - Callbacks for results
  - `setModel()` - Set model and task
  - `capturePhoto()` - Save current frame

- `YOLOResult` - Inference output
  - `.boxes` - Array of Box objects
  - `.fps` - Frames per second
  - `.speed` - Inference time in seconds

- `Box` - Individual detection
  - `.cls` - Class label (pothole/not-pothole)
  - `.conf` - Confidence score (0-1)
  - `.xywh` - Bounding box in image coordinates

## State Management

### Model State
```
State: Not Loaded
    ↓ loadPotholeDetectionModel()
State: Loading
    ↓ completion
State: Ready → Can accept frames
```

### Threshold State
```
confidenceSlider → Double (0.0-1.0)
    ↓
setConfidenceThreshold()
    ↓
ObjectDetector.confidenceThreshold = value
    ↓
Next frame filtered by new threshold
```

## Error Handling Strategy

### Model Loading Errors
```swift
if let modelURL = Bundle.main.url(forResource: "best", ...) {
    // Model found, attempt load
} else {
    // Model not found
    labelFPS.text = "Model not found"
    print("❌ Model file not found in bundle")
}
```

**User-Facing Result:** Error message in FPS label

### Model Load Failure
```swift
case .failure(let error):
    labelFPS.text = "Error loading model"
    print("❌ Failed to load model: \(error)")
```

**User-Facing Result:** Error message, activity stops

### Threshold Out of Range
```swift
guard (0.0...1.0).contains(value) else {
    print("Warning: Threshold should be between 0.0 and 1.0")
    return
}
```

**User-Facing Result:** Silently ignored (slider constrained 0-1)

## Performance Considerations

### Frame Processing
- Runs on background thread (YOLOView handles threading)
- Vision framework batches GPU execution
- Results delivered asynchronously via delegate

### Memory Usage
- Single YOLO instance held in YOLOView
- UIImage cached during capture only
- No frame buffering or history

### Latency
- Model inference: ~12-30ms (device dependent)
- Threshold application: <1ms
- UI update: Next screen refresh (16ms @ 60fps)

## Extension Points

### To Add Logging
In `yoloView(_:didReceiveResult:)` delegate:
```swift
func yoloView(_ view: YOLOView, didReceiveResult result: YOLOResult) {
    // Log detection results
    for box in result.boxes {
        print("Pothole at (\(box.xywh)) - Confidence: \(box.conf)")
    }
}
```

### To Add CSV Export
In `shareButtonTapped()`:
```swift
let csvLine = "\(Date()),\(box.xywh),\(box.conf)\n"
// Write to file
```

### To Add Multiple Models
Add to setupUI():
```swift
let modelPicker = UISegmentedControl()
modelPicker.addTarget(self, action: #selector(modelChanged), 
                      for: .valueChanged)
```

### To Add Confidence Persistence
In `resetThresholds()`:
```swift
UserDefaults.standard.set(value, forKey: "confidenceThreshold")
```

## Testing Strategy

### Unit Tests (Model Loading)
```swift
func testModelLoads() {
    // Verify best.mlmodel loads successfully
}
```

### Integration Tests (Detection)
```swift
func testDetectionOnTestImage() {
    // Load test image, verify results
}
```

### UI Tests
```swift
func testThresholdSliderAdjustment() {
    // Move slider, verify detection count changes
}
```

## Code Quality Standards

### Naming Convention
- Variables: Descriptive (not abbreviated)
- Functions: Verb starting (load, setup, update)
- Constants: UPPER_CASE or CamelCase (enum cases)
- Guard clauses: No early return without reason

### Function Size
- Target: < 20 lines per function
- Max: 40 lines (with permission)
- If longer: Extract helper function

### Cyclomatic Complexity
- Target: < 5 branches per function
- Achieved through guard clauses and early returns

### Comments
- Explain "why", not "what"
- Code should be self-documenting
- Comments for non-obvious business logic

## Security Considerations

### Camera Access
- User grants permission before use
- Permission persists (Settings → Privacy → Camera)
- App cannot bypass iOS permission system

### Model Access
- Model bundled in app (no download)
- No network calls for inference
- Results never transmitted without user action (Share button)

### Data Retention
- Frames processed in real-time only
- Photos saved only when user explicitly shares
- No logging to disk by default

---

**Architecture Principle:** Keep it simple enough to understand in 10 minutes, powerful enough to solve the problem.
