//
//  DashboardVC.swift
//  nDatu
//
//  Created by Sagar Ranshur on 15/04/20.
//  Copyright © 2020 Sagar Ranshur. All rights reserved.
//

import UIKit

class DashboardVC: UIViewController {
    
    @IBOutlet weak var reportTaskBaseView: UIView!
    @IBOutlet weak var myTasksBaseView: UIView!
    @IBOutlet weak var completedTasksBaseView: UIView!
    @IBOutlet weak var sideMenuBaseView: UIView!
    @IBOutlet weak var sideMenuWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraintSideView: NSLayoutConstraint!
    @IBOutlet weak var userProfileWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var baseView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    func setUpView()  {
        hideSideMenu()
        self.reportTaskBaseView.elevate(elevation: 2.0)
        self.myTasksBaseView.elevate(elevation: 2.0)
        self.completedTasksBaseView.elevate(elevation: 2.0)
        self.sideMenuBaseView.elevate(elevation: 2.0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    //MARK: - API CALL Method
    //MARK: -
    
    
    
    //MARK: - Hide & Show Side bar Menu
    //MARK: -
    
    func showSideMenu()  {
        UIView.animate(withDuration: 0.5) {
            self.sideMenuWidthConstraint.constant = Constants.HardcodedData.screenWidth * 0.75
            self.leadingConstraintSideView.constant = 0
            self.userProfileWidthConstraint.constant = 45
            self.sideMenuBaseView.isHidden = false
            self.baseView.isUserInteractionEnabled = true
            self.view.layoutIfNeeded()
        }
    }
    
    func hideSideMenu()  {
        UIView.animate(withDuration: 0.5) {
            self.leadingConstraintSideView.constant = -200
            self.sideMenuWidthConstraint.constant = 0
            self.baseView.isUserInteractionEnabled = false
            self.view.layoutIfNeeded()
        }
    }
    
    func showAlert(msg: String)  {
        let alert = UIAlertController.init(title: "", message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Ok", style: .destructive) { (alertAction) in
            self.navigationController?.popViewController(animated: true)
        }
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .destructive) { (alertAction) in
            self.dismiss(animated: true, completion: nil)
            self.hideSideMenu()
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)

        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Button Action Methods
    //MARK: -
        
    @IBAction func sideMenuClicked(_ sender: UIButton) {
        showSideMenu()
    }
    
    @IBAction func mainViewClicked(_ sender: UITapGestureRecognizer) {
        hideSideMenu()
    }
    
    
    @IBAction func assignTaskBtnClicked(_ sender: UIButton) {
        let assignVC = Constants.Storyboards.main.instantiateViewController(identifier: "AssignTaskViewController") as! AssignTaskViewController
        self.navigationController?.pushViewController(assignVC, animated: true)
    }
    
        
    @IBAction func logoutBtnClicked(_ sender: UIButton) {
        showAlert(msg: Constants.validationMesages.logoutConfirmationMsg)
    }
    
    
    @IBAction func myTaskBtnClicked(_ sender: UITapGestureRecognizer) {
        
        let myTasksVC = Constants.Storyboards.main.instantiateViewController(identifier: "MyTasksViewController") as! MyTasksViewController
        self.navigationController?.pushViewController(myTasksVC, animated: true)
    }

    
    @IBAction func completedTaskClicked(_ sender: UITapGestureRecognizer) {
        let myTasksVC = Constants.Storyboards.main.instantiateViewController(identifier: "MyTasksViewController") as! MyTasksViewController
        myTasksVC.isOnlyCompleteTasks = true
        self.navigationController?.pushViewController(myTasksVC, animated: true)
    }
    
    @IBAction func homeAssignBtnClicked(_ sender: UIButton) {
        let assignVC = Constants.Storyboards.main.instantiateViewController(identifier: "AssignTaskViewController") as! AssignTaskViewController
        self.navigationController?.pushViewController(assignVC, animated: true)
    }
}
