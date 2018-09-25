//
//  TranscriptionCell.swift
//  ConvAssistantAR
//
//  Created by Virkkunen Anja on 13/06/2018.
//  Copyright © 2018 Virkkunen Anja. All rights reserved.
//

import UIKit

class TranscriptionCell: UICollectionViewCell {

    @IBOutlet weak var textBubbleView: textBubbleView!
    @IBOutlet weak var transcriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // Constraint bubble image so that it resizes automatically
        addConstraintsWithFormat( "H:|[v0]|", views: textBubbleView.bubbleImage)
        addConstraintsWithFormat( "V:|[v0]|", views: textBubbleView.bubbleImage)
     }
}

extension UIView {
    func addConstraintsWithFormat(_ format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}
