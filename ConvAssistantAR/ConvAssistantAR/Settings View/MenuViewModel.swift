//
//  MenuViewModelTableViewCell.swift
//  ConvAssistantAR
//
//  Created by Virkkunen Anja on 16/05/2018.
//  Copyright © 2018 Virkkunen Anja. All rights reserved.
//

import UIKit
import AVFoundation
import Speech

enum MenuViewModelItemType {
    case asrType
    case uiType
    case fontSize
    case history
    case camera
    case permissions
}

protocol MenuViewModelItem {
    var type: MenuViewModelItemType { get }
    var rowCount: Int { get }
    var sectionTitle: String { get }
}

extension MenuViewModelItem {
    var rowCount: Int {
        return 1
    }
}

class MenuViewModelAsrItem: MenuViewModelItem {
    var type: MenuViewModelItemType {
        return .asrType
    }
    
    var sectionTitle: String {
        return "ASR-palvelin"
    }
    
    init(){}
}

class MenuViewModelUIItem: MenuViewModelItem {
    var type: MenuViewModelItemType {
        return .uiType
    }
    
    var sectionTitle: String {
        return "Puheen esitystapa"
    }
    
    init(){}
}

class MenuViewModelFontSizeItem: MenuViewModelItem {
    var type: MenuViewModelItemType {
        return .fontSize
    }
    
    var sectionTitle: String {
        return "Kirjasimen koko"
    }
    
    init(){}
}

class MenuViewModelHistoryItem: MenuViewModelItem {
    var type: MenuViewModelItemType {
        return .history
    }
    
    var sectionTitle: String {
        return "Puhehistoria"
    }
    
    init(){}
}

class MenuViewModelCameraItem: MenuViewModelItem {
    var type: MenuViewModelItemType {
        return .camera
    }
    
    var sectionTitle: String {
        return "Kamera"
    }
    
    init(){}
}

class MenuViewModelPermissionsItem: MenuViewModelItem {
    var type: MenuViewModelItemType {
        return .permissions
    }
    
    var sectionTitle: String {
        return "Käyttöoikeudet"
    }
    
    var ARCameraStatus: String
    var microphoneStatus: String
    var speechRecognitionStatus: String
    
    init(ARCameraStatus: String, microphoneStatus: String, speechRecognitionStatus: String) {
        self.ARCameraStatus = ARCameraStatus
        self.microphoneStatus = microphoneStatus
        self.speechRecognitionStatus = speechRecognitionStatus
    }
    
}

class MenuViewModel: NSObject {
    var items = [MenuViewModelItem]()
    
    override init() {
        super.init()
        
        // Required permissions
        var cameraStatus: String
        var micStatus: String
        var speechStatus: String
        
        // Determine status of each permission
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraStatus = "Kameran käyttö sallittu."
        case .denied:
            cameraStatus = "Kameran käyttö estetty."
        case .notDetermined:
            cameraStatus = "Kameran käyttölupaa ei ole päätetty."
        case .restricted:
            cameraStatus = "Käyttäjällä ei ole lupaa käyttää kameraa."
        }

        switch AVAudioSession.sharedInstance().recordPermission() {
        case AVAudioSessionRecordPermission.granted:
            micStatus = "Mikrofonin käyttö sallittu."
        case AVAudioSessionRecordPermission.denied:
            micStatus = "Mikrofonin käyttö estetty."
        case AVAudioSessionRecordPermission.undetermined:
            micStatus = "Mikrofonin käyttölupaa ei ole päätetty."
        }
        
        switch SFSpeechRecognizer.authorizationStatus() {
        case .authorized:
            speechStatus = "Puheentunnistuksen käyttö sallittu."
        case .denied:
            speechStatus = "Puheentunnistuksen käyttö estetty."
        case .notDetermined:
            speechStatus = "Puheentunnistuksen käyttölupaa ei ole päätetty."
        case .restricted:
            speechStatus = "Käyttäjällä ei ole lupaa käyttää puheentunnistinta."
        }
        
        // Append buttons to menu (order matters)
        items.append(MenuViewModelAsrItem())
        items.append(MenuViewModelUIItem())
        items.append(MenuViewModelFontSizeItem())
        items.append(MenuViewModelHistoryItem())
        items.append(MenuViewModelCameraItem())
        items.append(MenuViewModelPermissionsItem(ARCameraStatus: cameraStatus, microphoneStatus: micStatus, speechRecognitionStatus: speechStatus))
    }
    
}

extension MenuViewModel: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.section]
        
        switch item.type {
        case .asrType:
            let cellIdentifier = "ASRTypeCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ASRTypeCell else {
                fatalError("The dequeue cell is not an instance of ASRTypeCell")
            }
            cell.item = item
            return cell
        case .uiType:
            let cellIdentifier = "UITypeCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? UITypeCell else {
                fatalError("The dequeue cell is not an instance of UITypeCell")
            }
            cell.item = item
            return cell
        case .fontSize:
            let cellIdentifier = "FontSizeCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FontSizeCell else {
                fatalError("The dequeue cell is not an instance of FontSizeCell")
            }
            cell.item = item
            return cell
        case .history:
            let cellIdentifier = "HistoryCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? HistoryCell else {
                fatalError("The dequeue cell is not an instance of HistoryCell")
            }
            cell.item = item
            return cell
        case .camera:
            let cellIdentifier = "CameraCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CameraCell else {
                fatalError("The dequeue cell is not an instance of CameraCell")
            }
            cell.item = item
            return cell
        case .permissions:
            let cellIdentifier = "PermissionsCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PermissionsCell else {
                fatalError("The dequeue cell is not an instance of PermissionsCell")
            }
            cell.item = item
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return items[section].sectionTitle
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}



