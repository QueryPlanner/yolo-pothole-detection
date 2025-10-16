// Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

//  This file is part of the Ultralytics YOLO app, providing the main user interface for model selection and visualization.
//  Licensed under AGPL-3.0. For commercial use, refer to Ultralytics licensing: https://ultralytics.com/license
//  Access the source code: https://github.com/ultralytics/yolo-ios-app
//
//  The ViewController serves as the primary interface for users to interact with YOLO models.
//  It provides the ability to select different models, tasks (detection, segmentation, classification, etc.),
//  and visualize results in real-time. The controller manages the loading of local and remote models,
//  handles UI updates during model loading and inference, and provides functionality for capturing
//  and sharing detection results. Advanced features include model download progress
//  tracking, and adaptive UI layout for different device orientations.

import AVFoundation
import AudioToolbox
import CoreML
import CoreMedia
import UIKit
import YOLO

class ViewController: UIViewController, YOLOViewDelegate {

  @IBOutlet weak var yoloView: YOLOView!
  @IBOutlet weak var labelName: UILabel!
  @IBOutlet weak var labelFPS: UILabel!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var shareButton: UIButton!
  @IBOutlet weak var settingsButton: UIButton!

  private let confidenceSlider = UISlider()
  private let iouSlider = UISlider()
  private let thresholdStack = UIStackView()
  
  private var isLoadingModel = false
  private let loadingIndicatorLabel = UILabel()

  private struct Constants {
    static let modelFileName = "best"
    static let defaultConfidenceThreshold = 0.5
    static let defaultIouThreshold = 0.45
    static let shareButtonTitle = "Share"
    static let settingsButtonTitle = "Settings"
  }

