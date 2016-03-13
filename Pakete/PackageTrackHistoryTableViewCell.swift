//
//  PackageTrackHistoryTableViewCell.swift
//  Pakete
//
//  Created by Royce Albert Dy on 13/03/2016.
//  Copyright © 2016 Pakete. All rights reserved.
//

import UIKit

class PackageTrackHistoryTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "PackageTrackHistoryCell"
    
    let dateLabel = UILabel()
    let statusLabel = UILabel()
    
    private var didSetupConstraints = false

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .None
        
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = false
        self.dateLabel.text = "January 1, 2016"
        self.dateLabel.font = UIFont.systemFontOfSize(12.0)
        self.dateLabel.textColor = .grayColor()
        self.contentView.addSubview(self.dateLabel)
                
        self.statusLabel.translatesAutoresizingMaskIntoConstraints = false
        self.statusLabel.text = "Shipment is held at Air21 CEBU station."
        self.statusLabel.font = UIFont.systemFontOfSize(14.0)
        self.statusLabel.numberOfLines = 0
        self.contentView.addSubview(self.statusLabel)
    }

    override func updateConstraints() {
        if !self.didSetupConstraints {
            NSLayoutConstraint.activateConstraints([
                NSLayoutConstraint(item: self.dateLabel, attribute: .Top, relatedBy: .Equal, toItem: self.contentView, attribute: .Top, multiplier: 1.0, constant: 10.0),
                NSLayoutConstraint(item: self.dateLabel, attribute: .Leading, relatedBy: .Equal, toItem: self.contentView, attribute: .Leading, multiplier: 1.0, constant: 15.0),
                NSLayoutConstraint(item: self.dateLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self.contentView, attribute: .Trailing, multiplier: 1.0, constant: -15.0),
                
                NSLayoutConstraint(item: self.statusLabel, attribute: .Top, relatedBy: .Equal, toItem: self.dateLabel, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: self.statusLabel, attribute: .Leading, relatedBy: .Equal, toItem: self.contentView, attribute: .Leading, multiplier: 1.0, constant: 15.0),
                NSLayoutConstraint(item: self.statusLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self.contentView, attribute: .Trailing, multiplier: 1.0, constant: -15.0),
                NSLayoutConstraint(item: self.statusLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self.contentView, attribute: .Bottom, multiplier: 1.0, constant: -10.0)
                ])
            self.didSetupConstraints = true
        }
        
        super.updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
