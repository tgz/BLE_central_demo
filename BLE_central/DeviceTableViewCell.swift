//
//  DeviceTableViewCell.swift
//  BLE_central
//
//  Created by qsc on 2018/3/30.
//  Copyright © 2018年 zerozero. All rights reserved.
//

import UIKit

class DeviceTableViewCell: UITableViewCell {
    
    static let reuseID = "device_table_view_cell"

    @IBOutlet weak var rssi: UILabel!
    @IBOutlet weak var name: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
