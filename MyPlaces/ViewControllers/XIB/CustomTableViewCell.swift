//
//  CustomTableViewCell.swift
//  MyPlaces
//
//  Created by Administrator on 27.10.2020.
//  Copyright © 2020 Administrator. All rights reserved.
//

import UIKit
import Cosmos

class CustomTableViewCell: UITableViewCell {

    @IBOutlet var imagePlace: UIImageView! {
        didSet {
            imagePlace.layer.cornerRadius = imagePlace.frame.size.height / 2
            imagePlace.clipsToBounds = true
        }
    }
    @IBOutlet var locationPlace: UILabel!
    @IBOutlet var namePlace: UILabel!
    @IBOutlet var typePlace: UILabel!    
    @IBOutlet var cosmosView: CosmosView! {
        didSet {
            cosmosView.settings.updateOnTouch = false
        }
    }
    
}
