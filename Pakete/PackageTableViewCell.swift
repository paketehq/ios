//
//  PackageTableViewCell.swift
//  Pakete
//
//  Created by Royce Albert Dy on 12/03/2016.
//  Copyright © 2016 Pakete. All rights reserved.
//

import UIKit

class PackageTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "PackageCell"
    
    let nameLabel = UILabel()
    let statusLabel = UILabel()
    let dateLabel = UILabel()
    
    private var activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    private var didSetupConstraints = false
    private var viewModel: PackageViewModel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.accessoryType = .DisclosureIndicator
        self.layer.rasterizationScale = UIScreen.mainScreen().scale
        self.layer.shouldRasterize = true
        
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = false
        self.dateLabel.font = UIFont.systemFontOfSize(12.0)
        self.dateLabel.textAlignment = .Right
        self.dateLabel.textColor = .grayColor()
        self.contentView.addSubview(self.dateLabel)
        
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.nameLabel.font = UIFont.systemFontOfSize(16.0)
        self.contentView.addSubview(self.nameLabel)
        
        self.statusLabel.translatesAutoresizingMaskIntoConstraints = false
        self.statusLabel.font = UIFont.systemFontOfSize(14.0)
        self.statusLabel.textColor = .grayColor()
        self.statusLabel.numberOfLines = 0
        self.contentView.addSubview(self.statusLabel)
    }
    
    override func updateConstraints() {
        if !self.didSetupConstraints {
            NSLayoutConstraint.activateConstraints([
                NSLayoutConstraint(item: self.dateLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self.nameLabel, attribute: .CenterY, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: self.dateLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self.contentView, attribute: .Trailing, multiplier: 1.0, constant: 0.0),
                
                NSLayoutConstraint(item: self.nameLabel, attribute: .Top, relatedBy: .Equal, toItem: self.contentView, attribute: .Top, multiplier: 1.0, constant: 10.0),
                NSLayoutConstraint(item: self.nameLabel, attribute: .Leading, relatedBy: .Equal, toItem: self.contentView, attribute: .Leading, multiplier: 1.0, constant: 15.0),
                NSLayoutConstraint(item: self.nameLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self.dateLabel, attribute: .Leading, multiplier: 1.0, constant: -10.0),
                
                NSLayoutConstraint(item: self.statusLabel, attribute: .Top, relatedBy: .Equal, toItem: self.nameLabel, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: self.statusLabel, attribute: .Leading, relatedBy: .Equal, toItem: self.contentView, attribute: .Leading, multiplier: 1.0, constant: 15.0),
                NSLayoutConstraint(item: self.statusLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self.contentView, attribute: .Trailing, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: self.statusLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self.contentView, attribute: .Bottom, multiplier: 1.0, constant: -10.0)
            ])
            self.didSetupConstraints = true
        }        
        
        super.updateConstraints()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.activityIndicatorView.stopAnimating()
        self.accessoryType = .DisclosureIndicator
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(withViewModel viewModel: PackageViewModel) {
        self.viewModel = viewModel
        self.viewModel.package.asObservable()
            .subscribeNext({ (_) in
                self.reloadData()
            })
            .addDisposableTo(rx_disposeBag)
    }

}

extension PackageTableViewCell {
    private func reloadData() {
        self.nameLabel.text = self.viewModel.name()
        self.statusLabel.text = self.viewModel.status()
        self.dateLabel.text = self.viewModel.lastUpdateDateString()
        
        if self.viewModel.updating() {
            self.activityIndicatorView.startAnimating()
            self.accessoryView = self.activityIndicatorView
        } else {
            self.activityIndicatorView.stopAnimating()
            self.accessoryView = nil
            self.accessoryType = .DisclosureIndicator
        }
        
        self.setNeedsUpdateConstraints()
        self.updateConstraintsIfNeeded()
    }
}
