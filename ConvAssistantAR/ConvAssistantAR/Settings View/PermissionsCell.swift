//
//  PermissionsCell.swift
//  ConvAssistantAR
//
//  Created by Virkkunen Anja on 16/05/2018.
//  Copyright © 2018 Virkkunen Anja. All rights reserved.
//

import UIKit

class PermissionsCell: UITableViewCell {
    
    @IBOutlet weak var openSettingsButton: UIButton!
    @IBOutlet weak var ARCameraLabel: UILabel!
    @IBOutlet weak var microphoneLabel: UILabel!
    @IBOutlet weak var speechRecogLabel: UILabel!
    
    
    var item: MenuViewModelItem? {
        didSet {
            guard let item = item as? MenuViewModelPermissionsItem else {
                return
            }
            
            self.ARCameraLabel.text = item.ARCameraStatus
            self.microphoneLabel.text = item.microphoneStatus
            self.speechRecogLabel.text = item.speechRecognitionStatus
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
