//
//  messagesTableViewCell.swift
//  GradesAssistant
//
//  Created by Ahmed Khattab on 8/26/19.
//  Copyright © 2019 AhmedKhattab. All rights reserved.
//

import UIKit

class messagesTableViewCell: UITableViewCell {

    let messageLabel = UILabel()
    let messageBackground = UIView()
    var leadingConstraint : NSLayoutConstraint!
    var tralingConstraint : NSLayoutConstraint!
    var sender:Bool!{
        didSet{
            messageBackground.backgroundColor = sender ? .white : .yellow
            if sender {
                leadingConstraint.isActive = true
                tralingConstraint.isActive = false
            }else{
                leadingConstraint.isActive = false
                tralingConstraint.isActive = true
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier:reuseIdentifier)
        
        backgroundColor = .clear
        messageBackground.layer.cornerRadius = 14
        addSubview(messageBackground)
        addSubview(messageLabel)
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageBackground.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant:32),
          
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant:-32),
            messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
            
            messageBackground.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant:-16),
            messageBackground.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant:-16),
            messageBackground.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant:16),
            messageBackground.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant:16)
        ]
        NSLayoutConstraint.activate(constraints)
        leadingConstraint =   messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant:32)
        tralingConstraint =   messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant:-32)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
