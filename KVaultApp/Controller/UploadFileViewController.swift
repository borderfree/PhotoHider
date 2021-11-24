//
//  UploadFileViewController.swift
//  KVaultApp
//
//  Created by Fetih Tunay on 22/02/2021.
//  Copyright © Fetih Tunay. All rights reserved.
//

import UIKit
import TLPhotoPicker
import Photos
import AVKit
import AVFoundation
@_exported import GoogleMobileAds

class UploadFileViewController: UIViewController, TLPhotosPickerViewControllerDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var collectionView : UICollectionView!
    var objAlbum : AlbumModel?
    var selectedAssets = [TLPHAsset]()
    var arrGallery = [GalleryModel]()
    var interstitial: GADInterstitial?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        APPDELEGATE.setupBannerView(bannerView, viewController: self)

        self.title = objAlbum?.albumName.capitalized
        self.getGalleryDataFromDB()
        collectionView.register(UINib(nibName: "EmptyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "EmptyCollectionViewCell")
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(gestureReconizer:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.collectionView.addGestureRecognizer(lpgr)
        // Do any additional setup after loading the view.
    }
    
    @objc  func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizer.State.ended {
            return
        }
        if arrGallery.count == 0{
            return
        }
        
        let p = gestureReconizer.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: p)
        
        if let index = indexPath {
            UtilityClass.showAlertWithMessage(message: "Are you sure to delete this Photo?", title: "Secret Photo Vault App", cancelButtonTitle: "Cancel", doneButtonTitle: "Yes", secondButtonTitle: nil, alertType: .actionSheet, callback: {[weak self] (isConfirm) -> (Void) in
                if isConfirm{
                    DBManager.sharedInstance.deleteRow(rowName: DBRowID, rowID: self?.arrGallery[index.row].galeryId ?? "", withTableName: DBTableGallery, callBack: { (isSuccess) in
                        UtilityClass.removeFileToDocumentDirectoryWithName(name: self?.arrGallery[index.row].imgName ?? "")
                        self?.arrGallery.remove(at: index.row)
                        self?.collectionView?.reloadData()
//                        if self?.arrGallery.count == 0{
//                            self?.collectionView?.reloadData()
//                        }
//                        else{
//                            self?.collectionView?.deleteItems(at: [index])
//                        }
                    })
                }
            })
            
            
        } else {
            print("Could not find index path")
        }
    }
    
    func getGalleryDataFromDB(){
        let arrData = DBManager.sharedInstance.getDataFromDB(withTableName: DBTableGallery, withFieldName: DBAlbumID, withFieldValue: objAlbum?.id ?? "")
        if arrData.count > 0{
            self.arrGallery = Mapper<GalleryModel>().mapArray(JSONArray: arrData)
        }
        self.collectionView.reloadData()
    }
    
    @IBAction func clickOnAddPhotos(_ sender: Any) {
        let viewController = TLPhotosPickerViewController()
        viewController.delegate = self
        let configure = TLPhotosPickerConfigure()
        viewController.configure = configure
        //configure.nibSet = (nibName: "CustomCell_Instagram", bundle: Bundle.main) // If you want use your custom cell..
        self.present(viewController, animated: true, completion: nil)
    }
    
    
    //TLPhotosPickerViewControllerDelegate
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        // use selected order, fullresolution image
        self.selectedAssets = withTLPHAssets
    }
    func dismissPhotoPicker(withPHAssets: [PHAsset]) {
        // if you want to used phasset.
        for (_,assets) in withPHAssets.enumerated(){
            
            if assets.mediaType == .image{
                assets.requestContentEditingInput(with: PHContentEditingInputRequestOptions()) {[weak self] (input, userInfo) in
                    
                    let timeString = UtilityClass.timeStampString()
                    let imageName =  timeString + ".png"
                    if let url = input?.fullSizeImageURL{
                        if let data = try? Data(contentsOf: url)
                        {
                            UtilityClass.saveFileToDocumentDirectoryWithName(name: imageName, mediaData: data)
                            let dict = [DBGalleryImageName : imageName, DBAlbumID : self?.objAlbum?.id ?? "", DBTimestamp : timeString]
                            if  let objGallery = Mapper<GalleryModel>().map(JSON: dict){
                                self?.arrGallery.append(objGallery)
                            }
                            DBManager.sharedInstance.insertDataInDB(withArray:[dict ], withTableName: DBTableGallery, callBack: { (isSuccess) in
                                print("image data added")
                            })
                        }
                    }
                    self?.collectionView.reloadData()
                }
            }
            else if assets.mediaType == .video{
                PHImageManager.default().requestAVAsset(forVideo: assets, options: PHVideoRequestOptions()) {[weak self] (avasset, audioMix, userinfo) in
                    if let urlAssets = avasset as? AVURLAsset{
                        let url = urlAssets.url
                        let timeString = UtilityClass.timeStampString()
                        let videoName =  timeString + "." + url.pathExtension
                        let videoThumbName =  timeString + ".png"

                        if let data = try? Data(contentsOf: url)
                        {
                            //save video
                            UtilityClass.saveFileToDocumentDirectoryWithName(name: videoName, mediaData: data)
                            
                            //thumb image
                            if let thumbData = url.generateThumbnail().jpegData(compressionQuality: 0.5){
                                UtilityClass.saveFileToDocumentDirectoryWithName(name: videoThumbName, mediaData: thumbData)
                            }

                            let dict = [DBGalleryImageName : videoName, DBAlbumID : self?.objAlbum?.id ?? "", DBTimestamp : timeString, DBVideoThumbName : videoThumbName]
                            if  let objGallery = Mapper<GalleryModel>().map(JSON: dict){
                                self?.arrGallery.append(objGallery)
                            }
                            DBManager.sharedInstance.insertDataInDB(withArray:[dict ], withTableName: DBTableGallery, callBack: { (isSuccess) in
                                print("image data added")
                            })
                        }
                    }
                    DispatchQueue.main.async {
                        self?.collectionView.reloadData()
                    }
                }
            }
        }
        
        
        UtilityClass.showAlertWithMessage(message: "Your photos successfully imported into the Secret Photo Vault App. \n\n Would you like to delete them from the Photos app?", title: "Success Import", cancelButtonTitle: "Cancel", doneButtonTitle: "Delete", secondButtonTitle: nil, alertType: .alert) { (isSuccess) -> (Void) in
            if isSuccess{
                PHPhotoLibrary.shared().performChanges( {
                    PHAssetChangeRequest.deleteAssets(withPHAssets as NSFastEnumeration)},
                                                        completionHandler: {
                                                            success, error in
                                                            print(success)
                                                            print(error?.localizedDescription)
                })
                
            }
        }
    }
    func photoPickerDidCancel() {
        // cancel
    }
    func dismissComplete() {
        // picker viewcontroller dismiss completion
    }
    func canSelectAsset(phAsset: PHAsset) -> Bool {
        //Custom Rules & Display
        //You can decide in which case the selection of the cell could be forbidden.
        return true
    }
    
    func didExceedMaximumNumberOfSelection(picker: TLPhotosPickerViewController) {
        // exceed max selection
    }
    func handleNoAlbumPermissions(picker: TLPhotosPickerViewController) {
        // handle denied albums permissions case
    }
    func handleNoCameraPermissions(picker: TLPhotosPickerViewController) {
        // handle denied camera permissions case
    }
    
}

