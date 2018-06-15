//
//  PlayDelegate.swift
//  num25
//
//  Created by 蒼月喵 on 2018/6/15.
//  Copyright © 2018年 蒼月喵. All rights reserved.
//

import Foundation
protocol PlayDelegate:class {
//    func addOneToScore()
    func addNextNum(_ nextNum: Int)
    func passGame()
    func restartGame()
    func gameEnd()
}
