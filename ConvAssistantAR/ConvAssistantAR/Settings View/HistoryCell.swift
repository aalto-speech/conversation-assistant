//
//  File.swift
//  ConvAssistantAR
//
//  Created by Virkkunen Anja on 16/08/2018.
//  Copyright © 2018 Virkkunen Anja. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {
    
    @IBOutlet weak var emptyHistoryButton: UIButton!
    
    var item: MenuViewModelItem? {
        didSet {
            guard let item = item as? MenuViewModelHistoryItem else {
                return
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
