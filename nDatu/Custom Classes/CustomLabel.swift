//
//  CustomLabel.swift
//  WFMS
//
//  Created by NectarInfotel2 on 27/02/20.
//  Copyright © 2020 NectarInfotel2. All rights reserved.
//

import Foundation
import UIKit

class CustomLabel: UILabel {
    
    @IBInspectable var fontSize: CGFloat {
        get {
            return 14.0
        }
        set {
            self.font = UIFont.FontFamily.Regular.of(size: newValue)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        allocInit()
    }
    
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        allocInit()
    }
        
    private func allocInit(){
        self.font = UIFont.FontFamily.Regular.of(size: self.fontSize)
        //self.numberOfLines = 0
        self.lineBreakMode = .byWordWrapping
    }
    
}


extension UIFont {
    enum FontFamily : String {
        
        case Regular = "Font-Regular"

        func of(size: CGFloat) -> UIFont {
            if let font : UIFont = UIFont(name: self.rawValue, size: size) {
                return font
            }else{
                return UIFont.systemFont(ofSize:size)
            }
        }

    }
}