extension UploadFileViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  arrGallery.count  == 0 ? 1 : arrGallery.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if  self.arrGallery.count == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCollectionViewCell", for: indexPath) as? EmptyCollectionViewCell
            cell?.strMessage  = "No Media Available\nAdd From Gallery"
            return cell!
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath ) as? GalleryCell
        cell?.imgGallery.image = arrGallery[indexPath.row].image
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if arrGallery.count > 0{
            let objGalley = arrGallery[indexPath.row]
            if objGalley.isVideo{
                let playerController = AVPlayerViewController()
                let player = AVPlayer(url: URL(fileURLWithPath: ( documentPathWithFileName(fileName: objGalley.imgName).path) ))
                playerController.player = player
                present(playerController, animated: true)
                player.play()
            }
            else{
                let imageViewerVc = self.storyboard?.instantiateViewController(withIdentifier: "ImageViewerController") as! ImageViewerController
                imageViewerVc.objUploadMedia = objGalley
                self.navigationController?.pushViewController(imageViewerVc, animated: true)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if  self.arrGallery.count == 0{
            return CGSize(width: CGFloat(collectionView.frame.size.width - 5 ), height: CGFloat(collectionView.frame.size.height))
        }
        return CGSize.init(width: collectionView.frame.size.width/4 - 5, height: collectionView.frame.size.width/4 - 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

class GalleryCell: UICollectionViewCell {
    @IBOutlet weak var imgGallery : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}


class GalleryModel : Mappable{
    var imgName  = ""
    var timestamp  = ""
    var albumID  = ""
    var galeryId = ""
    var thumbImg = ""
    var image : UIImage?
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        imgName <- map[DBGalleryImageName]
        timestamp <- map[DBTimestamp]
        albumID <- map[DBAlbumID]
        galeryId <- (map[DBRowID], StringTransform())
        thumbImg <- map[DBVideoThumbName]

        image = UIImage.init(contentsOfFile: documentPathWithFileName(fileName: imgName).path) ?? UIImage.init(named: "placeholder")
        if thumbImg.count > 0{
            image = UIImage.init(contentsOfFile: documentPathWithFileName(fileName: thumbImg).path) ?? UIImage.init(named: "placeholder")
        }
    }
    
    var isVideo : Bool{
        return thumbImg.count > 0
    }
    
}
