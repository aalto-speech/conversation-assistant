//
//  ViewController.swift
//  ConvAssistantAR
//
//  Created by Virkkunen Anja on 02/05/2018.
//  Copyright © 2018 Virkkunen Anja. All rights reserved.
//

import UIKit
import ARKit
import Vision
import Speech
import AVFoundation
import SwiftWebSocket

enum layoutType {
    case bubbleType
    case boxType
}

class MainViewController: UIViewController, ARSCNViewDelegate, UIApplicationDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: Properties
    // UI Elements
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var recordButton: RecordButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var faceDetectionView: UIView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var transcriptionCollectionView: UICollectionView!
    @IBOutlet weak var transcriptionCollectionViewLeading: NSLayoutConstraint!
    @IBOutlet weak var transcriptionCollectionViewTrailing: NSLayoutConstraint!
    @IBOutlet weak var transcriptionCollectionViewTop: NSLayoutConstraint!
    @IBOutlet weak var transcriptionCollectionViewBottom: NSLayoutConstraint!
    
    // Layout setup
    private var layoutType: layoutType?
    private var layoutTypeBeforeCameraTurnedOff: layoutType?
    private let flowLayout: UICollectionViewFlowLayout = {
        let alignedLayout = UICollectionViewFlowLayout()
        alignedLayout.scrollDirection = UICollectionViewScrollDirection.vertical
        return alignedLayout
    }()
    private var bubbleImage = "bubble_noface" {
        didSet {
            if bubbleImage != oldValue {
                self.transcriptionCollectionView.reloadData()
                self.view.layoutIfNeeded()
            }
        }
    }
    private var recordButtonSpace: CGFloat = 70
    private var settingsButtonSpace: CGFloat = 70
    private var textWidth: CGFloat = 250
    private var fontSize: CGFloat = 20
    private var speechRecHandler: SpeechRecognitionHandler?
    private var notification: NSObjectProtocol?
    
    // Face tracking
    private var scanTimer: Timer?
    private var scannedFaceViews = [UIView]()
    private var imageOrientation: CGImagePropertyOrientation {
        switch UIDevice.current.orientation {
        case .portrait: return .right
        case .landscapeRight: return .down
        case .portraitUpsideDown: return .left
        case .unknown: fallthrough
        case .faceUp: fallthrough
        case .faceDown: fallthrough
        case .landscapeLeft: return .up
        }
    }
    
    // MARK: View Control
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self

        transcriptionCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        // Fetch as float
        let size: Float = SettingsManager.currentSettings(segmentType: .fontSize)
        fontSize = CGFloat(size)
        
        let asrType: Int = SettingsManager.currentSettings(segmentType: .asrType)
        if asrType == 0 {
            speechRecHandler = SpeechRecognitionHandler(asrType: .aalto, transcriptionCollectionView: transcriptionCollectionView, recognitionLimitSec: 60, noSpeechDurationLimitSec: 5, socketDelegate: self)
        } else {
            speechRecHandler = SpeechRecognitionHandler(asrType: .apple, transcriptionCollectionView: transcriptionCollectionView, recognitionLimitSec: 60, noSpeechDurationLimitSec: 15, socketDelegate: self)
        }
        
        // Start with chosen layout (default is bubble)
        let uiType: Int = SettingsManager.currentSettings(segmentType: .uiType)
        if uiType == 0 {
            setupBubbleLayout()
            layoutTypeBeforeCameraTurnedOff = .bubbleType
        } else {
            setupBoxLayout()
            layoutTypeBeforeCameraTurnedOff = .boxType
        }
        
        passCameraOnOff(cameraIsOn: SettingsManager.currentSettings(segmentType: .camera))

        // Finish by setting the layout variable
        transcriptionCollectionView.collectionViewLayout = flowLayout
        
        // Check permission for speech recognition
        speechRecognitionIsEnabled()
        
        // Detect when application will enter foreground to resume animation
        notification = NotificationCenter.default.addObserver(forName: .UIApplicationWillEnterForeground, object: nil, queue: .main) {
            [unowned self] notification in
            if self.recordButton.isSelected {
                self.recordButton.startPulseAnimation()
            }
            self.transcriptionCollectionView.reloadData()
            self.scrollToBottom(animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        // Run the view's session
        sceneView.session.run(configuration)
        // Scan for faces in regular intervals
        scanTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(scanForFaces), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        scanTimer?.invalidate()
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // Reload cells to adjust transcriptions to changing box width when device is rotated 
        if layoutType == .boxType {
            transcriptionCollectionView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: Face tracking
    @objc private func scanForFaces() {
        // Remove the test views and empty the array that was keeping a reference to them
        _ = scannedFaceViews.map { $0.removeFromSuperview() }
        scannedFaceViews.removeAll()
        
        // Get the captured image of the ARSession's current frame
        guard let capturedImage = sceneView.session.currentFrame?.capturedImage else { return }
        let image = CIImage.init(cvPixelBuffer: capturedImage)
   
        let detectFaceRequest = VNDetectFaceRectanglesRequest { (request, error) in
            DispatchQueue.main.async {
                // Loop through the detected faces and add them to a container
                if let faces = request.results as? [VNFaceObservation] {
                    for face in faces {
                        let faceView = UIView(frame: self.faceFrame(from: face.boundingBox))
                        self.scannedFaceViews.append(faceView)
                    }
                }
                if self.layoutType == .bubbleType {
                    self.scannedFaceViews.sort { $0.frame.origin.x < $1.frame.origin.x}
                    if !self.scannedFaceViews.isEmpty {
                        let face = self.scannedFaceViews[self.scannedFaceViews.count/2]
                        self.faceDetectionView.frame = face.frame
                        self.faceDetectionView.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
                        self.faceDetectionView.layer.borderWidth = 0.5
                        // Move bubbles along the face frame on x-axis
                        if self.view.frame.width - face.frame.maxX - self.recordButtonSpace > 300  {
                            self.bubbleImage = "bubble_right_side"
                            self.transcriptionCollectionViewLeading.constant = face.frame.maxX
                            self.transcriptionCollectionViewTrailing.constant = self.view.frame.width - face.frame.maxX - 300
                        } else if face.frame.minX - self.settingsButtonSpace > 300 {
                            self.bubbleImage = "bubble_left_side"
                            self.transcriptionCollectionViewLeading.constant = face.frame.minX - 300                            // Leave space for button
                            self.transcriptionCollectionViewTrailing.constant = self.view.frame.width - face.frame.minX         // Computed as distance from screen right edge
                        } else {
                            // If there is not enough space on neither side of the face frame
                            self.bubbleImage = "bubble_right_side"
                            self.transcriptionCollectionViewLeading.constant = self.view.frame.width - self.recordButtonSpace - 300
                            self.transcriptionCollectionViewTrailing.constant = self.recordButtonSpace
                        }
                        // Same for y-axis
                        self.transcriptionCollectionViewBottom.constant = self.view.frame.height - face.frame.maxY + 0.25 * face.frame.height
                    } else {
                        self.bubbleImage = "bubble_noface"
                        self.faceDetectionView.layer.borderColor = UIColor.clear.cgColor
                        self.transcriptionCollectionViewLeading.constant = self.view.frame.width - self.recordButtonSpace - 300
                        self.transcriptionCollectionViewTrailing.constant = self.recordButtonSpace
                        self.transcriptionCollectionViewBottom.constant = self.view.frame.midY
                        self.transcriptionCollectionViewTop.constant = 0
                    }

                    self.view.bringSubview(toFront: self.transcriptionCollectionView)
                    UIView.animate(withDuration: 1.75, delay: 0, options: [.curveEaseInOut], animations: {
                        self.view.layoutIfNeeded()
                        self.scrollToBottom(animated: false)
                    }, completion: nil)
                }
            }
        }
        DispatchQueue.global().async {
            try? VNImageRequestHandler(ciImage: image, orientation: self.imageOrientation).perform([detectFaceRequest])
        }
    }
    
    private func faceFrame(from boundingBox: CGRect) -> CGRect {
        // Translate camera frame to frame inside the ARSKView
        let origin = CGPoint(x: boundingBox.minX * sceneView.bounds.width, y: (1 - boundingBox.maxY) * sceneView.bounds.height)
        let size = CGSize(width: boundingBox.width * sceneView.bounds.width, height: boundingBox.height * sceneView.bounds.height)
        
        return CGRect(origin: origin, size: size)
    }
    
    // MARK: Button actions
    @IBAction func transcribeButtonPressed(_ sender: RecordButton) {
        if sender.isSelected {
            speechRecHandler?.client?.closeSocket()
        } else {
            speechRecHandler?.tryRecording()
        }
    }
    
    // MARK: Permissions
    private func speechRecognitionIsEnabled() {
        // Check user permissions for usage of speech recognition
        DispatchQueue.main.async {
            SFSpeechRecognizer.requestAuthorization {
                [unowned self] (authStatus) in
                switch authStatus {
                case .authorized:
                    DispatchQueue.main.async {
                        self.recordButton.isEnabled = true
                    }
                case .denied:
                    self.disableRecordButton()
                case .restricted:
                    self.disableRecordButton()
                case .notDetermined:
                    self.disableRecordButton()
                }
            }

            switch AVAudioSession.sharedInstance().recordPermission() {
            case .granted:
                DispatchQueue.main.async {
                    self.recordButton.isEnabled = true                    
                }
            case .denied:
                self.disableRecordButton()
            case .undetermined:
                self.disableRecordButton()
            }
        }
    }
    
    // If user has denied recording permissions
    func disableRecordButton() {
        DispatchQueue.main.async {
            self.recordButton.isEnabled = false
            self.recordButton.alpha = 0.5            
        }
    }
    
    // MARK: Transcription collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Count number of elements
        if let count = speechRecHandler?.transcriptions?.count {
            return count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Fill cells with content
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "transcriptionCell", for: indexPath) as! TranscriptionCell
        cell.transcriptionLabel.text = speechRecHandler?.transcriptions?[indexPath.item]
        cell.transcriptionLabel.font = cell.transcriptionLabel.font.withSize(fontSize)
        
        // Estimate cell size depending on the amount of text in it
        if let transcriptionText = speechRecHandler?.transcriptions?[indexPath.item] {
            let size = CGSize(width: textWidth, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: transcriptionText).boundingRect(with: size, options: options,
                                                                                  attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: fontSize)], context: nil)
            if layoutType == .bubbleType {
                // This adjusts bubble image width to text width
                if bubbleImage == "bubble_right_side" {
                    cell.textBubbleView.frame = CGRect(x: 0, y: 0, width: estimatedFrame.width + 36, height: estimatedFrame.height + 20)
                    cell.transcriptionLabel.frame = CGRect(x: 18, y: 0, width: estimatedFrame.width + 14, height: estimatedFrame.height + 20)
                } else if bubbleImage == "bubble_left_side" {
                    cell.textBubbleView.frame = CGRect(x: transcriptionCollectionView.frame.width - estimatedFrame.width - 42, y: 0, width: estimatedFrame.width + 36, height: estimatedFrame.height + 20)
                    cell.transcriptionLabel.frame = CGRect(x: transcriptionCollectionView.frame.width - estimatedFrame.width - 30, y: 0, width: estimatedFrame.width + 14, height: estimatedFrame.height + 20)
                } else {
                    cell.textBubbleView.frame = CGRect(x: 0, y: 0, width: estimatedFrame.width + 30, height: estimatedFrame.height + 20)
                    cell.transcriptionLabel.frame = CGRect(x: 12, y: 0, width: estimatedFrame.width + 14, height: estimatedFrame.height + 20)
                }
                if !transcriptionText.isEmpty {
                    guard let image = UIImage(named: bubbleImage) else { fatalError("Image asset for speech bubble not found!") }
                    cell.textBubbleView.bubbleImage.image = image
                        .resizableImage(withCapInsets: UIEdgeInsetsMake(17, 21, 17, 21))
                        .withRenderingMode(.alwaysTemplate)
                } else {
                    cell.textBubbleView.bubbleImage.image = nil
                }
            } else if layoutType == .boxType {
                cell.textBubbleView.frame = CGRect(x: 0, y: 0, width: estimatedFrame.width, height: estimatedFrame.height)
                cell.transcriptionLabel.frame = CGRect(x: 15, y: 0, width: estimatedFrame.width, height: estimatedFrame.height)
                cell.textBubbleView.bubbleImage.image = nil
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Dimensions are underestimated so these are finetuned additional params
        var extraHeight: CGFloat = 5
        if layoutType == .bubbleType {
            extraHeight = 20
        }
        // Estimate cell size depending on the amount of text in it
        if let transcriptionText = speechRecHandler?.transcriptions?[indexPath.item] {
            let size = CGSize(width: textWidth, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: transcriptionText).boundingRect(with: size, options: options,
                                                                                  attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: fontSize)], context: nil)
            
            return CGSize(width: transcriptionCollectionView.frame.width, height: estimatedFrame.height + extraHeight)
        }
        
        return CGSize(width: transcriptionCollectionView.frame.width, height: 30)
    }
    
    private func scrollToBottom(animated: Bool) {
        if let lastTranscription = self.speechRecHandler?.findLastIndexPath() {
            self.speechRecHandler?.reloadAndScrollToItem(indexPath: lastTranscription, animated: animated)
        }
    }
    
    // MARK: Custom layout setups
    private func setupBubbleLayout() {
        layoutType = .bubbleType
        
        // Hide blur effect (and disable scrolling)
        visualEffectView.isHidden = true
        transcriptionCollectionView.isScrollEnabled = false
        
        // Layout properties
        flowLayout.sectionInset = UIEdgeInsetsMake(5, 0, 0, 0)
        flowLayout.minimumLineSpacing = 5
        
        // Change constraint properties
        transcriptionCollectionViewLeading.constant = view.frame.width - recordButtonSpace - 300
        transcriptionCollectionViewTrailing.constant = recordButtonSpace
        transcriptionCollectionViewBottom.constant = view.frame.midY
        transcriptionCollectionViewTop.constant = 0
        
        // Update
        view.layoutIfNeeded()
        textWidth = 250
        transcriptionCollectionView.reloadSections(IndexSet(integersIn: 0...0))
    }
    
    private func setupBoxLayout(topConstraint: CGFloat? = nil) {
        layoutType = .boxType
        
        // Show blur effect (and enable scrolling)
        visualEffectView.isHidden = false
        transcriptionCollectionView.isScrollEnabled = true
        
        // Layout properties
        flowLayout.sectionInset = UIEdgeInsetsMake(5, 0, 5, 0)
        flowLayout.minimumLineSpacing = 1
        
        // Change constraint properties
        transcriptionCollectionViewLeading.constant = 20
        transcriptionCollectionViewTrailing.constant = 20
        transcriptionCollectionViewBottom.constant = 20
        transcriptionCollectionViewTop.constant = topConstraint ?? view.frame.height * 0.66
        
        // Update
        view.layoutIfNeeded()
        textWidth = transcriptionCollectionView.frame.width - 30
        transcriptionCollectionView.reloadSections(IndexSet(integersIn: 0...0))
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // A segue for setting the delegate (enables information passing between controllers)
        if segue.identifier == "settingsMenuSegue" {
            let settingsMenu = segue.destination as! SettingsMenuViewController
            settingsMenu.delegate = self
        }
    }
    
    // MARK: Other
    // Remove observer when view controller is dismissed/deallocated
    deinit {
        if let notification = notification {
            NotificationCenter.default.removeObserver(notification)
        }
    }
}

