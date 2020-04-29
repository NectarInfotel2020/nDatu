//
//  AssignTaskViewController.swift
//  nDatu
//
//  Created by Sagar Ranshur on 15/04/20.
//  Copyright © 2020 Sagar Ranshur. All rights reserved.
//

import UIKit
import DropDown
import ObjectMapper
import CoreLocation

class AssignTaskViewController: UIViewController,UITextViewDelegate,UITextFieldDelegate,CameraHandlerDelegate {

    @IBOutlet weak var selectProjectBaseView: UIView!
    @IBOutlet weak var projectNameLbl: UILabel!
    @IBOutlet weak var selectUserBaseView: UIView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var enterSummaryTxt: UITextField!
    @IBOutlet weak var enterDescriptionTxtview: UITextView!
    @IBOutlet weak var dropDownImage: UIImageView!
    @IBOutlet weak var selectStatusBaseView: UIView!
    @IBOutlet weak var selectStatusLabel: UILabel!
    @IBOutlet weak var uploadImage: UIImageView!
    @IBOutlet weak var uploadBtn: UIButton!
    
    let dropDown = DropDown()
    var projectListArray = [Projects]()
    var usersListArray = [Users]()
    var locationManager = CLLocationManager()
    
    var selectedImage = UIImageView()
    var imageData = [Data]()
    var submitTaskFlag = false
    
    let customPickerView = CustomImagePicker()
    var selectedProject: Projects?
    var selectedUser: Users?
    var selectedTasks: Tasks?
    
    var statusarray = ["Pending for data", "Completed", "Work in progress", "Amount recieved", "Closed", "Billed", "Not due for bill"];
    
