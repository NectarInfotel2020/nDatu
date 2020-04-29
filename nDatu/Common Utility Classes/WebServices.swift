//
//  WebServices.swift
//  WFMS
//
//  Created by NectarInfotel2 on 27/02/20.
//  Copyright © 2020 NectarInfotel2. All rights reserved.
//

import UIKit
import Alamofire

enum HostServerType: Int {
    case UAT
    case LOCAL
}

struct WebService {
    
    // MARK: - Singleton
    static let shared = WebService()
    
    static func requestServiceWithPostMethod(url: String,requestType: String,completionHadler: @escaping (Data?,Error?) -> Swift.Void) {
                 
        let urlStr = Constants.singleton.selectedEnviornment + requestType + url
        
        let encodedUrl = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        Utility.printLog(key: "Request", value: encodedUrl)

        Alamofire.request(encodedUrl!, method: .post, parameters: [:], encoding: JSONEncoding.default, headers: nil).responseString { (response) in
            
            if let error = response.error {
                completionHadler(nil,error)
                return
            }
            if let success = response.data {
                completionHadler(success,nil)
                return
            }
        }
        
    }
    
    static func requestServiceWithGetMethod(url: String,requestType: String,completionHadler: @escaping (Data?,Error?) -> Swift.Void) {
        
        let urlStr = Constants.singleton.selectedEnviornment + requestType + url
        
        Alamofire.request(urlStr).responseString { (response) in

            if let error = response.error {
                completionHadler(nil,error)
                return
            }

            if let success = response.data {
                completionHadler(success,nil)
                return
            }
        }
    }
    
    
    
    //MARK: Request Service for API Calls
    static func requestServiceWith(urlExtensionWith requestType: String, serverType: HostServerType, parameters: Parameters, completionHandler:@escaping (Data?, Error?) -> Swift.Void)
    {
        
        // it is returning alsways true for now
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 120
        configuration.timeoutIntervalForRequest = 120// seconds
        
        var url = requestType
        var hostName = ""
        
//        let singleton = Singleton.sharedManager
//
//        switch serverType {
//
//        case .UAT:
//            url = singleton.wfmsUATHostName + requestType
//            configuration.httpAdditionalHeaders = ["Accept":"application/json", "Authentication-Key": Constants.singleton.authKey]
////            hostName = singleton.pgsHostName.replacingOccurrences(of: "https://", with: "")
//            break
//
//        case .LOCAL:
//            url = singleton.wfmsLocalHostName + requestType
//            configuration.httpAdditionalHeaders = ["Accept":"application/json"]
////            hostName = singleton.jarvisHostName.replacingOccurrences(of: "https://", with: "")
//            break
//
//        }
        
        Utility.printLog(key: "URL", value: url)
        
        
//        let serverTrustPolicy = ServerTrustPolicy.pinCertificates(
//            certificates: ServerTrustPolicy.certificates(in: Bundle.main),
//            validateCertificateChain: true,
//            validateHost: true
//        )
//
//        let serverPolicies: [String: ServerTrustPolicy] = [
//            hostName.getDomain() ?? hostName : serverTrustPolicy
//        ]
        
//        let manager =  Alamofire.SessionManager(configuration: configuration, delegate: SessionDelegate(), serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverPolicies))
        
        let manager =  Alamofire.SessionManager(configuration: configuration, delegate: SessionDelegate(), serverTrustPolicyManager: .none)
        
        let startDate = Date()
        
        //        let manager = Alamofire.SessionManager(configuration: configuration)
        
        manager.request(URL(string: url)!, method: .post, parameters:parameters, encoding: JSONEncoding.default).validate().responseData { (response) -> Void in
            
            //calculates time required to execute api
            let responseTime = Date().timeIntervalSince(startDate)
            
            Utility.printLog(key: "Response Time for \(requestType) API : ", value: responseTime)
            
            if let error = response.error {
                completionHandler(nil, error)
                
                manager.session.invalidateAndCancel()
                return
            }
            
            if let responseObj = response.result.value {
                completionHandler(responseObj, nil)
                
                manager.session.invalidateAndCancel()
                return
            }else{
                completionHandler(nil, response.result.error)
                
                manager.session.invalidateAndCancel()
                return
            }
        }
    }
    
