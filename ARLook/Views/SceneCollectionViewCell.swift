//
//  SceneCollectionViewCell.swift
//  ARLook
//
//  Created by ChenWei on 2019/9/11.
//  Copyright © 2019 Jacob. All rights reserved.
//

import UIKit
import SceneKit

class SceneCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scnView: SCNView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