    var isEditingTask = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        projectListAPICall()
    }
    
    func setup() {
        
        locationManager.requestWhenInUseAuthorization()
        var currentLoc: CLLocation!
        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
        CLLocationManager.authorizationStatus() == .authorizedAlways) {
           currentLoc = locationManager.location
        }
        
        customPickerView.cameraDelegate = self
        
        let paddingView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 8, height: self.enterSummaryTxt.frame.height))
        enterSummaryTxt.leftView = paddingView
        enterSummaryTxt.leftViewMode = .always
    }
    
    //MARK: - Camera/Photo setup
    //MARK: -------------------------------
    
    func camera()
    {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .camera
            self.present(myPickerController, animated: true, completion: nil)
        }else {
            Utility.showAlert(message: "Camera is not Available!")
        }
    }
    
    func photoLibrary()
    {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .photoLibrary
            self.present(myPickerController, animated: true, completion: nil)
        }else {
            Utility.showAlert(message: "Photo Library is not Available!")
        }
    }
    
    //MARK: - Camera Handler Delegate Methods
    //MARK: -
    
    func cameraClicked() {
        CustomImagePicker.removeAlert(view: CustomImagePicker.contentView!)
        camera()
    }
    
    func photoGallaryClicked() {
        CustomImagePicker.removeAlert(view: CustomImagePicker.contentView!)
        photoLibrary()
    }

    //MARK: - API Call Methods
    //MARK: -
    func projectListAPICall()  {
        
        Utility.startIndicator()
        
        WebService.requestServiceWithPostMethod(url: "", requestType: Constants.RequestType.projectlist) { (data, error) in
            
            do {
                Utility.hideIndicator()
                
                if let jsonData = data {
                    let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                    Utility.printLog(key: "Response", value: json as Any)
                    
                    if let projectsResponceObject = ProjectListModel.init(JSON: json!)
                    {
                        if projectsResponceObject.status == "success" {
                           
                            if projectsResponceObject.data.count > 0 {
                                self.projectListArray = projectsResponceObject.data
                                self.userListAPICall()
                            }

                        }else if projectsResponceObject.status == "fail" {
                            Utility.showAlert(message: projectsResponceObject.message)
                        }else {
                            Utility.showAlert(message: Constants.validationMesages.tryAgainError)
                        }
                    }
                }else {
                    Utility.showAlert(message: Constants.validationMesages.tryAgainError)
                }
            }
            catch {
                Utility.showAlert(message: error.localizedDescription)
            }
        }
    }
    
    func userListAPICall()  {
        
        Utility.startIndicator()
        
        WebService.requestServiceWithPostMethod(url: "", requestType: Constants.RequestType.userlist) { (data, error) in
            
            do {
                
                Utility.hideIndicator()
                
                if let jsonData = data {
                    let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                    Utility.printLog(key: "Response", value: json as Any)
                    
                    if let usersResponceObject = UserListModel.init(JSON: json!)
                    {
                        if usersResponceObject.status == "success" {
                           
                            if usersResponceObject.data.count > 0 {
                                self.usersListArray = usersResponceObject.data
                                
                                DispatchQueue.main.async {
                                    if self.isEditingTask  {
                                        self.setUpEditView()
                                    }
                                }
                            }

                        }else if usersResponceObject.status == "fail" {
                            Utility.showAlert(message: usersResponceObject.message)
                        }else {
                            Utility.showAlert(message: Constants.validationMesages.tryAgainError)
                        }
                    }
                }else {
                    Utility.showAlert(message: Constants.validationMesages.tryAgainError)
                }
            }
            catch {
                Utility.showAlert(message: error.localizedDescription)
            }
        }
    }
    
    func submitTaskAPICall() {
        
        Utility.startIndicator()
        
        let wholeUrl = Constants.HostName.strUATBaseURL + Constants.RequestType.submittask
        
        let paraDict: [String:Any] = ["project_id":"\(selectedProject?.id ?? 0)",
            "reporter_id":"\(Constants.singleton.loginObject?.user_id ?? 0)",
            "handler_id":"\(selectedUser?.id ?? 0)",
            "image":"\(imageData)",
            "summary": enterSummaryTxt.text ?? "",
            "description": enterDescriptionTxtview.text ?? ""]
        
        if imageData.count > 0 {
            imageUploadRequest(imageView: self.selectedImage, uploadUrl: NSURL.init(string: wholeUrl)!, param: paraDict as? [String : String])
        }else {
            submitTaskWithoutImageAPICall()
        }
    }
    
    func submitTaskWithoutImageAPICall()  {
        
        Utility.startIndicator()
        
        let url  = "&project_id=\(selectedProject?.id ?? 0)&reporter_id=\(Constants.singleton.loginObject?.user_id ?? 0)&handler_id=\(selectedUser?.id ?? 0)&image=&summary=\(enterSummaryTxt.text ?? "")&description=\(enterDescriptionTxtview.text ?? "")"
        
        WebService.requestServiceWithPostMethod(url: url, requestType: Constants.RequestType.submittask) { (data, error) in
            
            do {
                
                Utility.hideIndicator()
                
                if let jsonData = data {
                    let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                    Utility.printLog(key: "Response", value: json as Any)
                    
                    if let submitResponceObject = SubmitTaskModel.init(JSON: json!)
                    {
                        if submitResponceObject.status == "success" {
                           
                            self.submitTaskFlag = true
                            self.showAlert(msg: submitResponceObject.message, titleMsg: "Success")

                        }else if submitResponceObject.status == "fail" {
                            Utility.showAlert(message: submitResponceObject.message)
                        }else {
                            Utility.showAlert(message: Constants.validationMesages.tryAgainError)
                        }
                    }
                }else {
                    Utility.showAlert(message: Constants.validationMesages.tryAgainError)
                }
            }
            catch {
                Utility.showAlert(message: error.localizedDescription)
            }
        }
    }
    
    
    func editTaskCall(projectId: String,reporter_Id: String,handler_Id: String,task_Id: String,status: String,summary: String,descStr: String)  {
        
        Utility.startIndicator()
        
        let url  = "&project_id=\(projectId)&reporter_id=\(reporter_Id)&handler_id=\(handler_Id)&task_id=\(task_Id)&status=\(status)&summary=\(summary)&description=\(descStr)"
        
        WebService.requestServiceWithPostMethod(url: url, requestType: Constants.RequestType.edittask) { (data, error) in
            
            do {
                
                Utility.hideIndicator()
                
                if let jsonData = data {
                    let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                    Utility.printLog(key: "Response", value: json as Any)
                    
                    if let submitResponceObject = SubmitTaskModel.init(JSON: json!)
                    {
                        if submitResponceObject.status == "success" {
                           
                            self.submitTaskFlag = true
                            self.showAlert(msg: submitResponceObject.message, titleMsg: "Success")

                        }else if submitResponceObject.status == "fail" {
                            Utility.showAlert(message: submitResponceObject.message)
                        }else {
                            Utility.showAlert(message: Constants.validationMesages.tryAgainError)
                        }
                    }
                }else {
                    Utility.showAlert(message: Constants.validationMesages.tryAgainError)
                }
            }
            catch {
                Utility.showAlert(message: error.localizedDescription)
            }
        }
    }
    
    
    func imageUploadRequest(imageView: UIImageView, uploadUrl: NSURL, param: [String:String]?) {
        
        let request = NSMutableURLRequest(url:uploadUrl as URL);
        request.httpMethod = "POST"
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let imageData = imageView.image!.jpegData(compressionQuality: 0.3)
        
        if(imageData==nil)  { return; }
        
        request.httpBody = createBodyWithParameters(parameters: param, filePathKey: "image", imageDataKey: imageData! as NSData, boundary: boundary) as Data
        
        //myActivityIndicator.startAnimating();
        
        let task =  URLSession.shared.dataTask(with: request as URLRequest,
                                               completionHandler: {
                                                (data, response, error) -> Void in
                                                if let data = data {
                                                    
                                                    Utility.hideIndicator()
                                                    
                                                    // Print out reponse body
                                                    let responseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                                                    print("****** response data = \(responseString!)")
                                                    
                                                    let json =  try!JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String : Any]
                                                    
                                                    let submittaskObj = SubmitTaskModel.init(JSON: json!)
                                                    
                                                    DispatchQueue.main.async(execute: {
                                                        if submittaskObj?.status == "success" {
                                                            self.submitTaskFlag = true
                                                            self.showAlert(msg: submittaskObj?.message ?? "", titleMsg: "Success")
                                                        }else {
                                                            self.showAlert(msg: submittaskObj?.message ?? "", titleMsg: "Message")
                                                        }
                                                    });
                                                    
                                                } else if let error = error {
                                                    
                                                    self.showAlert(msg: error.localizedDescription, titleMsg: "Message")
                                                }
        })
        task.resume()
    }
    
       func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
           let body = NSMutableData();

           if parameters != nil {
               for (key, value) in parameters! {
                body.appendString(string: "--\(boundary)\r\n")
                body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString(string: "\(value)\r\n")
               }
           }

           let filename = "user-profile.jpg"

           let mimetype = "image/jpg"

        body.appendString(string: "--\(boundary)\r\n")
        body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey as Data)
        body.appendString(string: "\r\n")

        body.appendString(string: "--\(boundary)--\r\n")

           return body
       }

       func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
       }

    
    //MARK: - Regular Functions
    //MARK: -
    func handleProjectListResponse()  {
        
        if projectListArray.count > 0 {
            let projects = projectListArray.map { (project) -> String in
                return project.name
            }
            
            let dropDown = DropDown()
            
            dropDown.anchorView = self.selectProjectBaseView
            dropDown.width = self.selectProjectBaseView.frame.size.width
            dropDown.direction = .any
            dropDown.bottomOffset = CGPoint.init(x: self.selectProjectBaseView.frame.origin.x - 25, y: self.selectProjectBaseView.frame.origin.y)
            // The list of items to display. Can be changed dynamically
            dropDown.dataSource = projects
            dropDown.show()
            // Action triggered on selection
            dropDown.selectionAction = { (index: Int, item: String) in
                self.projectNameLbl.text = item
                self.selectedProject = self.projectListArray[index]
            }
        }
    }
    
    func setUpEditView() {
        
        if projectListArray.count > 0 && usersListArray.count > 0 {
                        
            var project : Projects?
            var user : Users?
            for item in projectListArray {
                if item.id == selectedTasks?.project_id {
                    project = item
                    selectedProject = item
                }
            }
            
            for item in usersListArray {
                if item.id == selectedTasks?.handler_id {
                    user = item
                    selectedUser = item
                }
            }

            if isEditingTask {
                selectProjectBaseView.backgroundColor = .white
                projectNameLbl.textColor = UIColor.init(hexString: Constants.HexColors.wfmsBlue)
                
                (Constants.singleton.currentDevice == .pad) ? (projectNameLbl.font = UIFont.init(name: "lato", size: 21)) : (projectNameLbl.font = UIFont.init(name: "lato", size: 18))

                dropDownImage.isHidden = true
                
                projectNameLbl.text = "Client Name : \(project?.name ?? "")"
                
                usernameLbl.text = user?.username
                
                enterSummaryTxt.text = selectedTasks?.summary
                
                enterDescriptionTxtview.text = selectedTasks?.description
                
                self.selectStatusBaseView.isHidden = false
                self.selectStatusLabel.text = Utility.getTaskStringStatus(taskStatus: selectedTasks?.status ?? 0)
                self.selectStatusBaseView.backgroundColor = UIColor.init(hexString: "#E1E1E1")
                
                uploadBtn.isHidden = true
                uploadImage.isHidden = true
                
            }else {
                
                selectProjectBaseView.backgroundColor = UIColor.init(hexString: "#E1E1E1")
                projectNameLbl.textColor = UIColor.init(hexString: Constants.HexColors.wfmsBlue)
            
                (Constants.singleton.currentDevice == .pad) ? (projectNameLbl.font = UIFont.init(name: "lato", size: 18)) : (projectNameLbl.font = UIFont.init(name: "lato", size: 16))
                
                dropDownImage.isHidden = true
                projectNameLbl.text = "Select Project"
                usernameLbl.text = "Select User"
                enterSummaryTxt.text = "Enter Summary"
                
                enterDescriptionTxtview.text = "Enter Description"
                
                self.selectStatusBaseView.isHidden = true
                self.selectStatusLabel.text = ""
                
                uploadBtn.isHidden = false
                uploadImage.isHidden = false
            }
        }else {
            Utility.showAlert(message: "Project List / User List fail to load!")
        }
    }
    
    func handleUserListResponse() {
        
        if usersListArray.count > 0 {
            let users = usersListArray.map { (user) -> String in
                return user.username
            }
            
            let dropDown = DropDown()
            
            dropDown.anchorView = self.selectUserBaseView
            dropDown.width = self.selectUserBaseView.frame.size.width
            dropDown.direction = .any
            dropDown.bottomOffset = CGPoint.init(x: self.selectUserBaseView.frame.origin.x - 25, y: self.selectUserBaseView.frame.origin.y - 50)
            dropDown.dataSource = users
            dropDown.show()
            // Action triggered on selection
            dropDown.selectionAction = { (index: Int, item: String) in
                
                self.usernameLbl.text = item
                self.selectedUser = self.usersListArray[index]
            }
        }
    }
    
    func handleStatusResponse() {
        
        if statusarray.count > 0 {
            
            let dropDown = DropDown()
            
            dropDown.anchorView = self.selectStatusBaseView
            dropDown.width = self.selectStatusBaseView.frame.size.width
            dropDown.direction = .any
            dropDown.bottomOffset = CGPoint.init(x: self.selectStatusBaseView.frame.origin.x, y: self.selectStatusBaseView.frame.origin.y)
            dropDown.dataSource = statusarray
            dropDown.show()
            // Action triggered on selection
            dropDown.selectionAction = { (index: Int, item: String) in
                
                self.selectStatusLabel.text = item
            }
        }
    }
    
        
    //MARK: - Validation Method
    //MARK: -
    
    func validateFields() -> Bool {
        if projectNameLbl.text == "Select Project" || projectNameLbl.text == "" {
            Utility.showAlert(message: Constants.validationMesages.emptyProjectName)
            return false
        }else if usernameLbl.text == "Select User" || usernameLbl.text == "" {
            Utility.showAlert(message: Constants.validationMesages.emptyUserSelection)
            return false
        }else if enterSummaryTxt.text!.isEmpty {
            Utility.showAlert(message: Constants.validationMesages.emptySummary)
            return false
        }else if enterDescriptionTxtview.text!.isEmpty {
            Utility.showAlert(message: Constants.validationMesages.emptyDescription)
            return false
        }
        
        return true
    }

    
    //MARK: - Textfield delegate Methods
    //MARK: -
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.enterDescriptionTxtview.textColor = .black
        self.enterDescriptionTxtview.text = ""
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - Tap gesture events
    //MARK: -
    
    @IBAction func selectProjectClicked(_ sender: UITapGestureRecognizer) {
        if !isEditingTask {
            handleProjectListResponse()
        }
    }
    
    @IBAction func selectUserClicked(_ sender: UITapGestureRecognizer) {
        handleUserListResponse()
    }
    
    @IBAction func selectStatusActionClicked(_ sender: UITapGestureRecognizer) {
        handleStatusResponse()
    }

    
    //MARK: - Show Alert Message
    //MARK: --------------------------------
    func showAlert(msg: String,titleMsg: String) {
        let alert = UIAlertController.init(title: titleMsg, message: msg, preferredStyle: .alert)
        let action = UIAlertAction.init(title: "OK", style: .cancel) { (UIAlertAction) in
            
            self.dismiss(animated: true, completion: nil)

            if self.submitTaskFlag {
                self.navigationController?.popViewController(animated: true)
            }
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }

    //MARK: - Button Action Methods
    //MARK: -
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func submitBtnClicked(_ sender: UIButton) {
        if validateFields() {
            if !isEditingTask {
                submitTaskAPICall()
            }else{
                
                let statusStr = Utility.getTaskIntStatus(taskStatus: selectStatusLabel.text ?? "")
                
                editTaskCall(projectId: "\(selectedProject?.id ?? 0)", reporter_Id: "\(Constants.singleton.loginObject?.user_id ?? 0)", handler_Id: "\(selectedUser?.id ?? 0)", task_Id: "\(selectedTasks?.id ?? 0)", status: "\(statusStr)", summary: self.enterSummaryTxt.text ?? "", descStr: self.enterDescriptionTxtview.text ?? "")
            }
        }
    }
    
    
    @IBAction func uploadImageClicked(_ sender: UIButton) {
        CustomImagePicker.showAlert(view: CustomImagePicker.contentView!)
    }
    
    @IBAction func cancelBtnClicked(_ sender: UIButton) {
        
    }
    
    @IBAction func uploadImageBtnClicked(_ sender: UIButton) {
        
    }
    

}

extension AssignTaskViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {

        self.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)

        let image = info[.originalImage] as! UIImage
        self.selectedImage.image = image
        self.uploadImage.backgroundColor = .systemGreen
//        self.imageData = image.jpeg(.low)

        if let data = image.pngData(){
            if !self.imageData.contains(data) {
                imageData.append(data)
            }
        }

    }
}

class ProjectListModel: Mappable {
    
    var status: String = ""
    var data = [Projects]()
    var message: String = ""

    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        status <- map["status"]
        data <- map["data"]
        message <- map["message"]
    }
}

class Projects: Mappable {
    
    var id: Int?
    var name: String = ""
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
    }
}

class UserListModel: Mappable {
    
    var status: String = ""
    var data = [Users]()
    var message: String = ""

    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        status <- map["status"]
        data <- map["data"]
        message <- map["message"]
    }
}

class Users: Mappable {
    
    var id: Int?
    var email: String = ""
    var username: String = ""
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        email <- map["email"]
        username <- map["username"]
    }
}

class SubmitTaskModel: Mappable {
    
    var task_id: Int?
    var message: String = ""
    var status: String = ""
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        task_id <- map["task_id"]
        message <- map["message"]
        status <- map["status"]
    }
}

extension NSMutableData {

    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}


