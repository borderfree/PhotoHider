//
//  UtilityClass.swift
//  Centreel
//
//  Created by Fetih Tunay on 24/02/2021.
//  Copyright © Fetih Tunay. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Reachability
import Photos
import MobileCoreServices
@_exported import RxCocoa
@_exported import RxSwift
@_exported import ObjectMapper
@_exported import SwiftyPickerPopover
@_exported import Moya
@_exported import IQKeyboardManagerSwift
@_exported import NotificationBannerSwift
@_exported import Toast_Swift

class UtilityClass: NSObject {
    public typealias PopupOverHandler = (Int, String) -> Void
    public typealias PopupOverDatePickerHandler = (Date) -> Void
    typealias ImagePickerHander = ((_ chosenImage : UIImage?) -> Void)
    var videoPickerCompletionHandler : ((_ url: URL, _ data: Data, _ thumbnail: UIImage) -> Void)?

    var imagePickerCompletionHandler : ImagePickerHander?
    
    static let sharedInstance = UtilityClass()
    var pick = UIImagePickerController()
    
    
    //MARK Notification
    enum NotificationType : String {
        case orderDetail = "OrderDetail"
        case none = ""
        
        init(fromRawValue: String){
            self = NotificationType(rawValue: fromRawValue) ?? .none
        }
    }
    // handler for notification
    typealias  NotificationDataHandler = (_ type : NotificationType, _ data : [String : Any]?) -> Void
    var arrNotificationHandler : [NotificationDataHandler]?
    var notificationHandler : NotificationDataHandler?
    
    
    class func presentViewController(vc : UIViewController) -> Void{
        let viewController : UIViewController = (APPDELEGATE.window?.rootViewController)!
        vc.modalPresentationStyle = .overCurrentContext
        vc.popoverPresentationController?.sourceView = viewController.view
        vc.popoverPresentationController?.sourceRect = viewController.view.bounds
        vc.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        
        if (viewController.presentedViewController != nil)  {
            viewController.presentedViewController?.dismiss(animated: true, completion: {
            })
            viewController.present(vc, animated: true, completion: nil)
            
            //            viewController.presentedViewController?.present(vc, animated: true, completion: nil)
        }
        else{
            viewController.present(vc, animated: true, completion: nil)
        }
    }
    
    class func dismissViewController(){
        APPDELEGATE.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK :  Check InternetConectivity
    class func isInternetConnectedWith(isAlert: Bool) -> Bool{
        let reachability = Reachability.init(hostname: "www.google.com")!
        if reachability.connection == .none  && isAlert  {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                //                UtilityClass.showAlertOnNavigationBarWith(message: "Please check your internet connection.", title: "", alertType: .failure)
                UtilityClass.showToastMessage(message: "No internet connection")
                UtilityClass .removeActivityIndicator()
            }
        }
        return reachability.connection != .none
    }
}

// MARK: Alertview
extension UtilityClass{
    
    class func showAlertOnNavigationBarWith(message: String?, title: String?, alertStyle: BannerStyle){
        let banner = GrowingNotificationBanner(title: title, subtitle: message, style: alertStyle)
        banner.show()
      //  NotificationView.sharedInstance.show(title:  title, message: message, notificationType: alertType, autoHide: true, delayTime: 3)
    }
    
    class func showToastMessage(message : String){
        APPDELEGATE.window?.rootViewController?.view.makeToast(message)
      //  ToastView.sharedInstance.show(message: message, autoHide: true, delayTime: 3)
    }
    
    class func showToastMessage(message : String, withDelay: TimeInterval)
    {
        APPDELEGATE.window?.rootViewController?.view.makeToast(message, duration: withDelay)
    }
    
    class func showAlertWithMessage(message: String?, title: String?, cancelButtonTitle: String?, doneButtonTitle: String?, secondButtonTitle: String?, alertType : UIAlertController.Style, callback : @escaping (_ isConfirmed: Bool) -> (Void)) -> (Void){
        let alert : UIAlertController = UIAlertController.init(title: title, message: message, preferredStyle: alertType)
        //        if iPAD && alertType == .actionSheet
        //        {
        //            if let tabController = APPDELEGATE.tabBarController {
        //                alert.popoverPresentationController?.sourceView = tabController.topMostViewController().view
        //                alert.popoverPresentationController?.sourceRect = tabController.topMostViewController().view.bounds
        //                alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        //            }
        //
        //
        //        }
        if cancelButtonTitle?.isEmpty == false {
            let cancelButton : UIAlertAction = UIAlertAction.init(title: cancelButtonTitle, style: .cancel) { (action) in
                // callback(false)
            }
            alert .addAction(cancelButton)
            
        }
        if doneButtonTitle?.isEmpty == false {
            let yesButton : UIAlertAction = UIAlertAction.init(title: doneButtonTitle, style: .default) { (action) in
                callback(true)
            }
            alert .addAction(yesButton)
        }
        
