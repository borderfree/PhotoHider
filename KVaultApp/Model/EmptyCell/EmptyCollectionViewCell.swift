//
//  EmptyCollectionViewCell.swift
//  Lime Diary
//
//  Created by SearchNative-iOS1 on 30/03/18.
//  Copyright © 2018 SearchNative-iOS1. All rights reserved.
//

import UIKit

class EmptyCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var lblMessage: UILabel!
    var strMessage : String!{
        willSet{
            lblMessage.text = newValue
            if !(UtilityClass.isInternetConnectedWith(isAlert: false)){
                lblMessage.text = "No Internet Connection"
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