  private var yoloModel: YOLO?

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .black
    setupUI()
    loadPotholeDetectionModel()
    setupGestures()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    view.overrideUserInterfaceStyle = .dark
  }

  private func setupUI() {
    setupLabels()
    setupButtons()
    setupThresholdControls()
  }

  private func setupLabels() {
    labelName.text = "Pothole Detection"
    labelName.textColor = .white
    labelName.font = .systemFont(ofSize: 18, weight: .semibold)

    labelFPS.textColor = .systemGreen
    labelFPS.font = .systemFont(ofSize: 14, weight: .regular)
    labelFPS.text = "Initializing..."
  }

  private func setupButtons() {
    shareButton.setTitle(Constants.shareButtonTitle, for: .normal)
    shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
    shareButton.backgroundColor = .systemBlue
    shareButton.layer.cornerRadius = 8

    settingsButton.setTitle(Constants.settingsButtonTitle, for: .normal)
    settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
    settingsButton.backgroundColor = .systemGray
    settingsButton.layer.cornerRadius = 8
  }

  private func setupThresholdControls() {
    thresholdStack.axis = .vertical
    thresholdStack.spacing = 12
    thresholdStack.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(thresholdStack)

    // Confidence threshold control
    let confContainer = createThresholdControlContainer(
      title: "Confidence: 0.50",
      slider: confidenceSlider,
      onValueChanged: { [weak self] value in
        self?.updateConfidenceLabel(value)
        self?.yoloModel?.setConfidenceThreshold(Double(value))
      }
    )
    thresholdStack.addArrangedSubview(confContainer)

    // IoU threshold control
    let iouContainer = createThresholdControlContainer(
      title: "IoU: 0.45",
      slider: iouSlider,
      onValueChanged: { [weak self] value in
        self?.updateIouLabel(value)
        self?.yoloModel?.setIouThreshold(Double(value))
      }
    )
    thresholdStack.addArrangedSubview(iouContainer)

    // Layout thresholdStack at bottom of view
    NSLayoutConstraint.activate([
      thresholdStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      thresholdStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      thresholdStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
    ])
  }

  private func createThresholdControlContainer(
    title: String,
    slider: UISlider,
    onValueChanged: @escaping (Float) -> Void
  ) -> UIView {
    let container = UIView()
    container.backgroundColor = UIColor.white.withAlphaComponent(0.1)
    container.layer.cornerRadius = 8

    let label = UILabel()
    label.text = title
    label.textColor = .white
    label.font = .systemFont(ofSize: 12, weight: .regular)

    slider.minimumValue = 0.0
    slider.maximumValue = 1.0
    slider.value = Float(title.contains("Confidence") ? Constants.defaultConfidenceThreshold : Constants.defaultIouThreshold)
    slider.addTarget(self, action: #selector(thresholdChanged(_:)), for: .valueChanged)

    if title.contains("Confidence") {
      slider.tag = 1
    } else {
      slider.tag = 2
    }

    container.translatesAutoresizingMaskIntoConstraints = false
    label.translatesAutoresizingMaskIntoConstraints = false
    slider.translatesAutoresizingMaskIntoConstraints = false

    container.addSubview(label)
    container.addSubview(slider)

    NSLayoutConstraint.activate([
      label.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
      label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
      label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
      slider.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
      slider.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
      slider.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
      slider.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
      container.heightAnchor.constraint(equalToConstant: 60)
    ])

    return container
  }

  @objc private func thresholdChanged(_ slider: UISlider) {
    if slider.tag == 1 {
      updateConfidenceLabel(slider.value)
      yoloModel?.setConfidenceThreshold(Double(slider.value))
    } else if slider.tag == 2 {
      updateIouLabel(slider.value)
      yoloModel?.setIouThreshold(Double(slider.value))
    }
  }

  private func updateConfidenceLabel(_ value: Float) {
    for case let label as UILabel in thresholdStack.subviews.flatMap({ $0.subviews }) {
      if label.text?.contains("Confidence") == true {
        label.text = String(format: "Confidence: %.2f", value)
        break
      }
    }
  }

  private func updateIouLabel(_ value: Float) {
    for case let label as UILabel in thresholdStack.subviews.flatMap({ $0.subviews }) {
      if label.text?.contains("IoU") == true {
        label.text = String(format: "IoU: %.2f", value)
        break
      }
    }
  }

  private func setupGestures() {
    yoloView.delegate = self
  }

  private func loadPotholeDetectionModel() {
    guard !isLoadingModel else {
      print("Model is already loading.")
      return
    }
    isLoadingModel = true

    activityIndicator.startAnimating()
    labelFPS.text = "Loading model..."

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
      guard let self = self else { return }

      if let modelURL = Bundle.main.url(forResource: Constants.modelFileName, withExtension: "mlmodel", subdirectory: "DetectModels") {
        // Load YOLO model directly to get reference for threshold control
        YOLO(modelURL.path, task: .detect) { [weak self] result in
          guard let self = self else { return }
          DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.isLoadingModel = false

            switch result {
            case .success(let yoloInstance):
              // Store reference for threshold control
              self.yoloModel = yoloInstance
              // Also set model in YOLOView for visualization
              self.yoloView.setModel(modelPathOrName: modelURL.path, task: .detect) { _ in }
              self.labelFPS.text = "Ready"
              print("✅ Pothole detection model loaded successfully")
            case .failure(let error):
              self.labelFPS.text = "Error loading model"
              print("❌ Failed to load model: \(error)")
            }
          }
        }
      } else {
        DispatchQueue.main.async {
          self.activityIndicator.stopAnimating()
          self.isLoadingModel = false
          self.labelFPS.text = "Model not found"
          print("❌ Model file not found in bundle")
        }
      }
    }
  }

  @objc func shareButtonTapped() {
    yoloView.capturePhoto { [weak self] image in
      guard let self = self, let image = image else { return }
      DispatchQueue.main.async {
        let vc = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        vc.popoverPresentationController?.sourceView = self.shareButton
        self.present(vc, animated: true)
      }
    }
  }

  @objc func settingsButtonTapped() {
    let alert = UIAlertController(title: "Settings", message: "Adjust detection parameters", preferredStyle: .actionSheet)

    alert.addAction(UIAlertAction(title: "Reset to Defaults", style: .default) { [weak self] _ in
      self?.resetThresholds()
    })

    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

    present(alert, animated: true)
  }

  private func resetThresholds() {
    confidenceSlider.value = Float(Constants.defaultConfidenceThreshold)
    iouSlider.value = Float(Constants.defaultIouThreshold)
    yoloModel?.setConfidenceThreshold(Constants.defaultConfidenceThreshold)
    yoloModel?.setIouThreshold(Constants.defaultIouThreshold)
    updateConfidenceLabel(confidenceSlider.value)
    updateIouLabel(iouSlider.value)
  }

  func yoloView(_ view: YOLOView, didUpdatePerformance fps: Double, inferenceTime: Double) {
    DispatchQueue.main.async { [weak self] in
      self?.labelFPS.text = String(format: "%.1f FPS | %.1f ms", fps, inferenceTime)
    }
  }

  func yoloView(_ view: YOLOView, didReceiveResult result: YOLOResult) {
    // Result handling is done internally by YOLOView for visualization
    // Additional result processing can be added here if needed
  }

  deinit {
    print("ViewController deinitialized")
  }
}
