//
//  ImageViewerController.swift
//  MYMECA
//
//  Created by Fetih Tunay on 19/02/2021.
//  Copyright © Fetih Tunay. All rights reserved.
//

import UIKit

class ImageViewerController: UIViewController  {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imgPhoto: UIImageView!
    var objUploadMedia : GalleryModel!
    override func viewDidLoad() {

        super.viewDidLoad()
        imgPhoto.image = objUploadMedia.image
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0


        let doubleTapGest = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapScrollView(recognizer:)))
        doubleTapGest.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGest)
        // scrollView.delegate = self - it is set on the storyboard.
    }

    @objc func handleDoubleTapScrollView(recognizer: UITapGestureRecognizer) {
        if scrollView.zoomScale == 1 {
            scrollView.zoom(to: zoomRectForScale(scale: scrollView.maximumZoomScale, center: recognizer.location(in: recognizer.view)), animated: true)
        } else {
            scrollView.setZoomScale(1, animated: true)
        }
    }

    func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = imgPhoto.frame.size.height / scale
        zoomRect.size.width  = imgPhoto.frame.size.width  / scale
        let newCenter = imgPhoto.convert(center, from: scrollView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgPhoto
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
