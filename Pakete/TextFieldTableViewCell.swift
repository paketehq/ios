//
//  TextFieldTableViewCell.swift
//  Pakete
//
//  Created by Royce Albert Dy on 14/03/2016.
//  Copyright © 2016 Pakete. All rights reserved.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell {

    static let reuseIdentifier = "TextFieldCell"

    let textField = UITextField()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none

        self.textField.translatesAutoresizingMaskIntoConstraints = false
        self.textField.placeholder = "Placeholder"
        self.textField.clearButtonMode = .whileEditing
        self.textField.font = UIFont.systemFont(ofSize: 16.0)
        self.textField.tintColor = ColorPalette.Matisse
        self.contentView.addSubview(self.textField)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: self.textField, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.textField, attribute: .bottom, relatedBy: .equal, toItem: self.contentView, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.textField, attribute: .leading, relatedBy: .equal, toItem: self.contentView, attribute: .leading, multiplier: 1.0, constant: 15.0),
            NSLayoutConstraint(item: self.textField, attribute: .trailing, relatedBy: .equal, toItem: self.contentView, attribute: .trailing, multiplier: 1.0, constant: -15.0)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
