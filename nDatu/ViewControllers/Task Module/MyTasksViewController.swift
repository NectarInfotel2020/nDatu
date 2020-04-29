//
//  MyTasksViewController.swift
//  nDatu
//
//  Created by Sagar Ranshur on 16/04/20.
//  Copyright © 2020 Sagar Ranshur. All rights reserved.
//

import UIKit
import ObjectMapper

class MyTasksViewController: UIViewController {

    @IBOutlet weak var tapView1: UIView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var tapView2: UIView!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var tapView3: UIView!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var tapView4: UIView!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var tasksTableView: UITableView!
    @IBOutlet weak var bottomTabView: UIView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    var isOnlyCompleteTasks = false
    var tasksArray = [Tasks]()
    var mainTasksArray = [Tasks]()
    var selectedOption = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if isOnlyCompleteTasks {
            bottomTabView.isHidden = true
            topConstraint.constant = -30
        }else {
            bottomTabView.isHidden = false
            topConstraint.constant = 16
        }
        if Constants.singleton.currentDevice == .pad {
            tasksTableView.estimatedRowHeight = 180
        }else {
            tasksTableView.estimatedRowHeight = 120
        }
        tasksTableView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        getAllTasksListAPICall()
        setAssignAsInitial()
    }
    
    func setAssignAsInitial(){
        label1.textColor = UIColor.init(hexString: Constants.HexColors.wfmsCyan)
        tapView1.backgroundColor = UIColor.init(hexString: Constants.HexColors.wfmsCyan)
        
        tapView2.backgroundColor = .white
        label2.textColor = UIColor.init(hexString: Constants.HexColors.wfmsBlue)
        tapView3.backgroundColor = .white
        label3.textColor = UIColor.init(hexString: Constants.HexColors.wfmsBlue)
        tapView4.backgroundColor = .white
        label4.textColor = UIColor.init(hexString: Constants.HexColors.wfmsBlue)
    }
    
    //MARK: - Web API call Method
    //MARK: -
    
    func getAllTasksListAPICall()  {
        
        Utility.startIndicator()
        
        WebService.requestServiceWithPostMethod(url: "", requestType: Constants.RequestType.viewtask) { (data, error) in
            
            do {
                Utility.hideIndicator()
                
                if let jsonData = data {
                    let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                    Utility.printLog(key: "Response", value: json as Any)
                    
                    if let myTaskResponceObject = MyTasksModel.init(JSON: json!)
                    {
                        if myTaskResponceObject.status == "success" {
                           
                            if myTaskResponceObject.data.count > 0 {
                                
                                self.handleResponse(tasksArr: myTaskResponceObject.data)
                            }

                        }else if myTaskResponceObject.status == "fail" {
                            Utility.showAlert(message: myTaskResponceObject.message)
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
    
    
    func handleResponse(tasksArr: [Tasks]) {
        
        self.mainTasksArray = tasksArr

        if isOnlyCompleteTasks {
            Utility.startIndicator()
            tasksArray = [Tasks]()
            let reportedByMe = mainTasksArray.filter { (task) -> Bool in
                return task.status == 20
                }
            if reportedByMe.count > 0 {
                Utility.hideIndicator()
                tasksArray = reportedByMe
                self.tasksTableView.reloadData()
            }

        }else {
            //sort arrays
             let assignToMe = tasksArr.filter { (task) -> Bool in
                 return Constants.singleton.loginObject?.user_id == task.handler_id
                 }
             if assignToMe.count > 0 {
                 tasksArray = assignToMe
                 self.tasksTableView.reloadData()
             }
        }
    }
    
    //MARK: - Button Action Methods
    //MARK: -

    @IBAction func backButtonClicked(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func completedTasksClicked(_ sender: UIButton) {
        
        //sort arrays
        Utility.startIndicator()
        tasksArray = [Tasks]()
        let reportedByMe = mainTasksArray.filter { (task) -> Bool in
            return task.status == 20
            }
        if reportedByMe.count > 0 {
            Utility.hideIndicator()
            tasksArray = reportedByMe
            self.tasksTableView.reloadData()
        }
        
        selectedOption = "Completed"
        
        label4.textColor = UIColor.init(hexString: Constants.HexColors.wfmsCyan)
        tapView4.backgroundColor = UIColor.init(hexString: Constants.HexColors.wfmsCyan)
        
        tapView1.backgroundColor = .white
        label1.textColor = UIColor.init(hexString: Constants.HexColors.wfmsBlue)
        tapView2.backgroundColor = .white
        label2.textColor = UIColor.init(hexString: Constants.HexColors.wfmsBlue)
        tapView3.backgroundColor = .white
        label3.textColor = UIColor.init(hexString: Constants.HexColors.wfmsBlue)
    }
    
    @IBAction func monitorededByMeClicked(_ sender: UIButton) {
        
        //sort arrays
        Utility.startIndicator()
        tasksArray = [Tasks]()
        let reportedByMe = mainTasksArray.filter { (task) -> Bool in
            return Constants.singleton.loginObject?.user_id == task.reporter_id
            }
        if reportedByMe.count > 0 {
            Utility.hideIndicator()
            tasksArray = reportedByMe
            self.tasksTableView.reloadData()
        }

        selectedOption = "Monitor"
        
        label3.textColor = UIColor.init(hexString: Constants.HexColors.wfmsCyan)
        tapView3.backgroundColor = UIColor.init(hexString: Constants.HexColors.wfmsCyan)
        
        tapView1.backgroundColor = .white
        label1.textColor = UIColor.init(hexString: Constants.HexColors.wfmsBlue)
        tapView2.backgroundColor = .white
        label2.textColor = UIColor.init(hexString: Constants.HexColors.wfmsBlue)
        tapView4.backgroundColor = .white
        label4.textColor = UIColor.init(hexString: Constants.HexColors.wfmsBlue)
    }
    
    @IBAction func reportedByMeClicked(_ sender: UIButton) {
        
        //sort arrays
        Utility.startIndicator()
        tasksArray = [Tasks]()

        let reportedByMe = mainTasksArray.filter { (task) -> Bool in
            return Constants.singleton.loginObject?.user_id == task.reporter_id
            }
        if reportedByMe.count > 0 {
            Utility.hideIndicator()
            tasksArray = reportedByMe
            self.tasksTableView.reloadData()
        }

        selectedOption = "Reported"
        
        label2.textColor = UIColor.init(hexString: Constants.HexColors.wfmsCyan)
        tapView2.backgroundColor = UIColor.init(hexString: Constants.HexColors.wfmsCyan)
        
        tapView1.backgroundColor = .white
        label1.textColor = UIColor.init(hexString: Constants.HexColors.wfmsBlue)
        tapView3.backgroundColor = .white
        label3.textColor = UIColor.init(hexString: Constants.HexColors.wfmsBlue)
        tapView4.backgroundColor = .white
        label4.textColor = UIColor.init(hexString: Constants.HexColors.wfmsBlue)
    }
    
    @IBAction func assignedToMeClicked(_ sender: UIButton) {
        
        //sort arrays
        Utility.startIndicator()
        tasksArray = [Tasks]()

        let assignToMe = mainTasksArray.filter { (task) -> Bool in
            return Constants.singleton.loginObject?.user_id == task.handler_id
            }
        if assignToMe.count > 0 {
            Utility.hideIndicator()
            tasksArray = assignToMe
            self.tasksTableView.reloadData()
        }
        
        selectedOption = "Assign"

        
        label1.textColor = UIColor.init(hexString: Constants.HexColors.wfmsCyan)
        tapView1.backgroundColor = UIColor.init(hexString: Constants.HexColors.wfmsCyan)
        
        tapView2.backgroundColor = .white
        label2.textColor = UIColor.init(hexString: Constants.HexColors.wfmsBlue)
        tapView3.backgroundColor = .white
        label3.textColor = UIColor.init(hexString: Constants.HexColors.wfmsBlue)
        tapView4.backgroundColor = .white
        label4.textColor = UIColor.init(hexString: Constants.HexColors.wfmsBlue)
    }
}

extension MyTasksViewController : UITableViewDelegate,UITableViewDataSource, MyTasksCustomCellDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tasksTableView.dequeueReusableCell(withIdentifier: "cell") as! MyTasksCustomCell
        
        let taskObj = tasksArray[indexPath.row]
        cell.indexpath = indexPath
        cell.delegate = self
        
        ( taskObj.id != 0 ) ? ( cell.taskIdLabel.text = "Task ID : \(taskObj.id ?? 0)" ) : ( cell.taskIdLabel.text = "Task ID : N.A" )
        
        ( taskObj.summary != "" ) ? ( cell.summaryLabel.text = "Summary : \(taskObj.summary )" ) : ( cell.summaryLabel.text = "Summary : N.A" )

        ( taskObj.description != "" ) ? ( cell.descriptionLabel.text = "Description : \(taskObj.description )" ) : ( cell.taskIdLabel.text = "Description : N.A" )
        
        if taskObj.status != 0 {
            cell.statusLabel.text = "Status : \(Utility.getTaskStringStatus(taskStatus: taskObj.status ?? 0))"
            if taskObj.status == 20 {
                cell.statusLabel.textColor = .systemGreen
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func editAction(index: IndexPath) {
        // go to
        let taskObj = tasksArray[index.row]
        let taskToEdit = Constants.Storyboards.main.instantiateViewController(identifier: "AssignTaskViewController") as! AssignTaskViewController
        taskToEdit.selectedTasks = taskObj
        taskToEdit.isEditingTask = true
        navigationController?.pushViewController(taskToEdit, animated: true)
    }
}

class MyTasksModel: Mappable {
    
    var data = [Tasks]()
    var message: String = ""
    var status: String = ""
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        data <- map["data"]
        message <- map["message"]
        status <- map["status"]
    }
}

class Tasks: Mappable {
    
    var id: Int?
    var project_id: Int?
    var reporter_id: Int?
    var handler_id: Int?
    var status: Int?
    var summary: String = ""
    var description: String = ""
    
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        project_id <- map["project_id"]
        reporter_id <- map["reporter_id"]
        handler_id <- map["handler_id"]
        status <- map["status"]
        summary <- map["summary"]
        description <- map["description"]
    }
}

