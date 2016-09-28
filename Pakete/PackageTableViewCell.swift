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

    fileprivate var activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    fileprivate var didSetupConstraints = false
    fileprivate var viewModel: PackageViewModel!
    fileprivate let updating: Variable<Bool> = Variable(false)

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.accessoryType = .disclosureIndicator
        self.layer.rasterizationScale = UIScreen.main.scale
        self.layer.shouldRasterize = true

        self.statusImageView.translatesAutoresizingMaskIntoConstraints = false
        self.statusImageView.layer.cornerRadius = 18.0
        self.statusImageView.contentMode = .center
        self.contentView.addSubview(self.statusImageView)

        self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.activityIndicatorView)

        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.nameLabel.font = UIFont.systemFont(ofSize: 16.0)
        self.nameLabel.adjustFontToRealIPhoneSize = true
        self.nameLabel.numberOfLines = 0
        self.contentView.addSubview(self.nameLabel)

        self.statusLabel.translatesAutoresizingMaskIntoConstraints = false
        self.statusLabel.font = UIFont.systemFont(ofSize: 14.0)
        self.statusLabel.textColor = .gray
        self.statusLabel.numberOfLines = 0
        self.statusLabel.adjustFontToRealIPhoneSize = true
        self.contentView.addSubview(self.statusLabel)

        self.updating.asObservable()
            .bindTo(self.activityIndicatorView.rx.animating)
            .addDisposableTo(rx_disposeBag)

        self.updating.asObservable()
            .bindTo(self.statusImageView.rx.hidden)
            .addDisposableTo(rx_disposeBag)
    }

    override func updateConstraints() {
        if !self.didSetupConstraints {
            NSLayoutConstraint.activate([
                NSLayoutConstraint(item: self.statusImageView, attribute: .centerY, relatedBy: .equal, toItem: self.contentView, attribute: .centerY, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: self.statusImageView, attribute: .left, relatedBy: .equal, toItem: self.contentView, attribute: .left, multiplier: 1.0, constant: 15.0),
                NSLayoutConstraint(item: self.statusImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 36.0),
                NSLayoutConstraint(item: self.statusImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 36.0),

                NSLayoutConstraint(item: self.activityIndicatorView, attribute: .centerY, relatedBy: .equal, toItem: self.statusImageView, attribute: .centerY, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: self.activityIndicatorView, attribute: .centerX, relatedBy: .equal, toItem: self.statusImageView, attribute: .centerX, multiplier: 1.0, constant: 0.0),

                NSLayoutConstraint(item: self.nameLabel, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1.0, constant: 10.0),
                NSLayoutConstraint(item: self.nameLabel, attribute: .leading, relatedBy: .equal, toItem: self.statusImageView, attribute: .trailing, multiplier: 1.0, constant: 15.0),
                NSLayoutConstraint(item: self.nameLabel, attribute: .trailing, relatedBy: .equal, toItem: self.contentView, attribute: .trailing, multiplier: 1.0, constant: -10.0),

                NSLayoutConstraint(item: self.statusLabel, attribute: .top, relatedBy: .equal, toItem: self.nameLabel, attribute: .bottom, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: self.statusLabel, attribute: .leading, relatedBy: .equal, toItem: self.statusImageView, attribute: .trailing, multiplier: 1.0, constant: 15.0),
                NSLayoutConstraint(item: self.statusLabel, attribute: .trailing, relatedBy: .equal, toItem: self.contentView, attribute: .trailing, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: self.statusLabel, attribute: .bottom, relatedBy: .equal, toItem: self.contentView, attribute: .bottom, multiplier: 1.0, constant: -10.0)
            ])
            self.didSetupConstraints = true
        }

        super.updateConstraints()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.activityIndicatorView.stopAnimating()
        self.accessoryType = .disclosureIndicator
        self.rx_disposeBag = DisposeBag()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(withViewModel viewModel: PackageViewModel) {
        self.viewModel = viewModel
        self.viewModel.package.asObservable()
            .subscribe({ [unowned self] _ in
                self.reloadData()
            })
            .addDisposableTo(rx_disposeBag)
    }

}

extension PackageTableViewCell {
    fileprivate func reloadData() {
        self.nameLabel.text = self.viewModel.name()
        self.statusLabel.text = self.viewModel.status()
        self.setupPackageStatusImageView()

        self.setNeedsUpdateConstraints()
        self.updateConstraintsIfNeeded()
    }

    fileprivate func setupPackageStatusImageView() {
        if self.viewModel.completed() {
            self.updating.value = false
            self.statusImageView.image = UIImage(named: "deliveredIcon")
            self.statusImageView.backgroundColor = ColorPalette.SeaGreenMedium
        } else {
            self.updating.value = self.viewModel.updating()
            self.statusImageView.image = UIImage(named: "inTransitIcon")
            self.statusImageView.backgroundColor = ColorPalette.Raven
        }
    }
}
