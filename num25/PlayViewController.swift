//
//  ViewController.swift
//  num25
//
//  Created by 蒼月喵 on 2018/6/12.
//  Copyright © 2018年 蒼月喵. All rights reserved.
//

import UIKit

class PlayViewController: UIViewController {
    var playTableVC: PlayTable?
    var stateViewVC: StateView?
    var scoreTableVC: ScoreTableViewController?
    
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var StartBtn: UIButton!
    @IBOutlet weak var PassBtn: UIButton!
    var timerTest : Timer?
    var sec = 0
    var name: String = "UnKnown"
    
    var db :SQLiteConnect?
    
    @IBAction func Start(_ sender: Any) {
//        leadingConstraint.constant = 200
        StartBtn.isHidden = true
        stateViewVC?.passBtn.isEnabled = true
        stateViewVC?.restartBtn.isEnabled = true
        startTimer()
    }
    
    @objc func timerActionTest() {
        print(" timer condition \(String(describing: timerTest))")
    }
    func startTimer () {
        if timerTest == nil {
            timerTest =  Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { (timer) in
                print("\(self.sec) 豪秒")
                self.sec = self.sec + 1
                if self.sec%100/10 == 0 {
                    self.stateViewVC?.timerLabel.text = "\(self.sec/100):0\(self.sec%100)"
                }else{
                    self.stateViewVC?.timerLabel.text = "\(self.sec/100):\(self.sec%100)"
                }
            }
        }
    }
    func passTimer () {
        if timerTest != nil {
            timerTest?.invalidate()
            timerTest = Timer()
        }
    }
    
    @IBAction func keepPlay(_ sender: Any) {
        PassBtn.isHidden = true
        startTimer()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        tabBar = tabBarController as! TabBarViewController
        
        PassBtn.isHidden = true
        stateViewVC?.passBtn.isEnabled = false
        stateViewVC?.restartBtn.isEnabled = false
        
        // 資料庫檔案的路徑
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let sqlitePath = urls[urls.count-1].absoluteString + "sqlite3.db"
        
        // 印出儲存檔案的位置
//        print(sqlitePath)
        
        // SQLite 資料庫
        db = SQLiteConnect(path: sqlitePath)
        
        if let mydb = db {
            
            // create table
            let _ = mydb.createTable("score", columnsInfo: [
                "id integer primary key autoincrement",
                "name text",
                "score text"])
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc1 = segue.destination as? PlayTable {
            playTableVC = vc1
            playTableVC?.delegate = self
        }
        if let vc2 = segue.destination as? StateView {
            stateViewVC = vc2
            stateViewVC?.delegate = self
        }
        if let vc3 = segue.destination as? ScoreTableViewController{
            scoreTableVC = vc3
        }
    }
}

extension PlayViewController: PlayDelegate {
    func addNextNum(_ nextNum: Int) {
//        print("XX")
        stateViewVC?.upNextNum(nextNum)
    }
    func passGame() {
        PassBtn.isHidden = false
        passTimer()
    }
    func restartGame() {
//        playTableVC?.randomList()
//        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        playTableVC?.viewDidLoad()
        playTableVC?.nextNum = 1
        stateViewVC?.upNextNum(1)
        StartBtn.isHidden = false
        PassBtn.isHidden = true
        stateViewVC?.timerLabel.text = "0"
        sec = 0
        passTimer()
    }
    func gameEnd() {
        passTimer()
        stateViewVC?.passBtn.isEnabled = false
        
        //enter score to db
        
        // 建立一個提示框
        var score: String = ""
        if sec%100/10 == 0 {
            score = "\(sec/100):0\(sec%100)"
        }else {
            score = "\(sec/100):\(sec%100)"
        }
        let alertController = UIAlertController(
            title: "您的成績為:",
            message: score,
            preferredStyle: .alert)
        
        // 建立一個輸入框
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = "Type Your Name Here"
        }
        
        // 建立[取消]按鈕
        let cancelAction = UIAlertAction(
            title: "取消",
            style: .cancel,
            handler: nil)
        alertController.addAction(cancelAction)
        
        // 建立[登入]按鈕
        let okAction = UIAlertAction(
            title: "輸入",
            style: UIAlertActionStyle.default) {
                (action: UIAlertAction!) -> Void in
                let acc =
                    (alertController.textFields?.first)!
                        as UITextField
                self.name = acc.text!
                
                // 資料庫檔案的路徑
                let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                let sqlitePath = urls[urls.count-1].absoluteString + "sqlite3.db"
                
                // SQLite 資料庫
                self.db = SQLiteConnect(path: sqlitePath)
                
                // insert DB
                if let mydb = self.db {
                    let _ = mydb.insert("score", rowInfo: ["name":"'\(self.name)'","score":"'\(score)'"])
                    print("insert")
                }
                self.scoreTableVC?.viewDidLoad()
        }
        alertController.addAction(okAction)
        
        // 顯示提示框
        self.present(
            alertController,
            animated: true,
            completion: nil)
        
    }
}
