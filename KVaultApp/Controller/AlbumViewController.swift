//
//  AlbumViewController.swift
//  KVaultApp
//
//  Created by Fetih Tunay on 22/02/2021.
//  Copyright © Fetih Tunay. All rights reserved.
//

import UIKit

class AlbumViewController: UIViewController, AddAlbumDelegate {
   

    @IBOutlet weak var tblViewAlbum : UITableView?
    @IBOutlet weak var bannerView: GADBannerView!
    
    var arrAlbums = [AlbumModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblViewAlbum?.tableFooterView = UIView()
        APPDELEGATE.setupBannerView(bannerView, viewController: self)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getDataFromDB()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PushToAddAlbum"{
            if let addAlbumVC = segue.destination as? AddAlbumViewController{
                addAlbumVC.delegate = self
                if let indexPath = sender as? IndexPath{
                    addAlbumVC.objAlbum = arrAlbums[indexPath.row]
                }
            }
        }
    }
    
    func addAlbumSuccessfully() {
        self.getDataFromDB()
    }
    
    
    func getDataFromDB(){
       let arrData = DBManager.sharedInstance.getAllDataFromDB(withTableName: DBTableAlbum)
        print(arrData)
        if arrData.count > 0{
            self.arrAlbums = Mapper<AlbumModel>().mapArray(JSONArray: arrData)
        }
        self.tblViewAlbum?.reloadData()
    }
}

extension AlbumViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrAlbums.count == 0 ? 1 : arrAlbums.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if arrAlbums.count == 0{
            var cell = tableView.dequeueReusableCell(withIdentifier: "EmptyTableViewCell") as? EmptyTableViewCell
            if cell == nil{
                cell  = EmptyTableViewCell.emptyCell()
            }
            cell?.lblMessage.text = "No Album Available"
            return cell!
        }
        let identifier = "AlbumTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? AlbumTableViewCell
        let objAlbum = arrAlbums[indexPath.row]
        cell?.imgAlbum.image = objAlbum.image
        cell?.lblAlbumName.text = objAlbum.albumName
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if arrAlbums.count > 0{
            let objAlbum = arrAlbums[indexPath.row]
            if !objAlbum.albumPassword.isEmpty(){ // password protected folder
                self.showAlbumPasswordView(objAlbum)
            }
            else{
                self.view.window?.endEditing(true)
                self.pushToGalleryView(objAlbum)
            }
        }
    }
    
    func showAlbumPasswordView(_ objAlbum : AlbumModel){
        if let confirmation  = ConfirmationView().loadNib() as? ConfirmationView{
            confirmation.frame = UIScreen.main.bounds
            APPDELEGATE.window?.addSubview(confirmation)
            confirmation.isHidden = true
            confirmation.fadeIn()
            confirmation.btnSubmit.callBackTarget {[weak self] (sender) in
                if confirmation.txtPassword.text != objAlbum.albumPassword{ // failed
                    UtilityClass.showAlertOnNavigationBarWith(message: "Password doesn't match", title: nil, alertStyle: .danger)
                    confirmation.txtPassword.text = ""
                }
                else{ // success password
                    confirmation.txtPassword.resignFirstResponder()
                    confirmation.fadeOut()
                    self?.pushToGalleryView(objAlbum)
                    
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if arrAlbums.count == 0{
            return tableView.frame.size.height
        }
        return 100
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if arrAlbums.count == 0{
            return nil
        }
        let action1 = UITableViewRowAction(style: .default, title: "Delete", handler: {
            (action, indexPath) in
            UtilityClass.showAlertWithMessage(message: "Are you sure to delete this album?", title: "Secret Photo Vault App", cancelButtonTitle: "Cancel", doneButtonTitle: "Yes", secondButtonTitle: nil, alertType: .actionSheet, callback: {[weak self] (isConfirm) -> (Void) in
                if isConfirm{
                    DBManager.sharedInstance.deleteRow(rowName: DBRowID, rowID: self?.arrAlbums[indexPath.row].id ?? "", withTableName: DBTableAlbum, callBack: { (isSuccess) in
                        
                        self?.arrAlbums.remove(at: indexPath.row)
                        if self?.arrAlbums.count == 0{
                            self?.tblViewAlbum?.reloadData()
                        }
                        else{
                            self?.tblViewAlbum?.deleteRows(at: [indexPath], with: .fade)
                        }
                    })
                }
            })
        })
        action1.backgroundColor = UIColor.red
        
        let action2 = UITableViewRowAction(style: .default, title: "Edit", handler: {[weak self]
            (action, indexPath) in
            self?.performSegue(withIdentifier: "PushToAddAlbum", sender: indexPath)
        })
        action2.backgroundColor = UIColor.init(hexFromString: "87dfc1")
        return [action2, action1]
    }
    
    
    func pushToGalleryView(_ objAlbum : AlbumModel){
        if let galleryVC = self.storyboard?.instantiateViewController(withIdentifier: "UploadFileViewController") as? UploadFileViewController{
            galleryVC.objAlbum = objAlbum
            self.navigationController?.pushViewController(galleryVC, animated: true)
        }
    }
}


class  AlbumTableViewCell : UITableViewCell{
    @IBOutlet weak var lblAlbumName : UILabel!
    @IBOutlet weak var imgAlbum : UIImageView!

    
    override func awakeFromNib() {}
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
}


class AlbumModel : Mappable{
    var albumName  = ""
    var albumImg  = ""
    var albumPassword  = ""
    var id  = ""
    var image : UIImage?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        albumName <- map[DBAlbumName]
        albumName = albumName.capitalized
        albumImg <- map[DBAlbumImage]
        albumPassword <- map[DBAlbumPassword]
        id = map.JSON.string(forKey: DBRowID)

        image = UIImage.init(named: "Ic_folder")  // UIImage.init(contentsOfFile: documentPathWithFileName(fileName: albumImg).path) ?? UIImage.init(named: "placeholder")
    }
}
