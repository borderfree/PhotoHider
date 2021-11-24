//
//  Constant.swift
//  Centreel
//
//  Created by Fetih Tunay on 24/02/2021.
//  Copyright © Fetih Tunay. All rights reserved.
//

import UIKit

var  APPDELEGATE : AppDelegate {
    return UIApplication.shared.delegate as? AppDelegate ?? AppDelegate()
}
let USERDEFAULTS = UserDefaults.standard
let NOTIFICATIONCENTER = NotificationCenter.default
let BUNDLE = Bundle.main
let MAIN_SCREEN = UIScreen.main
let SCREEN_WIDTH:CGFloat = MAIN_SCREEN.bounds.width
let SCREEN_HEIGHT = MAIN_SCREEN.bounds.height
let SCREEN_SCALE:CGFloat = MAIN_SCREEN.bounds.width/320

let kIphone_4s : Bool =  (SCREEN_HEIGHT == 480)
let kIphone_5 : Bool =  (SCREEN_HEIGHT == 568)
let kIphone_6 : Bool =  (SCREEN_HEIGHT == 667)
let kIphone_6_Plus : Bool =  (SCREEN_HEIGHT == 736)
let kIphone_X : Bool = (SCREEN_HEIGHT == 812)

let iPAD = UIDevice.current.userInterfaceIdiom == .pad


//MARK: - Print
func PRINT(_ data:Any)
{
    #if DEBUG
    print(data)
    #endif
}

// MARK: iOS Version
func IOS_VERSION_EQUAL_TO(v: Any) -> Bool {
    return UIDevice.current.systemVersion.compare(v as? String ?? "", options: .numeric) == .orderedSame
}
func IOS_VERSION_GREATER_THAN(v: Any) -> Bool {
    return UIDevice.current.systemVersion.compare(v as? String ?? "", options: .numeric) == .orderedDescending
}
func IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(v: Any) -> Bool {
    return UIDevice.current.systemVersion.compare(v as? String ?? "", options: .numeric) != .orderedAscending
}
func IOS_VERSION_LESS_THAN(v: String) -> Bool {
    return UIDevice.current.systemVersion.compare(v, options: .numeric) == .orderedAscending
}
func IOS_VERSION_LESS_THAN_OR_EQUAL_TO(v: Any) -> Bool {
    return UIDevice.current.systemVersion.compare(v as? String ?? "" , options: .numeric) != .orderedAscending
}


func CheckNullString(value : Any) -> String{
    var str = ""
    // var str = String.init(format: "%ld", value as! CVarArg)
    if let v = value as? NSString{
        str = v as String
    }else if let v = value as? NSNumber{
        str = v.stringValue
    }else if let v = value as? Double{
        str = String.init(format: "%ld", v);
    }else if let v = value as? Int{
        str = String.init(format: "%ld", v);
    }
    else if value is NSNull{
        str = "";
    }
    else{
        str = ""
    }
    return str;
}

 func documentPathWithFileName(fileName : String!) -> URL{
    let documentsDirectoryURL = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    // create a name for your image
    // create a name for your image
    let fileURL = documentsDirectoryURL.appendingPathComponent(fileName)
    return fileURL
}


let MainStoryBoard = UIStoryboard.init(name: "Main", bundle: nil)





//-------------------------------------------------------------------------------------------//
//-*-*-*-*-*-*--*-*-*-*-*-*-*-*-*-*AllMessageString-*-*-*-*-*-*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-//
//-------------------------------------------------------------------------------------------//

//login
let PleseEnterEmail                       = "Please enter Email address!"
let PleaseEnterPassword                   = "Please enter Password!"

//forgot password
let PleaseEnteRegisterEmail               = "Please enter registered Email address!"
let PleaseEnterValidEmail                 = "Please enter valid Email address!"

// Pin Screen
let PleaseEnterTodoDescription = "Please enter description"
let PleaseSelectDepartment = "Please select department"
let PleaseSelectTTD = "Please select TTD"
let PleaseSelectLastDate = "Please select lastdate"
let PleaseSelectUser = "Please select user"
let PleaseSelectOne = "Please select one"
let PleaseSelectStatus = "Please select status"
let PleaseSelectEnquiry = "Please select enquiry"
let PleaseSelectParty = "Please select party"
let PleaseSelectVendor = "Please select vendor"
let PleaseSeletApproxClosedDate = "Please select approx closed date"






//-------------------------------------------------------------------------------------------//
//-------------------------------------------------------------------------------------------//


enum FontName : String {
    case MontserratMedium = "Montserrat-Medium"
    case MontserratBold = "Montserrat-Bold"
    case MontserratRegular = "Montserrat-Regular"
    case MontserratLight = "Montserrat-Light"
    case MontserratExtraLight = "Montserrat-ExtraLight"
}

func font(name : FontName, size: CGFloat) -> UIFont{
    return UIFont.init(name: name.rawValue, size: size.scaledFontSize)!
}

func systemFont(weight : UIFont.Weight, size : CGFloat) -> UIFont{
    return UIFont.systemFont(ofSize: size.scaledFontSize, weight: weight)
}

func Localization(localKey : String?) -> String{
    return localKey!
    //return UtilityClass.getLanguageLabelWithKey(key: localKey!)
}


// MARK: Currency format

func strCurrencyFormat(value : Double,isDecimal : Bool,isCurrencySymbol : Bool) -> String{
    let formatter = NumberFormatter()
    formatter.locale = Locale(identifier: "en_US")

    if isDecimal{
        formatter.numberStyle = .currency
       // formatter.currencySymbol = ""
    }else{
        formatter.numberStyle = .decimal
    }
    if isCurrencySymbol{
        formatter.currencySymbol = "$"
    }
    else{
        formatter.currencySymbol = ""
    }
    return formatter.string(from: value as NSNumber)!
}
struct AlertMessage{
    static let AvailableStockValidationMsg = "Attention! Available Stock is "
    // confirmation screen
    static let CloseoutDiscrepancyMsg = "HMMM… LOOKS LIKE YOU’VE FOUND A DISCREPANCY!"
    static let ConfirmDiscrepancyMsg = "PLEASE RECONFIRM THE TOTAL RECONCILIATION."
    static let ConfirmTransferMsg = "THE TRANSFER HAS BEEN SETUP!"
    
    
    static func setStrokeMsgWithQuantity(qty : String) -> String{
        return AvailableStockValidationMsg + qty + " only"
    }
}
class Constant: NSObject {
    
}