    //MARK: Request Service for Key
    static func requestServiceForKey(url: String, parameters: Parameters, completionHandler: @escaping (Any?, String?) -> Swift.Void)
    {
        if Utility.checkInternetConnection()
        {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForResource = 60
            configuration.timeoutIntervalForRequest = 60// seconds
            
            let serverTrustPolicy = ServerTrustPolicy.pinCertificates(
                certificates: ServerTrustPolicy.certificates(in: Bundle.main),
                validateCertificateChain: true,
                validateHost: true
            )
            
            let serverTrustPolicies = [
                "wayveonline.com": serverTrustPolicy
            ]
            
            let manager =  Alamofire.SessionManager(configuration: configuration, delegate: SessionDelegate(), serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))
            
            
            //                let manager = Alamofire.SessionManager(configuration: configuration)
            
            manager.request(URL(string: url)!, method: .post, parameters:parameters, encoding: JSONEncoding.default).validate().responseJSON { (response) -> Void in
                
                guard response.result.isSuccess else{
                    completionHandler(nil, Constants.validationMesages.unableToConnect)
                    return
                }
                
                guard let responseObj = response.result.value as? [String: Any] else{
                    completionHandler(nil, response.result.error?.localizedDescription)
                    return
                }
                
                let jsonResponse = responseObj
                Utility.printLog(key: "Response Details",value: jsonResponse)
                
                if (jsonResponse["status"] as! String != "FAILED") && jsonResponse["status"] as! String != "Fail"
                {
                    let res = jsonResponse["jsonResponse"] as? String
//                    guard let decryptedResponse = res?.decryptResponseWithDefaultKeyIV() else{
//                        completionHandler(nil, Constants.validationMessages.somethingwrong)
//                        return
//                    }
//                    Utility.printLog(key: "Decrypted Response Details",value: decryptedResponse)
//                    completionHandler(decryptedResponse, response.result.error?.localizedDescription)
                }
                else
                {
//                    if let errorCode = jsonResponse["responseCode"] as? String
//                    {
//                        Constants.singleton.currentErrorCode = errorCode
//                    }
                    
                    let res = jsonResponse["message"] as? String
                    completionHandler(nil, res)
                }
                manager.session.invalidateAndCancel()
            }
        }
        else
        {
//            completionHandler(nil, Constants.validationMessages.noInternet)
        }
    }
    
        static func requestMultiPartWith(url: String, parameters: [String : String], arrayImgdata:[Data], completionHandler: @escaping (Any?, String?) -> Swift.Void) {
    
            let headers : HTTPHeaders = ["Content-type" : "multipart/form-data"]
    
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                for (key, value) in parameters {
                    multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
                }
    
                for imageData in arrayImgdata {
                        multipartFormData.append(imageData, withName: "image", fileName: "image.jpg", mimeType: "image/jpeg")
                }
    
                Utility.printLog(key: "Multipart Request Details",value: multipartFormData)
    
            },usingThreshold: UInt64.init(), to: url, method: .post, headers: headers) { (result) in
                switch result{
                case .success(let upload, _, _):
                    upload.responseString { response in
    
                        guard response.result.isSuccess else{
                            completionHandler("Nil", response.result.error?.localizedDescription)
                            Utility.printLog(key: "Error in image upload", value: response.result.error?.localizedDescription ?? "")
                            return
                        }
    
                        guard let responseObj = response.result.value as? [String: Any] else{
                            completionHandler("Nil", response.result.error?.localizedDescription)
                            Utility.printLog(key: "Error in image upload", value: response.result.error?.localizedDescription ?? "")
                            return
                        }
                        print("Succesfully uploaded")
                        completionHandler(responseObj, response.result.error?.localizedDescription)
    
                    }
                case .failure(let error):
                    print("Error in upload: \(error.localizedDescription)")
                    completionHandler(nil, error.localizedDescription)
                }
            }
        }
    
    
    func downloadImage(imageURL: String, completionHandler:@escaping (UIImage?, Error?) -> Swift.Void ) {
        
        Alamofire.request(imageURL).responseData { (response) in
            if response.error == nil {
                 print(response.result)
                
                // Show the downloaded image:
                if let data = response.data {
                    let image = UIImage(data: data)
                        completionHandler(image,nil)
                    }
                }
             }
    }
}
