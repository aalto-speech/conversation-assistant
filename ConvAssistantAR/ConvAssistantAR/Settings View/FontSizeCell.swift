//
//  FontSizeCell.swift
//  ConvAssistantAR
//
//  Created by Virkkunen Anja on 29/08/2018.
//  Copyright © 2018 Virkkunen Anja. All rights reserved.
//

import UIKit

class FontSizeCell: UITableViewCell {
    
    @IBOutlet weak var fontSizeSlider: UISlider!
    @IBOutlet weak var sizeLabel: UILabel!
    
    var item: MenuViewModelItem? {
        didSet {
            guard let item = item as? MenuViewModelFontSizeItem else {
                return
            }
            let currentFontSize: Float = SettingsManager.currentSettings(segmentType: item.type)
            fontSizeSlider?.value = currentFontSize
            sizeLabel?.text = String(describing: Int(currentFontSize))
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
    
    @IBAction func fontSizeChanged(_ sender: UISlider) {
        sizeLabel?.text = String(describing: Int(sender.value))
    }
}
