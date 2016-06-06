//
//  PackageTableViewCell.swift
//  Pakete
//
//  Created by Royce Albert Dy on 12/03/2016.
//  Copyright © 2016 Pakete. All rights reserved.
//

import UIKit
import RxSwift

class PackageTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "PackageCell"
    
    let nameLabel = UILabel()
    let statusLabel = UILabel()
    let statusImageView = UIImageView()

    private var activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    private var didSetupConstraints = false
    private var viewModel: PackageViewModel!
    private let updating: Variable<Bool> = Variable(false)

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.accessoryType = .DisclosureIndicator
        self.layer.rasterizationScale = UIScreen.mainScreen().scale
        self.layer.shouldRasterize = true
                
        self.statusImageView.translatesAutoresizingMaskIntoConstraints = false
        self.statusImageView.layer.cornerRadius = 18.0
        self.statusImageView.contentMode = .Center
        self.contentView.addSubview(self.statusImageView)
        
        self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.activityIndicatorView)
        
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.nameLabel.font = UIFont.systemFontOfSize(16.0)
        self.nameLabel.adjustFontToRealIPhoneSize = true
        self.nameLabel.numberOfLines = 0
        self.contentView.addSubview(self.nameLabel)
        
        self.statusLabel.translatesAutoresizingMaskIntoConstraints = false
        self.statusLabel.font = UIFont.systemFontOfSize(14.0)
        self.statusLabel.textColor = .grayColor()
        self.statusLabel.numberOfLines = 0
        self.statusLabel.adjustFontToRealIPhoneSize = true
        self.contentView.addSubview(self.statusLabel)
        
        self.updating.asObservable()
            .bindTo(self.activityIndicatorView.rx_animating)
            .addDisposableTo(rx_disposeBag)
        
        self.updating.asObservable()
            .bindTo(self.statusImageView.rx_hidden)
            .addDisposableTo(rx_disposeBag)
    }
    
    override func updateConstraints() {
        if !self.didSetupConstraints {
            NSLayoutConstraint.activateConstraints([
                NSLayoutConstraint(item: self.statusImageView, attribute: .CenterY, relatedBy: .Equal, toItem: self.contentView, attribute: .CenterY, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: self.statusImageView, attribute: .Left, relatedBy: .Equal, toItem: self.contentView, attribute: .Left, multiplier: 1.0, constant: 15.0),
                NSLayoutConstraint(item: self.statusImageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 36.0),
                NSLayoutConstraint(item: self.statusImageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 36.0),
                
                NSLayoutConstraint(item: self.activityIndicatorView, attribute: .CenterY, relatedBy: .Equal, toItem: self.statusImageView, attribute: .CenterY, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: self.activityIndicatorView, attribute: .CenterX, relatedBy: .Equal, toItem: self.statusImageView, attribute: .CenterX, multiplier: 1.0, constant: 0.0),
                
                NSLayoutConstraint(item: self.nameLabel, attribute: .Top, relatedBy: .Equal, toItem: self.contentView, attribute: .Top, multiplier: 1.0, constant: 10.0),
                NSLayoutConstraint(item: self.nameLabel, attribute: .Leading, relatedBy: .Equal, toItem: self.statusImageView, attribute: .Trailing, multiplier: 1.0, constant: 15.0),
                NSLayoutConstraint(item: self.nameLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self.contentView, attribute: .Trailing, multiplier: 1.0, constant: -10.0),
                
                NSLayoutConstraint(item: self.statusLabel, attribute: .Top, relatedBy: .Equal, toItem: self.nameLabel, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: self.statusLabel, attribute: .Leading, relatedBy: .Equal, toItem: self.statusImageView, attribute: .Trailing, multiplier: 1.0, constant: 15.0),
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
            .subscribe({ (_) in
                self.reloadData()
            })
            .addDisposableTo(rx_disposeBag)
    }

}

extension PackageTableViewCell {
    private func reloadData() {
        self.nameLabel.text = self.viewModel.name()
        self.statusLabel.text = self.viewModel.status()
        self.setupPackageStatusImageView()
        
        self.setNeedsUpdateConstraints()
        self.updateConstraintsIfNeeded()
    }
    
    private func setupPackageStatusImageView() {
        if self.viewModel.completed() {
            self.updating.value = false
            self.statusImageView.image = UIImage(named: "deliveredIcon")!
            self.statusImageView.backgroundColor = ColorPalette.SeaGreenMedium
        } else {
            self.updating.value = self.viewModel.updating()
            self.statusImageView.image = UIImage(named: "inTransitIcon")!
            self.statusImageView.backgroundColor = ColorPalette.Raven
        }
    }
}
