//
//  OnboardingViewController.swift
//  KVaultApp
//
//  Created by Fetih Tunay on 02/03/2021.
//  Copyright © Fetih Tunay. All rights reserved.
//

import UIKit
typealias OnbaordingHandler = (_ currentPage : NSInteger, _ isSkip : Bool) -> Void

class OnboardingViewController: UIViewController {
    
    var onboardingHandler : OnbaordingHandler?
    @IBOutlet weak var scrollView : UIScrollView!
    @IBOutlet weak var pagecontrol : UIPageControl!
    @IBOutlet weak var btnDone: UIButton!
    
    @IBOutlet weak var lblWelcome: UILabel!
    
    @IBOutlet weak var lblMsg: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblWelcome.isHidden = true
        btnDone.isHidden = true
        lblMsg.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        lblWelcome.slideIn(from: .top, duration: 0.2, delay: 0.2, completion: nil)
        lblMsg.slideIn(from: .left, duration: 0.2, delay: 0.3, completion: nil)

    }
    
    @IBAction func clickOnSkip(sebder : UIButton){
        onboardingHandler?(NSInteger(scrollView.contentOffset.x/scrollView.frame.size.width), true)
        UtilityClass.dismissViewController()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = NSInteger(scrollView.contentOffset.x/scrollView.frame.size.width)
        pagecontrol.currentPage = index
        btnDone.fadeOut()

        if index == (pagecontrol.numberOfPages - 1){
            btnDone.fadeIn()
        }
    }

}



func showOnboardingViewController(_ callBack : @escaping OnbaordingHandler)  {
    if let onboardingVC = MainStoryBoard.instantiateViewController(withIdentifier: "OnboardingViewController") as? OnboardingViewController{
        onboardingVC.onboardingHandler = callBack
        UtilityClass.presentViewController(vc: onboardingVC)
    }
    
}
