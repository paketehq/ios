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
        self.selectionStyle = .None
        
        self.textField.translatesAutoresizingMaskIntoConstraints = false
        self.textField.placeholder = "Placeholder"
        self.textField.clearButtonMode = .WhileEditing
        self.textField.font = UIFont.systemFontOfSize(16.0)
        self.contentView.addSubview(self.textField)
        NSLayoutConstraint.activateConstraints([
            NSLayoutConstraint(item: self.textField, attribute: .Top, relatedBy: .Equal, toItem: self.contentView, attribute: .Top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.textField, attribute: .Bottom, relatedBy: .Equal, toItem: self.contentView, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.textField, attribute: .Leading, relatedBy: .Equal, toItem: self.contentView, attribute: .Leading, multiplier: 1.0, constant: 15.0),
            NSLayoutConstraint(item: self.textField, attribute: .Trailing, relatedBy: .Equal, toItem: self.contentView, attribute: .Trailing, multiplier: 1.0, constant: -15.0)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
