//
//  UITypeCell.swift
//  ConvAssistantAR
//
//  Created by Virkkunen Anja on 20/06/2018.
//  Copyright © 2018 Virkkunen Anja. All rights reserved.
//

import UIKit

class UITypeCell: UITableViewCell {

    @IBOutlet weak var uiTypeLabel: UILabel!
    @IBOutlet weak var uiSegmentedControl: UISegmentedControl?
    var isCameraOn: Bool = false {
        willSet {
            uiSegmentedControl?.isEnabled = newValue
        }
    }
    
    var item: MenuViewModelItem? {
        didSet {
            guard let item = item as? MenuViewModelUIItem else {
                return
            }            
            uiSegmentedControl?.selectedSegmentIndex = SettingsManager.currentSettings(segmentType: item.type)
            uiSegmentedControl?.isEnabled = SettingsManager.currentSettings(segmentType: .camera)
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
