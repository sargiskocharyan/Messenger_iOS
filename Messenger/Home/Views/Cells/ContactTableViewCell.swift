//
//  ContactTableViewCell.swift
//  Messenger
//
//  Created by Employee1 on 6/4/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var lastnameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contactImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        changeShapeOfImageView()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func changeShapeOfImageView() {
        contactImageView.clipsToBounds = true
        contactImageView.layer.cornerRadius = 25
    }
    
    func configure(contact: User) {
        contactImageView.image = UIImage(named: "noPhoto")
        ImageCache.shared.getImage(url: contact.avatarURL ?? "", id: contact._id!) { (image) in
            DispatchQueue.main.async {
                self.contactImageView.image = image
            }
        }
        if contact.name != nil && contact.lastname != nil {
            nameLabel.textColor = UIColor(named: "color")
            nameLabel.text = contact.name
            lastnameLabel.textColor = UIColor(named: "color")
            lastnameLabel.text = contact.lastname
        } else if contact.name != nil && contact.lastname == nil {
            nameLabel.textColor = UIColor(named: "color")
            nameLabel.text = contact.name
            lastnameLabel.text = ""
        } else if contact.lastname != nil && contact.name == nil {
            nameLabel.textColor = UIColor(named: "color")
            nameLabel.text = contact.lastname
        } else {
            nameLabel.text = ""
            lastnameLabel.text = ""
        }
        if contact.username != nil {
            usernameLabel.text = contact.username
            usernameLabel.textColor = UIColor(named: "color")
        } else {
            usernameLabel.text = "Method's user"
        }
    }
}
