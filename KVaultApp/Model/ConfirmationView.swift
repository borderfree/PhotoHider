//
//  ConfirmationView.swift
//  TODOAPP
//
//  Created by Macbook Pro on 26/02/2021.
//  Copyright © 1940 Macbook Pro. All rights reserved.
//

import UIKit

class ConfirmationView: UIView {

    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var btnNo: UIButton!
    @IBOutlet weak var txtPassword: UITextField!
    
    override func awakeFromNib() {
        self.btnNo.callBackTarget {[weak self] (sender) in
            self?.fadeOut( completion: { (isCompleted) in
                self?.removeFromSuperview()
            })
        }
    }
    
    deinit {
        print("Confiremation removed")
    }
    
}
