//
//  SwiftTwoView.swift
//  AMapRoutsMove
//
//  Created by 666GPS on 2017/3/24.
//  Copyright © 2017年 yang. All rights reserved.
//

import UIKit

class SwiftTwoView: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var tableView = UITableView();

    override func viewDidLoad() {
        super.viewDidLoad()
        creatBaseUI()
        // Do any additional setup after loading the view.
    }
    func creatBaseUI() {
        tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), style: UITableViewStyle.plain)
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30;
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "ID"
        let cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: cellID)
        cell.textLabel?.text = "这是第\(indexPath.row)"
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