        if secondButtonTitle?.isEmpty == false {
            let thirdButton : UIAlertAction = UIAlertAction.init(title: secondButtonTitle, style: .default) { (action) in
                callback(false)
            }
            alert .addAction(thirdButton)
        }
        
        self.presentViewController(vc: alert)
    }
   
    
   
}

// for activity indicator
extension UtilityClass{
    // MARK : Activity Indicatior
    static var activityView: UIView? = nil
    static var activityIndicatorView: NVActivityIndicatorView? = nil
    
    class func removeActivityIndicator() -> Void{
        activityView?.isHidden = true
        activityView?.removeFromSuperview()
        activityIndicatorView?.stopAnimating()
    }
    
    class func showActivityIndicator() {
        if !UtilityClass.isInternetConnectedWith(isAlert: false){
            UtilityClass.removeActivityIndicator()
            return
        }
        
        guard let window = APPDELEGATE.window else{
            return
        }
        
        if let activityView = activityView{
            DispatchQueue.main.async {
                window.addSubview(activityView)
                self.activityIndicatorView? .startAnimating()
                activityView.isHidden = false
            }
            
            return
        }
        
        activityView = UIView(frame: MAIN_SCREEN.bounds)
        activityView?.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.28)
        activityIndicatorView  =  NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50), type: .ballClipRotateMultiple, color: UIColor.init(hexFromString: "3867D5"), padding: 50)
        activityIndicatorView?.center = window.center
        activityView?.addSubview(activityIndicatorView!)
        window.addSubview(activityView!)
        activityIndicatorView? .startAnimating()
        activityView?.isHidden = false
    }
}

extension UtilityClass{ // for User
   
    class func getUserPin() -> String? {
        return CheckNullString(value: USERDEFAULTS.object(forKey: "userpin") ?? "")
    }

    class func loggedUserId() -> String {
        guard let userID = UtilityClass.getUserPin() else{
            return ""
        }
        return userID
    }

    class func isUserLoggedIN() -> Bool {
        return UtilityClass.loggedUserId().count > 0 ? true : false
    }
    
    func setUserPin(_ pin : String){
        USERDEFAULTS.set(pin, forKey: "userpin")
        USERDEFAULTS.synchronize()
    }
//
//    class func setUserInfo(_ objUserInfo: UserInfo) {
//        let jsonString = objUserInfo.toJSONString()
//        USERDEFAULTS.set(jsonString, forKey: "userinfos")
//        USERDEFAULTS.synchronize()
//    }
//
//    // for set auth key
    class func setOnboardingSeenFlag(isShow : Bool){
        USERDEFAULTS.set(isShow, forKey: "OnbaordingSeen")
        USERDEFAULTS.synchronize()
    }
    
    class func isOnboardingSeen() -> Bool {
        return USERDEFAULTS.bool(forKey: "OnbaordingSeen")
    }
//
//    class  func authenticationKey() -> String{
//        return CheckNullString(value: USERDEFAULTS.object(forKey: "AuthenticationKey") as Any)
//    }
//
//
    class func logout() {
        USERDEFAULTS.set(nil, forKey: "userpin")
    }
    
}


extension UtilityClass{
    class func showPopOverMenuWith(_ sender : UIView, title : String = "Select", selectedString : String = "", dataSources : [String]?, callBack : @escaping PopupOverHandler, cancelCallBack : (() -> ())? = nil){
        var selectString = selectedString
        guard let dataSource = dataSources else {
            return
        }
        if dataSource.count == 0{
            return
        }
        
        var  p = StringPickerPopover(title: title, choices: dataSource)
            .setDoneButton(action: {
                popover, selectedRow, selectedString in
                print("done row \(selectedRow) \(selectedString)")
                callBack(selectedRow, selectedString)
            })
            .setCancelButton(action: { _, _, _ in
                print("cancel")
                cancelCallBack?()
            })
        
        let filteredArray = dataSource.filter { $0.localizedCaseInsensitiveContains(selectedString)}
        if filteredArray.count > 0 {
            selectString = filteredArray.first!
        }
        if let index = dataSource.index(of: selectString){
            p = p.setSelectedRow(index)
        }
        
        
        
        if APPDELEGATE.window?.rootViewController?.presentedViewController != nil{
            p.appear(originView: sender, baseViewController: (APPDELEGATE.window?.rootViewController?.presentedViewController)!)
        }
        else{
            p.appear(originView: sender, baseViewController: (APPDELEGATE.window?.rootViewController)!)
        }
    }
    
