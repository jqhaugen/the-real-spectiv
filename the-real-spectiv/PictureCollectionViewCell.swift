//
//  PictureCollectionViewCell.swift
//  spectiv1
//
//  Created by Jason Haugen on 11/10/16.
//  Copyright © 2016 Jason Haugen. All rights reserved.
//

import UIKit
import Firebase

class PictureCollectionViewCell: UICollectionViewCell {
    
    let rootRef = FIRDatabase.database().reference()
    @IBOutlet weak var theImage: UIImageView!
    
    
}
