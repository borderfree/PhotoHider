//
//  EnterPinViewController.swift
//  KVaultApp
//
//  Created by Fetih Tunay on 21/02/2021.
//  Copyright © Fetih Tunay. All rights reserved.
//

import UIKit
@_exported import RxCocoa
@_exported import SimpleAnimation
import MessageUI

typealias EnterPinHandler = (_ success : Bool) -> Void

class EnterPinViewController: UIViewController {
    @IBOutlet weak var lblEnterPinScreen : UILabel?
    @IBOutlet weak var lblEnterPinMsg : UILabel?
    @IBOutlet weak var btnClear : UIButton?
    @IBOutlet weak var txtFirst : UITextField!
    @IBOutlet weak var txtSecond : UITextField!
    @IBOutlet weak var txtThird : UITextField!
    @IBOutlet weak var txtFourth : UITextField!
    @IBOutlet weak var pinKeyboardView : UIView!
    @IBOutlet weak var btnReset: UIButton!
    var pinHandler : EnterPinHandler?
    var pinDisposeBag = DisposeBag()
    let blueTextBGColor = UIColor.init(red: 0/255, green: 83/255, blue: 181/255, alpha: 1)
    var previousPin = ""
    @IBOutlet var arrButton : [UIButton]?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presentWithAnimation()
        self.handleClearButton()
        self.handlePinTextColor()
        self.handleNumberButtons()
        self.view.layoutIfNeeded()
        for button in arrButton! {
            button.layoutIfNeeded()
            button.cornerRadius = button.frame.width/2
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.resetUI()
    }
    
    func resetUI(){
        self.resetTexts()
        if UtilityClass.isUserLoggedIN(){
            self.lblEnterPinMsg?.text = "Please enter pin to continue using our app."
        }
        else{
            if previousPin.isEmpty(){
                self.lblEnterPinMsg?.text = "Enter pin to generate new pin to continue using our app."
            }
            else{
                self.lblEnterPinMsg?.text = "Enter confirm pin to generate new pin"
            }
        }
    }
    
    //for all animations
    func presentWithAnimation(){
        self.pinKeyboardView.fadeIn( delay:0.0, completion: nil)
        
        self.txtFirst.fadeIn( delay:0.2, completion: nil)
        self.txtSecond.fadeIn( delay:0.2, completion: nil)
        self.txtThird.fadeIn( delay:0.2, completion: nil)
        self.txtFourth.fadeIn( delay:0.2, completion: nil)
        
        self.lblEnterPinScreen?.bounceIn(from: .top,  delay: 0.3, completion: nil)
        self.lblEnterPinMsg?.bounceIn(from: .top,  delay: 0.3, completion: nil)
        // self.viewStoreSelection.bounceIn(from: .top,  delay: 0.2, completion: nil)
    }
    
    
    
    
    // pin verification logic
    func handlePinTextColor(){
        let isValidFirst =  txtFirst.rx.observe(String.self, "text").map { $0?.count ?? 0 > 0 } // add observer for track text changes
        isValidFirst.bind {[weak self] (isEnabled) in
            self?.txtFirst.backgroundColor = isEnabled ?  UIColor.white : UIColor.clear
            self?.txtFirst.borderWidth = isEnabled ? 0 : 2
            }.disposed(by: pinDisposeBag)
        
        let  isValidSecond =   txtSecond.rx.observe(String.self, "text").map { $0?.count ?? 0 > 0 }
        isValidSecond.bind { [weak self](isEnabled) in
            self?.txtSecond.backgroundColor = isEnabled ?  UIColor.white : UIColor.clear
            self?.txtSecond.borderWidth = isEnabled ? 0 : 2
            
            }.disposed(by: pinDisposeBag)
        
        let  isValidThird =  txtThird.rx.observe(String.self, "text").map { $0?.count ?? 0 > 0 }
        isValidThird.bind {[weak self] (isEnabled) in
            self?.txtThird.backgroundColor = isEnabled ? UIColor.white : UIColor.clear
            self?.txtThird.borderWidth = isEnabled ? 0 : 2
            
            }.disposed(by: pinDisposeBag)
        
        let  isValidFourth =  txtFourth.rx.observe(String.self, "text").map { $0?.count ?? 0 > 0 }
        isValidFourth.bind {[weak self] (isEnabled) in
            self?.txtFourth.backgroundColor = isEnabled ?  UIColor.white : UIColor.clear
            self?.txtFourth.borderWidth = isEnabled ? 0 : 2
            
            }.disposed(by: pinDisposeBag)
        
        let everythingValid = Observable.combineLatest(isValidFirst, isValidSecond, isValidThird, isValidFourth) { $0 && $1 && $2 && $3 }
            .share(replay: 1) // for validation all field
        
        everythingValid.bind {[weak self] (isValid) in
            if (isValid){ // all field are filled here
                self?.doVerifyPin()
            }
            }.disposed(by: pinDisposeBag)
    }
    
