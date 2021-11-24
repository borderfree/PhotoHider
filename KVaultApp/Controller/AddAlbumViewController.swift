//
//  AddAlbumViewController.swift
//  KVaultApp
//
//  Created by Fetih Tunay on 22/02/2021.
//  Copyright © Fetih Tunay. All rights reserved.
//

import UIKit

protocol AddAlbumDelegate : class {
    func addAlbumSuccessfully()
}

class AddAlbumViewController: UIViewController {
    
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtAlbumName: UITextField!
    var objAlbum : AlbumModel?
    weak var delegate : AddAlbumDelegate?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = objAlbum == nil ?  "Add Album" : "Edit Album"
        self.txtAlbumName.text = objAlbum?.albumName
        self.txtPassword.text = objAlbum?.albumPassword
        self.txtConfirmPassword.text = txtPassword.text
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func ClickOnDone(_ sender: Any) {
        if txtAlbumName.text?.isEmpty() ?? true{
            UtilityClass.showAlertOnNavigationBarWith(message: "Please enter album name", title: " Secret Photo", alertStyle: .danger)
            return
        }
        if !(txtPassword.text?.isEmpty() ?? true){
            if txtConfirmPassword.text?.isEmpty() ?? true{
                UtilityClass.showAlertOnNavigationBarWith(message: "Please enter confirm password", title: "Secret Photo", alertStyle: .danger)
                return
            }
            if txtPassword.text != txtConfirmPassword.text{
                UtilityClass.showAlertOnNavigationBarWith(message: "Both passwords does not match", title: "Secret Photo", alertStyle: .danger)
                return
            }
        }
        
        APPDELEGATE.showFullScreenAd {[weak self] (issuccess) in
            if self?.objAlbum != nil{
                DBManager.sharedInstance.updateMultipleRowValues(withTableName: DBTableAlbum, withParameter: [DBAlbumImage : "", DBAlbumName : self?.txtAlbumName.text ?? "", DBAlbumPassword : self?.txtPassword.text ?? ""], rowID: self?.objAlbum?.id ?? "", rowName: DBRowID) {[weak self] (success) in
                    if success{
                        UtilityClass.showAlertOnNavigationBarWith(message: "Album update successfully", title: "Secret Photo", alertStyle: .success)
                        self?.navigationController?.popViewController(animated: true)
                        self?.delegate?.addAlbumSuccessfully()
                    }
                }
                return
            }
            
            DBManager.sharedInstance.insertDataInDB(withArray: [[DBAlbumImage : "", DBAlbumName : self?.txtAlbumName.text ?? "", DBAlbumPassword : self?.txtPassword.text ?? ""]], withTableName: DBTableAlbum) {[weak self] (success) in
                self?.navigationController?.popViewController(animated: true)
                self?.delegate?.addAlbumSuccessfully()
            }
        }
    }
}
