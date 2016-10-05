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

    fileprivate var didSetupConstraints = false
    fileprivate let lineView = UIView()
    fileprivate let circleView = UIView()
    fileprivate let lineSeparatorView = UIView()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = ColorPalette.BlackHaze
        self.layer.rasterizationScale = UIScreen.main.scale
        self.layer.shouldRasterize = true

        self.lineView.translatesAutoresizingMaskIntoConstraints = false
        self.lineView.backgroundColor = ColorPalette.LavenderGray
        self.contentView.addSubview(self.lineView)

        self.circleView.translatesAutoresizingMaskIntoConstraints = false
        self.circleView.backgroundColor = ColorPalette.SeaGreenMedium
        self.circleView.layer.cornerRadius = 5.0
        self.contentView.addSubview(self.circleView)

        self.dateLabel.translatesAutoresizingMaskIntoConstraints = false
        self.dateLabel.font = UIFont.systemFont(ofSize: 12.0)
        self.dateLabel.textColor = .gray
        self.dateLabel.adjustFontToRealIPhoneSize = true
        self.contentView.addSubview(self.dateLabel)

        self.statusLabel.translatesAutoresizingMaskIntoConstraints = false
        self.statusLabel.font = UIFont.systemFont(ofSize: 14.0)
        self.statusLabel.numberOfLines = 0
        self.statusLabel.adjustFontToRealIPhoneSize = true
        self.contentView.addSubview(self.statusLabel)

        self.lineSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        self.lineSeparatorView.backgroundColor = ColorPalette.LavenderGray
        self.contentView.addSubview(self.lineSeparatorView)
    }

    override func updateConstraints() {
        if !self.didSetupConstraints {
            NSLayoutConstraint.activate([
                NSLayoutConstraint(item: self.lineView, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: self.lineView, attribute: .bottom, relatedBy: .equal, toItem: self.contentView, attribute: .bottom, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: self.lineView, attribute: .leading, relatedBy: .equal, toItem: self.contentView, attribute: .leading, multiplier: 1.0, constant: 15.0),
                NSLayoutConstraint(item: self.lineView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 1.0),

                NSLayoutConstraint(item: self.circleView, attribute: .centerY, relatedBy: .equal, toItem: self.dateLabel, attribute: .bottom, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: self.circleView, attribute: .centerX, relatedBy: .equal, toItem: self.lineView, attribute: .centerX, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: self.circleView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 10.0),
                NSLayoutConstraint(item: self.circleView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 10.0),

                NSLayoutConstraint(item: self.dateLabel, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1.0, constant: 10.0),
                NSLayoutConstraint(item: self.dateLabel, attribute: .leading, relatedBy: .equal, toItem: self.lineView, attribute: .leading, multiplier: 1.0, constant: 15.0),
                NSLayoutConstraint(item: self.dateLabel, attribute: .trailing, relatedBy: .equal, toItem: self.contentView, attribute: .trailing, multiplier: 1.0, constant: -15.0),

                NSLayoutConstraint(item: self.statusLabel, attribute: .top, relatedBy: .equal, toItem: self.dateLabel, attribute: .bottom, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: self.statusLabel, attribute: .leading, relatedBy: .equal, toItem: self.lineView, attribute: .leading, multiplier: 1.0, constant: 15.0),
                NSLayoutConstraint(item: self.statusLabel, attribute: .trailing, relatedBy: .equal, toItem: self.contentView, attribute: .trailing, multiplier: 1.0, constant: -15.0),
                NSLayoutConstraint(item: self.statusLabel, attribute: .bottom, relatedBy: .equal, toItem: self.contentView, attribute: .bottom, multiplier: 1.0, constant: -10.0),

                NSLayoutConstraint(item: self.lineSeparatorView, attribute: .top, relatedBy: .equal, toItem: self.statusLabel, attribute: .bottom, multiplier: 1.0, constant: 10.0),
                NSLayoutConstraint(item: self.lineSeparatorView, attribute: .leading, relatedBy: .equal, toItem: self.statusLabel, attribute: .leading, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: self.lineSeparatorView, attribute: .trailing, relatedBy: .equal, toItem: self.contentView, attribute: .trailing, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: self.lineSeparatorView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.5)
                ])
            self.didSetupConstraints = true
        }

        super.updateConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
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
