//
//  EmptyTableViewCell.swift
//  DealsOnAir
//
//  Created by SearchNative-iOS1 on 21/09/17.
//  Copyright © 2017 SearchNative-iOS1. All rights reserved.
//

import UIKit

class EmptyTableViewCell: UITableViewCell {

    @IBOutlet weak var lblMessage: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    class func emptyCell() -> EmptyTableViewCell{
       return  (UINib(nibName: "EmptyTableViewCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? EmptyTableViewCell)!
    }
    
}
