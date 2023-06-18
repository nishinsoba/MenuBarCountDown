//
//  TimerManager.swift
//  MenuBarCountDown
//

import Foundation
import AppKit

class TimerManager {
    
    static let shared = TimerManager()
    var timer:Timer = Timer()
    var statusBarItem: NSStatusItem?
    
    private init(){}
    
    func setUp(statusBarItem: NSStatusItem) {
        self.statusBarItem = statusBarItem
        
    }
    
    func timerStart(targetTime :Date, eventTitle: String){
        timer.invalidate()
        
        var showTitle = eventTitle
        let isShowTitle = UserDefaults.standard.bool(forKey: "isShowTitle")
        print(isShowTitle)
        if(!isShowTitle){
            showTitle = "次の予定"
        }
        print("timerStart \(showTitle), \(targetTime)")
        
        DispatchQueue.main.async {
            guard let button = self.statusBarItem?.button else { return }
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                button.title = makeTimerStr(targetTime: targetTime, showTitle: showTitle)
            }
        }
        
        func makeTimerStr(targetTime :Date, showTitle: String) -> String{
            let now = Date()
            let timeDifference = now.timeIntervalSince(targetTime)
            let timeLeft = timeDifference > 0 ? timeDifference : -timeDifference
            let hoursLeft = Int(timeLeft) / 3600
            let minutesLeft = Int(timeLeft) / 60 % 60
            let secondsLeft = Int(timeLeft) % 60
            let millisecondsLeft = Int(timeLeft * 10) % 10
            if timeDifference > 0 {
                return String(format: "\(showTitle) から %02i h %02i m %02i.%01i s", hoursLeft, minutesLeft, secondsLeft, millisecondsLeft)
            } else {
                return String(format: "\(showTitle) まで %02i h %02i m %02i.%01i s", hoursLeft, minutesLeft, secondsLeft, millisecondsLeft)
            }
        }
    }
}
