//
//  WallPostCell.swift
//  VKWallParser
//
//  Created by Admin on 22/07/2018.
//  Copyright © 2018 nikitagorshkov. All rights reserved.
//

import UIKit

class WallPostCell: UITableViewCell {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var postText: UILabel!
    
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var repostsLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    
    @IBOutlet weak var imagesView: UIView!
    @IBOutlet weak var imagesViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var audioView: UIView!
    @IBOutlet weak var audioViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var audioAndImagesDist: NSLayoutConstraint!
    @IBOutlet weak var postTextAndImagesDist: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
