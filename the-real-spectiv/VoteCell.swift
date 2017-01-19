//
//  VoteCell.swift
//  the-real-spectiv
//
//  Created by Labuser on 11/18/16.
//  Copyright © 2016 Jason Haugen. All rights reserved.
//

import UIKit

class VoteCell: UICollectionViewCell {
    
    @IBOutlet weak var voteImageView: UIImageView!
    @IBOutlet weak var searchImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    var submitterName: String!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        searchImageView.sizeToFit()
        profileImageView.sizeToFit()
        voteImageView.sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
