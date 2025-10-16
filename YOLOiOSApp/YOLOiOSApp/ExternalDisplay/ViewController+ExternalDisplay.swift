// Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

// MARK: - OPTIONAL External Display Support
// This extension provides optional external display functionality for the YOLO iOS app.
// It enhances the user experience when connected to an external monitor or TV but is
// NOT required for the core app functionality. The features remain dormant until
// an external display is connected.
//
// Features handled in this extension:
// - External display connection/disconnection detection
// - UI adjustments for external display mode:
//   * Hide switch camera and share buttons (not supported in external display mode)
//   * Adjust model dropdown positioning to prevent overlap
//   * Force landscape orientation for better external display experience
// - Model and threshold synchronization with external display
// - Camera session management (stop iPhone camera when external display is active)

import UIKit
import YOLO

// MARK: - External Display Support
extension ViewController {

  // Associated object key for tracking external display state
  private struct AssociatedKeys {
    static var isExternalDisplayConnected = "isExternalDisplayConnected"
  }

  private var isExternalDisplayConnected: Bool {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.isExternalDisplayConnected) as? Bool
        ?? false
    }
    set {
      objc_setAssociatedObject(
        self, &AssociatedKeys.isExternalDisplayConnected, newValue,
        .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  func setupExternalDisplayNotifications() {
    // External display support is optional and not required for pothole detection app
    print("External display support disabled for pothole detection app")
  }

  @objc func handleExternalDisplayConnected(_ notification: Notification) {
    // External display support disabled
    DispatchQueue.main.async {
      self.showExternalDisplayStatus()
    }
  }

  private func requestLandscapeOrientation() {
    guard let windowScene = view.window?.windowScene else { return }

    if #available(iOS 16.0, *) {
      windowScene.requestGeometryUpdate(
        .iOS(interfaceOrientations: [.landscapeLeft, .landscapeRight]))
    } else {
      UIViewController.attemptRotationToDeviceOrientation()
    }
  }

  @objc private func updateNumItemsLabelForExternalDisplay() {
    // Not applicable for pothole detection app
  }

  @objc private func handleDetectionCountUpdate(_ notification: Notification) {
    // External display support disabled
  }

  func notifyExternalDisplayOfCurrentModel() {
    // External display support disabled
  }

  @objc func handleExternalDisplayDisconnected(_ notification: Notification) {
    DispatchQueue.main.async {
      self.isExternalDisplayConnected = false
      self.yoloView.isHidden = false
      self.hideExternalDisplayStatus()
    }
  }

  private func requestPortraitOrientation() {
    guard let windowScene = view.window?.windowScene else { return }

    if #available(iOS 16.0, *) {
      windowScene.requestGeometryUpdate(
        .iOS(interfaceOrientations: [.portrait, .landscapeLeft, .landscapeRight]))
      setNeedsUpdateOfSupportedInterfaceOrientations()

      if UIDevice.current.orientation.isLandscape {
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
      }
    } else {
      UIViewController.attemptRotationToDeviceOrientation()

      if UIDevice.current.orientation.isLandscape {
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
      }
    }
  }

  func adjustLayoutForExternalDisplayIfNeeded() {
    // External display support disabled for pothole detection app
  }

  @objc func handleExternalDisplayReady(_ notification: Notification) {
    // External display support disabled
  }

  func checkAndNotifyExternalDisplayIfReady() {
    // External display support disabled
  }

  func checkForExternalDisplays() {
    // External display support disabled
  }

  func showExternalDisplayStatus() {
    let statusLabel = UILabel()
    statusLabel.text = "Pothole Detection App\nExternal Display Mode"
    statusLabel.textColor = .white
    statusLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    statusLabel.textAlignment = .center
    statusLabel.font = .systemFont(ofSize: 18, weight: .medium)
    statusLabel.numberOfLines = 0
    statusLabel.adjustsFontSizeToFitWidth = true
    statusLabel.minimumScaleFactor = 0.8
    statusLabel.layer.cornerRadius = 10
    statusLabel.layer.masksToBounds = true
    statusLabel.tag = 9999

    view.addSubview(statusLabel)

    statusLabel.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      statusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      statusLabel.widthAnchor.constraint(equalToConstant: 280),
      statusLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
    ])
  }

  func hideExternalDisplayStatus() {
    view.subviews.first(where: { $0.tag == 9999 })?.removeFromSuperview()
  }
}