extension MainViewController: SettingsMenuDelegate, SocketEventDelegate {
    
    // Catch changes made in the settings menu and act on it
    func passSegmentedControlChange(segmentIndex: Int, segmentType: MenuViewModelItemType) {
        // Layout change
        if segmentType == MenuViewModelItemType.uiType {
            switch segmentIndex {
            case 0:
                self.setupBubbleLayout()
                self.layoutTypeBeforeCameraTurnedOff = .bubbleType
            case 1:
                self.setupBoxLayout()
                self.layoutTypeBeforeCameraTurnedOff = .boxType
            default:
                self.setupBubbleLayout()
                self.layoutTypeBeforeCameraTurnedOff = .bubbleType
            }
        // ASR provider change
        } else if segmentType == MenuViewModelItemType.asrType {
            switch segmentIndex {
            case 0:
                speechRecHandler?.ASRType = .aalto
            case 1:
                speechRecHandler?.ASRType = .apple
            default:
                speechRecHandler?.ASRType = .aalto
            }
        }
    }
    
    // Update font
    func passFontSizeChange(fontSize: Float) {
        self.fontSize = CGFloat(fontSize)
        self.transcriptionCollectionView.reloadSections(IndexSet(integersIn: 0...0))
        scrollToBottom(animated: true)
    }
    