    class func showDatePicker(_ sender : UIView, selectedDate : Date = Date(), minimnumDate : Date? = nil,  maximumDate : Date? = nil, callBack : @escaping PopupOverDatePickerHandler){
        var datePicker = DatePickerPopover(title: "DatePicker")
            .setDateMode(.date)
            .setSelectedDate(selectedDate)
            .setDoneButton(action: { popover, selectedDate in print("selectedDate \(selectedDate)")
                callBack(selectedDate)
            })
            .setCancelButton(action: { _, _ in print("cancel")})
        
        if let  minimnumDate = minimnumDate{
            datePicker = datePicker.setMinimumDate(minimnumDate)
        }
        if let  maxDate = maximumDate{
            datePicker = datePicker.setMaximumDate(maxDate)
        }
        datePicker.appear(originView: sender, baseViewController: (APPDELEGATE.window?.rootViewController)!)
    }
    
}


//MARK: Actionsheet With ImagePicker
extension UtilityClass :  UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func caputurePhoto(compeltionHandler: @escaping ImagePickerHander) -> Void {
        if UIImagePickerController.isSourceTypeAvailable(.camera) == false {
            UtilityClass.showAlertOnNavigationBarWith(message: "Device has no camera", title: "", alertStyle: .info)
            return;
        }
        AVCaptureDevice.requestAccess(for:AVMediaType.video) {[unowned self] (granted) in
            if granted {
                self.pick.sourceType = .camera
                self.pick.delegate = self
                self.pick.allowsEditing = true
                
                DispatchQueue.main.async {
                    self.imagePickerCompletionHandler = compeltionHandler
                    self.pick.mediaTypes = [kUTTypeImage as String]
                    UtilityClass.presentViewController(vc: self.pick)
                }
            }
            else{
                DispatchQueue.main.async {
                    UtilityClass.showAlertOnNavigationBarWith(message: "Please go to Settings and enable the camera for this app to use this feature.", title: "", alertStyle: .info)
                }
            }
        }
    }
    
    func selectVideo(compeltionHandler: @escaping (_ url: URL, _ data: Data, _ thumbnail: UIImage) -> (Void)) -> Void{
        videoPickerCompletionHandler = compeltionHandler
        pick.sourceType = .photoLibrary
        pick.mediaTypes = [kUTTypeMovie as String]
        
        pick.allowsEditing = true
        pick.delegate = self
        UtilityClass.presentViewController(vc: pick);
    }
    
    func selectPhoto(compeltionHandler: @escaping ImagePickerHander) -> Void {
        //        let vc = rootViewController
        PHPhotoLibrary.requestAuthorization({[unowned self]
            (newStatus) in
            if newStatus ==  PHAuthorizationStatus.authorized {
                DispatchQueue.main.async{
                    self.imagePickerCompletionHandler = compeltionHandler
                    self.pick.sourceType = .photoLibrary
                    self.pick.allowsEditing = true
                    self.pick.delegate = self
                    self.pick.mediaTypes = [kUTTypeImage as String]
                    UtilityClass.presentViewController(vc: self.pick)
                    // UtilityClass.presentViewController(vc: pick)
                }
            }
        })
    }
    
    func showActionSheetWithImageHanlder(compeltionHandler: @escaping (_ capturedImage : UIImage?) -> (Void)) -> Void {
        imagePickerCompletionHandler = compeltionHandler
        UtilityClass.showAlertWithMessage(message: Localization(localKey: ""), title: Localization(localKey: "Please select option"), cancelButtonTitle: Localization(localKey: "Cancel"), doneButtonTitle:  Localization(localKey: "From Camera"), secondButtonTitle: Localization(localKey: "From Library"), alertType: .actionSheet) { (isConfirmed) -> (Void) in
            if isConfirmed  {
                self.caputurePhoto(compeltionHandler: compeltionHandler)
            }
            else{
                self.selectPhoto(compeltionHandler: compeltionHandler)
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let mediaType = info[.mediaType] as? String
        
        if mediaType == kUTTypeMovie as String{
            let chosenVideo = info[UIImagePickerController.InfoKey.mediaURL] as! URL
            let videoData = try! Data(contentsOf: chosenVideo, options: [])
            let thumbnail = chosenVideo.generateThumbnail()
            if let videoHandler = videoPickerCompletionHandler{
                videoHandler(chosenVideo, videoData, thumbnail)
            }
        }
        else if mediaType == kUTTypeImage as String{
            if let chosenImage =  info[.editedImage] as? UIImage{
                if let imagePickerCompletionHandler = imagePickerCompletionHandler{
                    imagePickerCompletionHandler(chosenImage)
                }
            }
        }
        
        
//        if mediaType == kUTTypeImage as String{
//            if let chosenImage =  info[.editedImage] as? UIImage{
//                if let imagePickerCompletionHandler = imagePickerCompletionHandler{
//                    imagePickerCompletionHandler(chosenImage)
//                }
//            }
//        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    class func saveFileToDocumentDirectoryWithName(name : String, mediaData : Data) -> Void{
        
        // let documentsDirectoryURL = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        // create a name for your image
        // create a name for your image
        let fileURL =  documentPathWithFileName(fileName: name)
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try mediaData.write(to: fileURL)
                print("Image Added Successfully \(fileURL)")
            } catch {
                print(error)
            }
        } else {
            print("Image Not Added")
        }
    }
    
    class func removeFileToDocumentDirectoryWithName(name : String) -> Void{
     
        let fileURL =  documentPathWithFileName(fileName: name)
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(at: fileURL)
                print("Image Added Successfully \(fileURL)")
            } catch {
                print(error)
            }
        } else {
            print("Image Not Added")
        }
    }
    
    
    class func timeStampString() -> String{
        let date  = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'_'HH_mm_ss_SSSS"
        dateFormatter.timeZone = NSTimeZone(name: "GMT")! as TimeZone
        return dateFormatter.string(from: date)
    }
    
}

