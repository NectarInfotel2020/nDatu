//
//  CustomButton.swift
//  WFMS
//
//  Created by NectarInfotel2 on 27/02/20.
//  Copyright © 2020 NectarInfotel2. All rights reserved.
//

import Foundation
import UIKit

//Button with Background Color
@IBDesignable
class CustomButton: UIButton {
    @IBInspectable var titleSize: CGFloat {
        get {
            return 16.0
        }
        set {
            self.titleLabel?.font = UIFont.init(name: Constants.Fonts.lato_Bold, size: newValue)
        }
    }
    
    @IBInspectable var bgColor: UIColor = UIColor.init(hexString: Constants.HexColors.activeColor){
        didSet {
            setBackgroundColor(colorBackground: bgColor)
        }
    }
    
    @IBInspectable var _cornerRadius: CGFloat = 10{
        didSet {
            setBackgroundColor(colorBackground: bgColor)
        }
    }
    
    @IBInspectable var textColor: UIColor = UIColor.white{
        didSet {
            setTitleColor(textColor, for: .normal)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        allocInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        allocInit()
    }
    
    func allocInit(){
        setBackgroundColor(colorBackground: bgColor)
        setCornerRadius(cornerRadius: _cornerRadius)
        self.layer.masksToBounds = true
        self.setTitleColor(UIColor.white, for: .normal)
        self.setTitle(self.currentTitle?.uppercased(), for: .normal)
        self.titleLabel?.font = UIFont.init(name: Constants.Fonts.lato_Bold, size: titleSize)
    }
    
    func isEnabled(enabled: Bool) {
        if enabled {
            self.backgroundColor = bgColor
            self.alpha = 1
            self.isEnabled = true
        } else {
//            self.backgroundColor =  colorLiteral(red: 0.8117647059, green: 0.8117647059, blue: 0.8117647059, alpha: 1)
            self.alpha = 0.50
            self.isEnabled = false
        }
    }
        
    fileprivate func setBackgroundColor (colorBackground color: UIColor) {
        
        self.backgroundColor = color
    }
    
    fileprivate func setCornerRadius(cornerRadius radius: CGFloat) {
        
        self.layer.cornerRadius  = radius
    }
}
