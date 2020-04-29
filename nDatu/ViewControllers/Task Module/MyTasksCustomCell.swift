//
//  MyTasksCustomCell.swift
//  nDatu
//
//  Created by Sagar Ranshur on 17/04/20.
//  Copyright © 2020 Sagar Ranshur. All rights reserved.
//

import UIKit

protocol MyTasksCustomCellDelegate {
    func editAction(index: IndexPath)
}

class MyTasksCustomCell: UITableViewCell {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var taskIdLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    var delegate: MyTasksCustomCellDelegate?
    var indexpath = IndexPath()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.baseView.elevate(elevation: 2.0)
        self.baseView.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        self.statusLabel.textColor = .darkGray
    }
    
    @IBAction func editBtnClicked(_ sender: UIButton) {
        delegate?.editAction(index: indexpath)
    }
}