import UserNotifications

extension UtilityClass : UNUserNotificationCenterDelegate{
    func registerNotification(){
        if #available(iOS 10.0, *) {
            let center  = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                guard granted else { return }
                self.getNotificationSettings()
            }
        }
        else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    func getNotificationSettings() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                print("Notification settings: \(settings)")
                guard settings.authorizationStatus == .authorized else { return }
                DispatchQueue.main.async{
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("User Info = ",notification.request.content.userInfo)
        //  self.responseHandle(userInfo: notification.request.content.userInfo)
        completionHandler([.alert, .badge, .sound])
    }
    
    //Called to let your app know which action was selected by the user for a given notification.
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("User Info = ",response.notification.request.content.userInfo)
        self.responseHandle(userInfo: response.notification.request.content.userInfo)
        completionHandler()
    }
    
    func responseHandle(userInfo : [AnyHashable : Any]){
        print(userInfo)
       // if let aps = userInfo[AnyHashable("aps")] as? [String : Any] {
            NotificationCenter.default.post(name: .NewNotificationArrived, object: userInfo)
      //  }
    }
    
//    func getNotificationData(_ callBack : @escaping NotificationDataHandler){
//        //self.notificationHandler = callBack
//        if self.arrNotificationHandler == nil{
//            self.arrNotificationHandler = [NotificationDataHandler]()
//        }
//
//        self.arrNotificationHandler?.append(callBack)
//        NOTIFICATIONCENTER.addObserver(self, selector: #selector(self.notificationReceived(_:)), name: .NewNotificationArrived, object: nil)
//    }
    
    func getNotificationData(_ callback :@escaping (_ notification : Notification) -> Void){
        let testBlock: (Notification) -> Void = { noti in
            callback(noti)
        }
        NOTIFICATIONCENTER.addObserver(forName: .NewNotificationArrived, object: nil, queue: OperationQueue.main, using: testBlock)
    }
    
//    @objc func notificationReceived(_ objNotification : Notification){
//        if let dictAps = objNotification.object as? [String : Any]{
//            self.handleNotification(dictAps)
//        }
//    }
    
    @discardableResult
    func handleNotification(_ objNotification : [String : Any]?) -> (type : NotificationType, dict : [String : Any]?){
        if let dictAps = objNotification{
            let types = NotificationType.init(fromRawValue:  dictAps.string(forKey: "category"))
            if let dictAlert = dictAps["alert"] as? [String : Any]{
                if  types == .orderDetail{
                    if let objData = dictAlert["body"]  as? [String : Any]// check key exist or not and  if type is 'offer' then alert dict will be nil it is nil because we dont want application alert
                    {
                        if let dictOrder =  objData["msg"] as? [String : Any] // check type of object
                        {
                
                            return(types, dictOrder)
                        }
                    }
                }
            }

            return(types, nil) // default return nil
        }
        return(.none, nil) // default return nil

    }
    
    class func isNotificationEnable(callback : @escaping (_ isEnable : Bool) -> Void) -> Void{
        if #available(iOS 10.0, *) {
            let current = UNUserNotificationCenter.current()
            current.getNotificationSettings(completionHandler: { (settings) in
                if settings.authorizationStatus == .notDetermined {
                    callback(false)
                }
                if settings.authorizationStatus == .denied {
                    // User should enable notifications from settings & privacy
                    // show an alert or sth
                    callback(false)
                    
                }
                if settings.authorizationStatus == .authorized {
                    // It's okay, no need to request
                    callback(true)
                }
            })
        }
        else{
            let notificationType = UIApplication.shared.currentUserNotificationSettings?.types
            if notificationType?.rawValue == 0 {
                callback(false)
            } else {
                callback(true)
            }
        }
    }
}
