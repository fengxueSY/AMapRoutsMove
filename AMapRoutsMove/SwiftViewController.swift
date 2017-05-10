//
//  SwiftViewController.swift
//  AMapRoutsMove
//
//  Created by 666GPS on 2017/3/24.
//  Copyright © 2017年 yang. All rights reserved.
//

import UIKit

class SwiftViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var _tableView = UITableView();
    var titleArrayOne:NSArray = ["我的驾校","我的学员","我的车辆","我的教练","我的订单"]
    var titleArrayTwo:NSArray = ["关于我们","当前版本","清除缓存","退出登录"]
    override func viewDidLoad() {
        super.viewDidLoad()
        creatBaseUI()
    }
    func creatBaseUI() {
        _tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), style: UITableViewStyle.plain)
        _tableView.delegate = self
        _tableView.dataSource = self
        self.view.addSubview(_tableView)
        let cellID = "ID"
        _tableView.register(UINib.init(nibName: "PHMySelfCell", bundle: nil), forCellReuseIdentifier: cellID)
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2;
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 5
        }else{
            return 4
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "ID"
        let cell:PHMySelfCell = tableView.dequeueReusableCell(withIdentifier: cellID) as! PHMySelfCell
       
        cell.setSelected(true, animated: true)
        if indexPath.section == 0 {
            cell.nameLabel.text = "\(titleArrayOne[indexPath.row])"
        }else{
            cell.nameLabel.text = "\(titleArrayTwo[indexPath.row])"
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            let v = ViewController()
            v.showT("查看显示的是怎么")
            OCModel.str("1", success: { (succeed) in
                print("\(succeed)")
            }, fail: { (faild) in
                print("\(faild)")
            });
            
        }
        if indexPath.row == 3 {
            let v = ViewController()
            v.showT("查看显示的是怎么")
            OCModel.str("2", success: { (succeed) in
                print("\(succeed)")
            }, fail: { (faild) in
                print("\(faild)")
            });
        }
    }
    func showText (str:String){
        print("\(str)")
    }
  
    class wc: WCAlertView {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
