//
//  ScoreTableViewController.swift
//  num25
//
//  Created by 蒼月喵 on 2018/6/15.
//  Copyright © 2018年 蒼月喵. All rights reserved.
//

import UIKit

class ScoreTableViewController: UITableViewController {
    
    var db :SQLiteConnect?
    var nameList: [String] = []
    var scoreList: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameList = []
        scoreList = []
        
        // 資料庫檔案的路徑
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let sqlitePath = urls[urls.count-1].absoluteString + "sqlite3.db"
        
        // SQLite 資料庫
        db = SQLiteConnect(path: sqlitePath)
        
        if let mydb = db {
            // select
            let statement = mydb.fetch("score", cond: nil, order: "score")
            while sqlite3_step(statement) == SQLITE_ROW{
                
//                let id = sqlite3_column_int(statement, 0)
                let name = String(cString: sqlite3_column_text(statement, 1))
                let score = String(cString: sqlite3_column_text(statement, 2))
                nameList.append(name)
                scoreList.append(score)
                
                print("\(name) ： \(score)")
            }
            sqlite3_finalize(statement)
        }
        print(nameList.count)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return nameList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = "\(indexPath.row + 1). \(nameList[indexPath.row]) : \(scoreList[indexPath.row])"

        return cell
    }
    

}
