//
//  Constants.swift
//  WFMS
//
//  Created by NectarInfotel2 on 27/02/20.
//  Copyright © 2020 NectarInfotel2. All rights reserved.
//

import UIKit

struct Constants {
    
    static let singleton = Singleton.sharedManager
    
    struct RequestType
    {
        static  let  client_detail           = "client_detail?"
        static  let  login                   = "login?"
        static  let  projectlist             = "projectlist?"
        static  let  userlist                = "userlist?"
        static  let  submittask              = "submittask?"
        static  let  viewtask                = "viewtask?"
        static  let  edittask                = "edittask?"
    }
    
    struct HardcodedData {
        static let monthsArray = ["January", "February","March","April","May","June","July","August","September","October","November","December"]
        static let yearArray = ["2019","2020"]
        //screen cgrect details
        static let screenHeight = UIScreen.main.bounds.height
        static let screenWidth = UIScreen.main.bounds.width
    }
    
    struct HostName
    {
        static let strUATBaseURL      = "http://tarefatracacc.nectarinfotel.com/nDatu_api/public/"
    }
    
    struct HexColors
    {
        static let wfmsBlue = "#292663"
        static let activeColor = "#292663"
        static let wfmsCyan = "#F16924"
    }
    
    struct Storyboards {
        static let main = UIStoryboard.init(name: "Main", bundle: .main)
    }
    
    struct UserDefaults {
        static let firstTimeUser = "isUserLogin"
        static let rememberMeClicked = "rememberMeClicked"
        static let clientNameStr = "ClientName"
        static let userDetails = "UserDetails"
    }
    
    struct validationMesages {
        
        static let emptyOrgnizationName = "Please enter orgnization name"
        static let validOrgnizationName = "Please enter valid orgnization name"

        static let emptyUsername        = "Please enter username"
        static let validateEmailid      = "Please enter valid email id"
        static let emptypassword        = "Please enter password"

        static let emptyClientName           = "The clientname field is required."
        static let tryAgainError             = "Please try again"
        static let unableToConnect           = "Unable to connect to server"
        
        static let biometricAuthErrorMsg     = "You could not be verified; please try again!"
        static let biometricAuthErrorTitle   = "Authentication failed!"
        
        static let emptyRecords              = "No Records Found!"
        static let uploadImageSuccess        = "Image uploaded successfully"
        static let emptyUserSelection        = "Please select User"
        static let emptyYearSelection        = "Please select Year"
        static let emptyMonthSelection       = "Please select Month"
        static let emptyOldpassword          = "Please enter old password"
        static let emptyNewPassword          = "Please enter new password"
        static let emptyConfirmPassword      = "Please enter confirmed password"
        static let passwordMismatch          = "New password & Confirm password does not match"
        
        static let emptyProjectName          = "Please select project"
        static let emptySummary              = "Please enter summary"
        static let emptyDescription          = "Please enter description"
        static let logoutConfirmationMsg     = "Are you sure you want to logout"
    }
    
    
    struct TaskStatusCode {
        static let completed        = "20"
        static let pending_For_Data = "10"
        static let work_in_progress = "50"
        static let amount_received  = "30"
        static let closed           = "90"
        static let billed           = "80"
        static let Not_due_for_bill = "40"
    }
    
    struct TaskStatusString {
        static let completed        = ""
    }
    
    struct Fonts {
        static let  lato_Black = "Lato-Black"
        static let  lato_BlackItalic = "Lato-BlackItalic"
        static let  lato_Bold = "Lato-Bold"
        static let  lato_BoldItalic = "Lato-BoldItalic"
        static let  lato_Hairline = "Lato-Hairline"
        static let lato_HairlineItalic = "Lato-HairlineItalic"
        static let lato_Heavy = "Lato-Heavy"
        static let lato_HeavyItalic = "Lato-HeavyItalic"
        static let lato_Italic = "Lato-Italic"
        static let lato_Light = "Lato-Light"
        static let lato_LightItalic = "Lato-LightItalic"
        static let lato_Medium = "Lato-Medium"
        static let lato_MediumItalic = "Lato-MediumItalic"
        static let lato_Regular = "Lato-Regular"
        static let lato_Semibold = "Lato-Semibold"
        static let lato_SemiboldItalic = "Lato-SemiboldItalic"
        static let lato_Thin = "Lato-Thin"
        static let lato_ThinItalic = "Lato-ThinItalic"
    }
}
