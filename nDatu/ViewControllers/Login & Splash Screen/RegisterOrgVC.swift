//
//  RegisterOrgVC.swift
//  WFMS
//
//  Created by NectarInfotel2 on 27/02/20.
//  Copyright © 2020 NectarInfotel2. All rights reserved.
//

import UIKit
import MaterialTextField
import ObjectMapper

class RegisterOrgVC: UIViewController,UITextFieldDelegate {
            
    @IBOutlet weak var orgText: MFTextField!
    @IBOutlet weak var submitBtn: CustomButton!
    
    var clientDetailsObject:ClientDetailsModel?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        orgText.underlineColor = UIColor.init(hexString: Constants.HexColors.activeColor)
        orgText.tintColor = UIColor.init(hexString: Constants.HexColors.activeColor)
        submitBtn.elevate(elevation: 2.0)
        
    }
    
    //MARK: - UITextfield delegate
    //MARK: --------------------------------
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        orgText.resignFirstResponder()
        return true
    }
    
    //MARK: - Button Action
    //MARK: --------------------------------
    
    @IBAction func submitButtonClicked(_ sender: CustomButton) {
        
        if orgText.text!.isEmpty {
            showAlert(msg: Constants.validationMesages.emptyOrgnizationName)
            orgText.resignFirstResponder()
            return
        }
        if orgText.text != "nDatu" {
            showAlert(msg: Constants.validationMesages.validOrgnizationName)
            orgText.resignFirstResponder()
            return
        }
        
        handleResponse(clientName: orgText.text ?? "")

        
        //call api
//        Utility.startIndicator()
//        getClientNameWebAPICall()
    }
    
    func getClientNameWebAPICall() {
        
        let url = "clientname=\(self.orgText.text ?? "")"
        
        WebService.requestServiceWithPostMethod(url: url, requestType: Constants.RequestType.client_detail) { (data, error) in
            
            do
            {
                Utility.hideIndicator()
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                
                if let clientDetailsObject = ClientDetailsModel.init(JSON: json!)
                {
                    if clientDetailsObject.status == "success" {
//                        self.handleResponse(responseObj: clientDetailsObject)
                    }else if clientDetailsObject.status == "fail" {
                        
                        self.showAlert(msg: Constants.validationMesages.emptyClientName)
                    }else {
                        self.showAlert(msg: Constants.validationMesages.tryAgainError)
                    }
                }
            } catch {
                self.showAlert(msg: Constants.validationMesages.tryAgainError)
            }
        }
    }
    
    func handleResponse(clientName: String) {
                
        // save to defaults
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: Constants.UserDefaults.firstTimeUser)
        userDefaults.set(clientName, forKey: Constants.UserDefaults.clientNameStr)
        userDefaults.synchronize()
        
        let controller = Constants.Storyboards.main.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    
    //MARK: - Show Alert Message
    //MARK: --------------------------------
    func showAlert(msg: String) {
        let alert = UIAlertController.init(title: "", message: msg, preferredStyle: .alert)
        let action = UIAlertAction.init(title: "OK", style: .cancel) { (UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
            
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //(["client_intime": 05:00:00, "client_id": 1, "status": success, "client_outtime": 08:35:00])
    struct client_details_Response {
        
        public var client_intime: String = ""
        public var client_id: String = ""
        public var status: String = ""
        public var client_outtime = ""
        
        public init(client_intime: String,client_id: String,status: String,client_outtime: String){
            self.client_intime = client_intime
            self.client_id = client_id
            self.status = status
            self.client_outtime = client_outtime
        }
    }
}

class ClientDetailsModel: Mappable {
    
     var client_intime: String = ""
     var client_id: String = ""
     var status: String = ""
     var client_outtime = ""
     var clientname = ""
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        client_intime <- map["client_intime"]
        client_id <- map["client_id"]
        status <- map["status"]
        client_outtime <- map["client_outtime"]
        clientname <- map["clientname"]
    }
}


