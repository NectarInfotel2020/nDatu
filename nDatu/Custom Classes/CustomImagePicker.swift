//
//  CustomImagePicker.swift
//  nDatu
//
//  Created by Sagar Ranshur on 16/04/20.
//  Copyright © 2020 Sagar Ranshur. All rights reserved.
//

import UIKit

protocol CameraHandlerDelegate {
    func cameraClicked()
    func photoGallaryClicked()
}

class CustomImagePicker: UIView {

    
    @IBOutlet weak var imagePickerBaseView: UIView!
    
    var cameraDelegate: CameraHandlerDelegate?
    
    let nibName = "CustomImagePicker"
    static var contentView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        guard let view = loadViewFromNib() else {return}
//        setUpCustomAlertView()
        view.frame = self.bounds
        self.addSubview(view)
        CustomImagePicker.contentView = view
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    static func showAlert(view: UIView) {
        let windows = UIApplication.shared.windows
        
        let lastWindow = windows.last
        contentView?.frame = UIScreen.main.bounds
        lastWindow?.addSubview(contentView!)
    }

    static func removeAlert(view: UIView) {
        view.removeFromSuperview()
    }

    
    @IBAction func gallaryBtnClicked(_ sender: UIButton) {
        cameraDelegate?.photoGallaryClicked()
    }
    
    @IBAction func circleBtnClicked(_ sender: UIButton) {
        cameraDelegate?.cameraClicked()
    }
    
}
