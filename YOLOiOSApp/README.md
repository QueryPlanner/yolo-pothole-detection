# Pothole Detection iOS App

A focused iOS application that uses a fine-tuned YOLO model to detect potholes in real-time camera feeds.

## Features

- Real-time pothole detection using the fine-tuned `best.mlmodel`
- Live FPS and inference time monitoring
- Adjustable confidence threshold (0.0 - 1.0)
- Adjustable IoU threshold (0.0 - 1.0)
- Share detection results as photos
- Settings panel for threshold adjustment
- Dark mode optimized UI
- Smooth performance on modern iOS devices

## Requirements

- iOS 16.0 or later
- iPhone with camera capability
- Xcode 14.0 or later

## Project Structure

```
YOLOiOSApp/
├── YOLOiOSApp/
│   ├── ViewController.swift         # Main app controller
│   ├── AppDelegate.swift            # App lifecycle management
│   ├── SceneDelegate.swift          # Scene lifecycle management
│   ├── Main.storyboard              # UI layout (simplified for pothole detection)
│   ├── Info.plist                   # App configuration
│   ├── Assets.xcassets/             # Image assets
│   └── DetectModels/
│       └── best.mlmodel             # Fine-tuned pothole detection model
├── YOLOiOSApp.xcodeproj/            # Xcode project configuration
└── README.md                         # This file
```

## Model Details

The app uses a fine-tuned YOLO detection model (`best.mlmodel`) specifically trained to detect potholes. The model:
- Runs efficiently on-device without internet connectivity
- Outputs bounding boxes with confidence scores
- Processes frames in real-time at 30+ FPS on modern devices

## Setup Instructions

### 1. Ensure Model File is Present

Verify that your fine-tuned model is located at:
```
yolo-pothole-detection/YOLOiOSApp/DetectModels/best.mlmodel
```

### 2. Open the Project

```bash
cd yolo-pothole-detection/YOLOiOSApp
open YOLOiOSApp.xcodeproj
```

### 3. Add YOLO Framework

The app depends on the YOLO package located in the parent directory. In Xcode:
1. Select the project → YOLOiOSApp target
2. Go to Build Phases → Link Binary With Libraries
3. Ensure the YOLO framework is linked

Or via Swift Package Manager:
1. File → Add Packages
2. Point to the local `yolo-pothole-detection` package

### 4. Configure Camera Permission

The app requires camera access. Update `Info.plist` with:
```xml
<key>NSCameraUsageDescription</key>
<string>Camera is required to detect potholes in real-time</string>
```

### 5. Build and Run

1. Select the target device or simulator
2. Press Cmd+R to build and run
3. Grant camera permissions when prompted

## Usage

### Real-Time Detection

1. Launch the app
2. Point your device's camera at areas with potential potholes
3. The app displays:
   - **Title:** "Pothole Detection"
   - **Status:** Current FPS and inference time (e.g., "35.2 FPS | 12.5 ms")
   - **Bounding boxes:** Detected potholes with confidence scores

### Adjust Detection Parameters

Tap **Settings** to access:
- **Confidence Threshold:** Increases → fewer false positives, may miss detections
- **IoU Threshold:** Controls overlap suppression between nearby detections
- **Reset to Defaults:** Restores confidence=0.5, IoU=0.45

### Share Results

Tap **Share** to:
1. Capture the current frame with annotations
2. Open iOS share sheet
3. Send to Messages, Email, Photos, or other apps

## Threshold Explanation

- **Confidence (0.0 - 1.0):** Minimum probability for a detection to be considered valid. Higher values = more selective
- **IoU (0.0 - 1.0):** Intersection over Union threshold for non-maximum suppression. Controls duplicate detection removal

### Recommended Settings

- **High Sensitivity:** Confidence=0.3, IoU=0.3 (catches more, may include false positives)
- **Balanced:** Confidence=0.5, IoU=0.45 (default, good for most use cases)
- **High Precision:** Confidence=0.7, IoU=0.6 (filters noise, only confident detections)

## UI Components

### Top Controls
- Model name and status
- Real-time FPS counter (green text)
- Loading indicator

### Bottom Buttons
- **Share:** Capture and export the current frame
- **Settings:** Access threshold adjustment controls

### Camera View
- Full-screen real-time video feed
- Bounding boxes for detected potholes
- Confidence scores on each detection

## Troubleshooting

### Model Not Loading
- Verify `best.mlmodel` exists in `DetectModels/` folder
- Check that the model format is supported (should be `.mlmodel`)
- Review console logs for specific error messages

### No Detections Shown
- Increase confidence slider to ensure model is running (check FPS counter)
- Lower confidence threshold to see all model predictions
- Ensure adequate lighting for the camera

### Poor Performance
- Check FPS counter; should be 20+ FPS
- Reduce model complexity if needed (use a smaller variant)
- Ensure device isn't running other GPU-intensive tasks

### Camera Not Working
- Grant camera permission in Settings → Privacy → Camera
- Try a different device or simulator with camera support

## Performance Optimization

The app is optimized for:
- Efficient on-device inference without cloud processing
- Minimal latency between frame capture and detection
- Low power consumption during continuous operation

For additional optimization:
1. Use a device with Apple Neural Engine (A12 or later)
2. Run in portrait orientation for consistent frame rates
3. Avoid heavy background tasks

## Development Notes

### Key Components

**ViewController.swift:**
- Manages model loading and lifecycle
- Handles camera feed input
- Manages threshold UI controls
- Processes detection results

**Main.storyboard:**
- Defines simplified UI layout
- Connects to outlets for dynamic updates
- Uses AutoLayout for responsive design

### Extending Functionality

To add features:
1. Detection logging → Implement `YOLOViewDelegate` callbacks
2. Multi-model support → Add model selection logic
3. Data export → Implement CSV/JSON logging
4. Network reporting → Add API integration for results

## License

This app uses the Ultralytics YOLO framework under AGPL-3.0 license. For commercial use, obtain appropriate licensing.

## Support

For issues related to:
- YOLO framework → See [Ultralytics YOLO GitHub](https://github.com/ultralytics/yolo-ios-app)
- iOS development → Consult Xcode documentation
- Model training → Reference YOLO documentation

---

**App Version:** 1.0
**YOLO Framework:** iOS compatible version
**Minimum iOS:** 16.0
