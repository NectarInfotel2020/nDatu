//
//  LoginViewController.swift
//  WFMS
//
//  Created by NectarInfotel2 on 27/02/20.
//  Copyright © 2020 NectarInfotel2. All rights reserved.
//

import UIKit
import Foundation
import MaterialTextField
import ObjectMapper

class LoginViewController: UIViewController,UITextFieldDelegate {

    
    @IBOutlet weak var loginTxtField: MFTextField!
    @IBOutlet weak var passwordTxtField: MFTextField!
    @IBOutlet weak var rememberMeImage: UIImageView!
    @IBOutlet weak var currentVersionLabel: UILabel!
    @IBOutlet weak var loginBtn: CustomButton!
    @IBOutlet weak var topBannerImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        setupBasView()
    }
    
    func setupBasView()  {
        if UserDefaults.standard.bool(forKey: Constants.UserDefaults.rememberMeClicked) {
            rememberMeImage.isHighlighted = true
            if let user = UserDefaults.standard.value(forKey: Constants.UserDefaults.userDetails) as? [String : String] {
                if let userName = user["username"] {
                    loginTxtField.text = userName
                }
                if let password = user["password"] {
                    passwordTxtField.text = password
                }
            }
        }else {
            loginTxtField.text = ""
            passwordTxtField.text = ""

            rememberMeImage.isHighlighted = false
        }
        loginBtn.elevate(elevation: 2.0)
        
        //set app version
        self.currentVersionLabel.text = "Version" + " " + Utility.getAppVersion()
        
        (Constants.singleton.currentDevice == .pad) ? (topBannerImage.contentMode = .scaleToFill) : (topBannerImage.contentMode = .scaleAspectFit)
        
//        Constants.singleton.clientName = UserDefaults.standard.value(forKey: Constants.UserDefaults.clientNameStr) as! String
    }
    
    
    //MARK: - Button Clicked Action
    //MARK: -
    
    @IBAction func loginButtonClicked(_ sender: CustomButton) {
        
        if self.loginTxtField.text!.isEmpty {
            self.showAlert(msg: Constants.validationMesages.emptyUsername, titleMsg: "Validation Error")
            return
        }
//        else if !Utility.isValidEmail(testStr: self.loginTxtField.text!) {
//            self.showAlert(msg: Constants.validationMesages.validateEmailid, titleMsg: "Validation Error")
//            return
//        }
        else if self.passwordTxtField.text!.isEmpty {
            self.showAlert(msg: Constants.validationMesages.emptypassword, titleMsg: "Validation Error")
            return
        }
        loginAPICalled()
    }
    
    //MARK: - Web API Call
    //MARK: --------------------------------
    
    func loginAPICalled()  {
        
        Utility.startIndicator()
        
        let url = "username=\(self.loginTxtField.text!)&password=\(self.passwordTxtField.text!)"
        
        Utility.printLog(key: "Login Request", value: url)

        WebService.requestServiceWithPostMethod(url: url, requestType: Constants.RequestType.login) { (data, error) in

            do
            {
                Utility.hideIndicator()
                
                if let jsonData = data {
                    let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                    Utility.printLog(key: "Response", value: json)
                    if let loginDetailsObject = LoginModel.init(JSON: json!)
                    {
                        if loginDetailsObject.status == "success" {
                            self.handleLoginResponse(resObject: loginDetailsObject)
                        }else {
                            self.showAlert(msg: loginDetailsObject.message, titleMsg: "Error")
                        }
                    }
                }else {
                    self.showAlert(msg: Constants.validationMesages.tryAgainError, titleMsg: "Error")
                }
            } catch {
                self.showAlert(msg: Constants.validationMesages.tryAgainError, titleMsg: "Error")
            }
        }
    }
    
    func handleLoginResponse(resObject: LoginModel)  {
        
        Constants.singleton.loginObject = resObject
        let controller = Constants.Storyboards.main.instantiateViewController(withIdentifier: "DashboardVC") as! DashboardVC
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    @IBAction func rememberMeButtonClicked(_ sender: UIButton) {
        
        var userDetails : [String : String] = [:]
        
        if rememberMeImage.isHighlighted {
            
            let userdefaults = UserDefaults.standard
            userdefaults.set(userDetails, forKey: Constants.UserDefaults.userDetails)
            userdefaults.set(false, forKey: Constants.UserDefaults.rememberMeClicked)
            userdefaults.synchronize()
            
            rememberMeImage.isHighlighted = !rememberMeImage.isHighlighted
        }else {
            //Saves to userdefaults
            if let username = loginTxtField.text {userDetails["username"] = username} else {return}
            if let passwordname = passwordTxtField.text {userDetails["password"] = passwordname} else {return}

            let userdefaults = UserDefaults.standard
            userdefaults.set(userDetails, forKey: Constants.UserDefaults.userDetails)
            userdefaults.set(true, forKey: Constants.UserDefaults.rememberMeClicked)
            userdefaults.synchronize()
            
            rememberMeImage.isHighlighted = !rememberMeImage.isHighlighted
        }
    }
    
    @IBAction func companyUrlClicked(_ sender: UITapGestureRecognizer) {
        
        let urlString = "http://nectarinfotel.com/"

        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        }
    }
    
    
    //MARK: - UITextfield delegate
    //MARK: --------------------------------
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        loginTxtField.resignFirstResponder()
        passwordTxtField.resignFirstResponder()

        return true
    }
    
    //MARK: - Show Alert Message
     //MARK: --------------------------------
     func showAlert(msg: String,titleMsg: String) {
         let alert = UIAlertController.init(title: titleMsg, message: msg, preferredStyle: .alert)
         let action = UIAlertAction.init(title: "OK", style: .cancel) { (UIAlertAction) in
             self.dismiss(animated: true, completion: nil)
             
         }
         alert.addAction(action)
         self.present(alert, animated: true, completion: nil)
     }
}

//MARK: - Login Module Class
//MARK: --------------------------------


class LoginModel: Mappable {
    
    var status: String = ""
    var user_id: Int?
    var access_level: Int?
    var message: String = ""
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        status <- map["status"]
        user_id <- map["user_id"]
        access_level <- map["user_name"]
        message <- map["message"]
    }
}


