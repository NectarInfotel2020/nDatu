//
//  Singleton.swift
//  WFMS
//
//  Created by NectarInfotel2 on 27/02/20.
//  Copyright © 2020 NectarInfotel2. All rights reserved.
//

import UIKit

import UIKit

enum ServerType: Int {
    case UAT
    case LOCAL
}


enum UIUserInterfaceIdiom : Int {
    case unspecified

    case phone // iPhone and iPod touch style UI
    case pad   // iPad style UI (also includes macOS Catalyst)
}

class Singleton: NSObject {
    
    
    static let sharedManager = Singleton()
    
    var wfmsUATHostName: String = ""
    var wfmsLocalHostName: String = ""
    
    var authKey: String = ""
    var clientName: String = ""
    var isAdmin = false
    
    var selectedEnviornment = ""
        
    var loginObject: LoginModel?
    
    let currentDevice = UIDevice.current.userInterfaceIdiom
    
    override init()
    {
        super.init()
        selectedEnviornment = selectServerType(serverType: .UAT)
    }
    
    
    private func selectServerType(serverType: ServerType) -> String
    {
        
        switch serverType
        {
            
        case .UAT:
            wfmsUATHostName = Constants.HostName.strUATBaseURL
            return wfmsUATHostName
//            break
            
        case .LOCAL:
            wfmsLocalHostName = Constants.HostName.strUATBaseURL
            return wfmsLocalHostName
//            break
        }
    }
    
}