    // Empty history
    func passEmptyHistory() {
        speechRecHandler?.transcriptions = nil
        speechRecHandler?.transcriptions = [""]
        speechRecHandler?.transcriptionCollectionView.reloadData()
    }
    
    func passCameraOnOff(cameraIsOn: Bool) {
        if cameraIsOn {
            sceneView.session.run(ARWorldTrackingConfiguration())
            sceneView.isHidden = false
            settingsButton.setTitleColor(.white, for: .normal)
            transcriptionCollectionView.layer.borderColor = UIColor.clear.cgColor
            transcriptionCollectionView.layer.borderWidth = 0.0
            transcriptionCollectionView.layer.cornerRadius = 0
            if layoutTypeBeforeCameraTurnedOff == .bubbleType {
                setupBubbleLayout()
            } else {
                setupBoxLayout()
            }
        } else {
            sceneView.session.pause()
            sceneView.isHidden = true
            settingsButton.setTitleColor(.black, for: .normal)
            transcriptionCollectionView.layer.borderColor = UIColor.gray.cgColor
            transcriptionCollectionView.layer.borderWidth = 0.5
            transcriptionCollectionView.layer.cornerRadius = 12
            setupBoxLayout(topConstraint: CGFloat(70))
        }
        recordButton.cameraOn = cameraIsOn
    }
    
    // Stop record button animation
    func socketClosed() {
        if recordButton.isSelected {
            recordButton.pathLayer.removeAllAnimations()
        }
    }
}

