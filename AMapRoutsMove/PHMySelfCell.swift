//
//  PHMySelfCell.swift
//  AMapRoutsMove
//
//  Created by 666GPS on 2017/3/27.
//  Copyright © 2017年 yang. All rights reserved.
//

import UIKit

class PHMySelfCell: UITableViewCell {

    @IBOutlet weak var lastLabel: UILabel!
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    // Class 初始化
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
