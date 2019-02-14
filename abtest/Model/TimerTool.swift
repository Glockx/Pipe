//
//  TimerTool.swift
//  abtest
//
//  Created by Muzaffarli Nijat on 12/02/2019.
//  Copyright © 2019 Nijat Muzaffarli. All rights reserved.
//

import Foundation

class TimerTool: NSObject
{
    static let shareInstance = TimerTool()
    var timeRemaning: TimeInterval!
    var pauseButtonState = true
    var pauseButtonText = "Pause"
    var startButtonState = false
    var stopButtonState = true
    var timerState = false
    var timeLabelState = true
    var timerIsOn = false
    var timer = Timer()
}
