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
    private let lineView = UIView()
    private let circleView = UIView()
    private let lineSeparatorView = UIView()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .None
        self.backgroundColor = ColorPalette.BlackHaze
        self.layer.rasterizationScale = UIScreen.mainScreen().scale
        self.layer.shouldRasterize = true
        
        self.lineView.translatesAutoresizingMaskIntoConstraints = false
        self.lineView.backgroundColor = ColorPalette.LavenderGray
        self.contentView.addSubview(self.lineView)
        
        self.circleView.translatesAutoresizingMaskIntoConstraints = false
        self.circleView.backgroundColor = ColorPalette.SeaGreenMedium
        self.circleView.layer.cornerRadius = 5.0
        self.contentView.addSubview(self.circleView)
        
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = false
        self.dateLabel.font = UIFont.systemFontOfSize(12.0)
        self.dateLabel.textColor = .grayColor()
        self.dateLabel.adjustFontToRealIPhoneSize = true
        self.contentView.addSubview(self.dateLabel)
                
        self.statusLabel.translatesAutoresizingMaskIntoConstraints = false
        self.statusLabel.font = UIFont.systemFontOfSize(14.0)
        self.statusLabel.numberOfLines = 0
        self.statusLabel.adjustFontToRealIPhoneSize = true
        self.contentView.addSubview(self.statusLabel)
        
        self.lineSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        self.lineSeparatorView.backgroundColor = ColorPalette.LavenderGray
        self.contentView.addSubview(self.lineSeparatorView)
    }

    override func updateConstraints() {
        if !self.didSetupConstraints {
            NSLayoutConstraint.activateConstraints([
                NSLayoutConstraint(item: self.lineView, attribute: .Top, relatedBy: .Equal, toItem: self.contentView, attribute: .Top, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: self.lineView, attribute: .Bottom, relatedBy: .Equal, toItem: self.contentView, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: self.lineView, attribute: .Leading, relatedBy: .Equal, toItem: self.contentView, attribute: .Leading, multiplier: 1.0, constant: 15.0),
                NSLayoutConstraint(item: self.lineView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 1.0),

                NSLayoutConstraint(item: self.circleView, attribute: .CenterY, relatedBy: .Equal, toItem: self.dateLabel, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: self.circleView, attribute: .CenterX, relatedBy: .Equal, toItem: self.lineView, attribute: .CenterX, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: self.circleView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 10.0),
                NSLayoutConstraint(item: self.circleView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 10.0),
                
                NSLayoutConstraint(item: self.dateLabel, attribute: .Top, relatedBy: .Equal, toItem: self.contentView, attribute: .Top, multiplier: 1.0, constant: 10.0),
                NSLayoutConstraint(item: self.dateLabel, attribute: .Leading, relatedBy: .Equal, toItem: self.lineView, attribute: .Leading, multiplier: 1.0, constant: 15.0),
                NSLayoutConstraint(item: self.dateLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self.contentView, attribute: .Trailing, multiplier: 1.0, constant: -15.0),
                
                NSLayoutConstraint(item: self.statusLabel, attribute: .Top, relatedBy: .Equal, toItem: self.dateLabel, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: self.statusLabel, attribute: .Leading, relatedBy: .Equal, toItem: self.lineView, attribute: .Leading, multiplier: 1.0, constant: 15.0),
                NSLayoutConstraint(item: self.statusLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self.contentView, attribute: .Trailing, multiplier: 1.0, constant: -15.0),
                NSLayoutConstraint(item: self.statusLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self.contentView, attribute: .Bottom, multiplier: 1.0, constant: -10.0),
                
                NSLayoutConstraint(item: self.lineSeparatorView, attribute: .Top, relatedBy: .Equal, toItem: self.statusLabel, attribute: .Bottom, multiplier: 1.0, constant: 10.0),
                NSLayoutConstraint(item: self.lineSeparatorView, attribute: .Leading, relatedBy: .Equal, toItem: self.statusLabel, attribute: .Leading, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: self.lineSeparatorView, attribute: .Trailing, relatedBy: .Equal, toItem: self.contentView, attribute: .Trailing, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: self.lineSeparatorView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 0.5)
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
    
    func configure(withViewModel viewModel: PackageTrackHistoryViewModel) {
        self.statusLabel.text = viewModel.status()
        self.dateLabel.text = viewModel.lastUpdateDateString()
        
        self.setNeedsUpdateConstraints()
        self.updateConstraintsIfNeeded()
    }

}