    // number pin actions
    func handleNumberButtons(){
        // manage all button action
        arrButton?.callBackTargetForCollections(closure: {[weak self] (button) in
            guard let strong = self else {return}
            if let emptyText = [strong.txtFirst, strong.txtSecond, strong.txtThird,strong.txtFourth].filter({$0?.isEmpty() ?? true}).first{
                emptyText?.text = button.titleLabel?.text
            }
        })
    }
    
    
    // clear button actions
    func handleClearButton(){
        self.btnClear?.rx.tap.asObservable()
            .subscribe (onNext: { [weak self] switchValue in
                // handle clear event
                // find filled textfield
                
                if let filledText = [self?.txtFirst, self?.txtSecond, self?.txtThird,self?.txtFourth].filter({!($0?.isEmpty() ?? true)}).last{
                    filledText?.text = ""
                }
            }).disposed(by: pinDisposeBag)
    }
    
    func doVerifyPin(){
        let pin =  "\(txtFirst.text ?? "")\(txtSecond.text ?? "")\(txtThird.text ?? "")\(txtFourth.text ?? "")"
        
        // confirm password
        if !previousPin.isEmpty(){
            if previousPin != pin {
                UtilityClass.showAlertOnNavigationBarWith(message: "Pin doesn't match", title: " Secret Photo", alertStyle:.danger)
                resetTexts()
                return
            }
            // success
            UtilityClass.sharedInstance.setUserPin(pin)
            self.clickOnReset(btnReset)

            UtilityClass.showAlertWithMessage(message: "Do you want to send pin as backup by email?  You have to remember your pin.", title: "Backup", cancelButtonTitle: nil, doneButtonTitle: "Yes, I want", secondButtonTitle: "No, I don't want", alertType: .alert) {[weak self] (isConfirmed) -> (Void) in
                if isConfirmed{
                    self?.sendBackupPinViaMail(pin)
                }
                else{
                    self?.dismiss(animated: true, completion: nil)
                    self?.pinHandler?(true)
                }
            }
            return
        }
        
        // Logged user
        if UtilityClass.isUserLoggedIN(){
            if pin == UtilityClass.getUserPin(){ // success verified again
                self.dismiss(animated: true, completion: nil)
                self.pinHandler?(true)
            }
            else{ // failure
                self.resetTexts()
            }
        }
        else{ // save first time pin
            self.btnReset.fadeIn()
            self.previousPin = pin
            resetUI()
        }
    }
    
    
    func sendBackupPinViaMail(_ pin : String) {
        if !MFMailComposeViewController.canSendMail() {
            return
        }
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        
        // Configure the fields of the interface.
        // composeVC.setToRecipients(["exampleEmail@email.com"])
        composeVC.setSubject("Secret Photo Pin Backup")
        composeVC.setMessageBody("Dear User,\n\n               Your Backup pin is \(pin).\n\nThank You", isHTML: false)
        
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func resetTexts(){
        self.txtFirst.text = ""
        self.txtSecond.text = ""
        self.txtThird.text = ""
        self.txtFourth.text = ""
    }
    
    @IBAction func clickOnReset(_ sender: UIButton) {
        self.previousPin = ""
        self.btnReset.fadeOut()
        self.resetUI()
    }
}

// This generic method for show pin screen with various typw


extension EnterPinViewController : MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if error == nil{
            switch(result){
                
            case .cancelled: break
            case .saved:
                UtilityClass.showAlertOnNavigationBarWith(message: "Your Backup pin saved successfully", title: "", alertStyle: .success)
            case .sent:
                UtilityClass.showAlertOnNavigationBarWith(message: "Your Backup pin sent successfully", title: "", alertStyle: .success)
            case .failed:
                self.sendMailAgainAlert()
                break
            }
            self.resetUI()
        }
        else{
           self.sendMailAgainAlert()
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    func sendMailAgainAlert(){
        // UtilityClass.showAlertOnNavigationBarWith(message: error?.localizedDescription, title: "Error", alertStyle: .danger)
        let pin =  "\(txtFirst.text ?? "")\(txtSecond.text ?? "")\(txtThird.text ?? "")\(txtFourth.text ?? "")"
        
        UtilityClass.showAlertWithMessage(message: "Something went to wrong! Do you want to resend pin as backup by email? you have to remember your pin.", title: "Backup", cancelButtonTitle: nil, doneButtonTitle: "Yes, I want", secondButtonTitle: "No, I don't want", alertType: .alert) {[weak self] (isConfirmed) -> (Void) in
            if isConfirmed{
                self?.sendBackupPinViaMail(pin)
            }
        }
    }
}
