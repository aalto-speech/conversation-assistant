//
//  ASRTypeCell.swift
//  ConvAssistantAR
//
//  Created by Virkkunen Anja on 16/05/2018.
//  Copyright © 2018 Virkkunen Anja. All rights reserved.
//

import UIKit

class ASRTypeCell: UITableViewCell {
    
    @IBOutlet weak var asrTypeLabel: UILabel!
    @IBOutlet weak var asrSegmentedControl: UISegmentedControl?
    
    var item: MenuViewModelItem? {
        didSet {
            guard let item = item as? MenuViewModelAsrItem else {
                return
            }
            asrSegmentedControl?.selectedSegmentIndex = SettingsManager.currentSettings(segmentType: item.type)
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
