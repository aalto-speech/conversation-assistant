//
//  CameraCell.swift
//  ConvAssistantAR
//
//  Created by Virkkunen Anja on 03/09/2018.
//  Copyright © 2018 Virkkunen Anja. All rights reserved.
//

import UIKit

class CameraCell: UITableViewCell {

    @IBOutlet weak var cameraOnOffButton: UIButton!
    
    var item: MenuViewModelItem? {
        didSet {
            guard let item = item as? MenuViewModelCameraItem else {
                return
            }
            
            let isCameraOn: Bool = SettingsManager.currentSettings(segmentType: item.type)
            if isCameraOn {
                cameraOnOffButton.setTitle("Sammuta kamera", for: .normal)
            } else {
                cameraOnOffButton.setTitle("Käynnistä kamera", for: .normal)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
