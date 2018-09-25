//
//  SettingsMenuViewController.swift
//  ConvAssistantAR
//
//  Created by Virkkunen Anja on 14/05/2018.
//  Copyright © 2018 Virkkunen Anja. All rights reserved.
//

import UIKit

protocol SettingsMenuDelegate: AnyObject {
    func passSegmentedControlChange(segmentIndex: Int, segmentType: MenuViewModelItemType)
    func passFontSizeChange(fontSize: Float)
    func passEmptyHistory()
    func passCameraOnOff(cameraIsOn: Bool)
}

class SettingsMenuViewController: UIViewController {
    
    @IBOutlet weak var settingsMenuTableView: UITableView!
    
    fileprivate let viewModel = MenuViewModel()
    weak var delegate: SettingsMenuDelegate?
    private var isCameraOn: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // General layout settings
        settingsMenuTableView.layer.cornerRadius = 12
        settingsMenuTableView.layer.masksToBounds = true
        // Adjust layout to varying cell sizes
        settingsMenuTableView.dataSource = viewModel
        settingsMenuTableView.estimatedRowHeight = 65.0 // Correct menu size, depends on number of cells
        settingsMenuTableView.rowHeight = UITableViewAutomaticDimension
        settingsMenuTableView.frame = CGRect(x: settingsMenuTableView.frame.origin.x, y: settingsMenuTableView.frame.origin.y,
            width: settingsMenuTableView.frame.size.width, height: settingsMenuTableView.contentSize.height)
        
        isCameraOn = SettingsManager.currentSettings(segmentType: .camera)
    }
    
    override func viewDidLayoutSubviews() {
        settingsMenuTableView.frame = CGRect(x: settingsMenuTableView.frame.origin.x, y: settingsMenuTableView.frame.origin.y,
                                             width: settingsMenuTableView.frame.size.width, height: settingsMenuTableView.contentSize.height)
        settingsMenuTableView.reloadData()
    }
    
    @IBAction func changeASRType(_ sender: UISegmentedControl) {
        // Change the ASR provider (save setting and delegate the choice to MainViewController)
        SettingsManager.applySettings(segmentType: .asrType, segmentIndex: sender.selectedSegmentIndex)
        delegate?.passSegmentedControlChange(segmentIndex: sender.selectedSegmentIndex, segmentType: .asrType)
    }
    
    @IBAction func changeUIType(_ sender: UISegmentedControl) {
        // Change the UI (save setting and delegate the choice to MainViewController)
        SettingsManager.applySettings(segmentType: .uiType, segmentIndex: sender.selectedSegmentIndex)
        delegate?.passSegmentedControlChange(segmentIndex: sender.selectedSegmentIndex, segmentType: .uiType)
    }
    
    @IBAction func fontSizeTouchUp(_ sender: UISlider) {
        SettingsManager.applySettings(segmentType: .fontSize, sliderValue: sender.value)
        delegate?.passFontSizeChange(fontSize: sender.value)
    }
    
    // Empty transcriptions
    @IBAction func emptyHistory(_ sender: UIButton) {
        delegate?.passEmptyHistory()
    }
    
    // Turn camera on or off
    @IBAction func turnCameraOnOff(_ sender: UIButton) {
        guard let isCameraOn = isCameraOn else {
            fatalError("isCameraOn not defined!")
        }
        
        if !isCameraOn {
            sender.setTitle("Sammuta kamera", for: .normal)
        } else {
            sender.setTitle("Käynnistä kamera", for: .normal)
        }
        SettingsManager.applySettings(segmentType: .camera, cameraOnOff: !isCameraOn)
        delegate?.passCameraOnOff(cameraIsOn: !isCameraOn)
        self.isCameraOn = !isCameraOn
        
        // Disable UITypeCell's segmented control when camera is off
        let cellIdentifier = "UITypeCell"
        let cells = settingsMenuTableView.visibleCells.filter{$0.reuseIdentifier == cellIdentifier} as! [UITypeCell]
        for cell in cells {
            cell.isCameraOn = !isCameraOn
        }
}
    
    // Open iOS settings so user can change permissions
    @IBAction func openSettings(_ sender: UIButton) {
        if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.shared.open(appSettings)
        }
    }
    
    // Close menu if user touches outside it
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        
        if touch?.view != settingsMenuTableView {
            dismiss(animated: true, completion: nil)
        }
    }
}

struct SettingsManager {
    // Data struct that saves user choices for the segmented control buttons
    
    static func currentSettings(segmentType: MenuViewModelItemType) -> Int {
        // Return current status of given segmented control button
        if segmentType == .asrType {
            return UserDefaults.standard.integer(forKey: "ASR")
        } else if segmentType == .uiType {
            return UserDefaults.standard.integer(forKey: "UI")
        }
        return 0
    }
    
    static func currentSettings(segmentType: MenuViewModelItemType) -> Float {
        // Return current status of font slider button
        if segmentType == .fontSize {
            return UserDefaults.standard.float(forKey: "Font")
        }
        return 0.0
    }
    
    static func currentSettings(segmentType: MenuViewModelItemType) -> Bool {
        if segmentType == .camera {
            return UserDefaults.standard.bool(forKey: "CameraOnOff")
        }
        return false
    }
    
    static func applySettings(segmentType: MenuViewModelItemType, segmentIndex: Int? = nil, sliderValue: Float? = nil, cameraOnOff: Bool? = nil) {
        // Save changes to segmented controls
        if segmentType == .asrType {
            guard let segmentIndex = segmentIndex else {
                fatalError("No segment index for ASR to store.")
            }
            UserDefaults.standard.set(segmentIndex, forKey: "ASR")
        } else if segmentType == .uiType {
            guard let segmentIndex = segmentIndex else {
                fatalError("No segment index for UI to store.")
            }
            UserDefaults.standard.set(segmentIndex, forKey: "UI")
        } else if segmentType == .fontSize {
            guard let sliderValue = sliderValue else {
                fatalError("No font size slider value to store.")
            }
            UserDefaults.standard.set(sliderValue, forKey: "Font")
        } else if segmentType == .camera {
            guard let cameraOnOff = cameraOnOff else {
                fatalError("No camera on/off status to store.")
            }
            UserDefaults.standard.set(cameraOnOff, forKey: "CameraOnOff")
        }
        UserDefaults.standard.synchronize()
    }
}
