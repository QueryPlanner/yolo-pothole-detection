# Pothole Detection App - Quick Start Guide

## What You Have

✅ Fine-tuned YOLO model: `DetectModels/best.mlmodel`  
✅ Simplified iOS app targeting pothole detection  
✅ Clean, production-ready interface  

## Quick Setup (5 minutes)

### Step 1: Open Xcode
```bash
cd yolo-pothole-detection/YOLOiOSApp
open YOLOiOSApp.xcodeproj
```

### Step 2: Configure Build
1. Select the YOLOiOSApp target
2. Go to **Build Settings** → Search "SKIP_MODEL_TESTS"
3. Set to `true` (if it appears)
4. Ensure iOS Deployment Target is 16.0 or later

### Step 3: Link Dependencies
1. Select target → **Build Phases** → **Link Binary With Libraries**
2. Ensure the YOLO framework from the parent package is linked
3. If not present, add it via: File → Add Packages (point to parent directory)

### Step 4: Run
- Select iPhone device/simulator (iOS 16+)
- Press **Cmd+R** or click Run button
- Grant camera permission when prompted

## App Features

| Feature | Status |
|---------|--------|
| Real-time detection | ✅ |
| FPS monitoring | ✅ |
| Confidence threshold slider | ✅ |
| IoU threshold slider | ✅ |
| Share results | ✅ |
| Settings panel | ✅ |

## Verification

### Model Loads Successfully
- App shows "Ready" in green
- FPS counter updates (e.g., "35.2 FPS | 12.5 ms")

### Detection Works
- Point camera at road/surface
- Green boxes appear over detected potholes
- Each box shows confidence score (0-1)

### Threshold Controls
- Tap Settings
- Adjust Confidence and IoU sliders
- Detections update in real-time

## File Structure

```
DetectModels/
└── best.mlmodel           ← Your fine-tuned model

YOLOiOSApp/
├── ViewController.swift   ← App logic (clean & simple)
├── Main.storyboard        ← UI layout (minimal)
├── AppDelegate.swift      ← Lifecycle
├── SceneDelegate.swift    ← Scene management
└── README.md              ← Full documentation
```

## Code Organization

### ViewController.swift
- **Constants:** Model filename, default thresholds
- **setupUI():** Initialize all views
- **loadPotholeDetectionModel():** Load best.mlmodel
- **Threshold controls:** Confidence & IoU sliders
- **Share & Settings:** Button handlers

### Key Classes
- `YOLO` - Main inference engine
- `YOLOView` - Camera + visualization
- `YOLOResult` - Detection results structure
- `Box` - Individual detection with coordinates

## Common Issues

| Issue | Solution |
|-------|----------|
| "Model not found" | Verify `best.mlmodel` in DetectModels folder |
| No detections | Lower confidence threshold to 0.3 |
| Slow performance | Check FPS counter; should be 20+ |
| Camera permission denied | Grant in Settings → Privacy → Camera |

## Next Steps

### To Extend:
1. **Logging results** → Implement `YOLOViewDelegate` callbacks
2. **Export data** → Add timestamp + CSV export in button handler
3. **Multiple models** → Add model selector
4. **Custom classes** → Update model-specific strings

### To Optimize:
1. Use quantized models (INT8)
2. Reduce input resolution if needed
3. Run on A12+ devices with Neural Engine
4. Test on actual hardware (simulator slower)

## Development Philosophy

This app prioritizes **clarity and simplicity**:
- ✅ Readable variable names
- ✅ Single responsibility per function
- ✅ No unnecessary abstraction
- ✅ Clear data flow
- ✅ Minimal dependencies

## Support Resources

- YOLO Framework: Check `Sources/YOLO/` in parent directory
- iOS Development: Xcode documentation
- Model Format: CoreML (Apple's machine learning framework)

---

**You're ready to detect potholes!** 🚗
