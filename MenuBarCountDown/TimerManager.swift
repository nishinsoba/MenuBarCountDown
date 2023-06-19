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
        // 予定名を隠す設定になっているかチェック
        let isShowTitle = UserDefaults.standard.bool(forKey: "isShowTitle")
        if(!isShowTitle){
            showTitle = "次の予定"
        }
        print("timerStart \(showTitle), \(targetTime)")
        
        // カウントダウン単位設定チェック
        let timeUnit = UserDefaults.standard.string(forKey: "timeUnit") ?? "0.1s"
        
        var pattern = ""
        switch timeUnit {
        case "0.1s":
            pattern = "%02i h %02i m %02i.%01i s"
        case "1s":
            pattern = "%02i h %02i m %02i s"
        case "1m":
            pattern = "%02i h %02i m"
        default:
            pattern = "%02i h %02i m %02i.%01i s"
        }
        
        DispatchQueue.main.async {
            guard let button = self.statusBarItem?.button else { return }
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                button.title = self.makeTimerStr(targetTime: targetTime, showTitle: showTitle, pattern: pattern)
            }
        }
    }
    
    func makeTimerStr(targetTime :Date, showTitle: String, pattern: String) -> String{
        let now = Date()
        let timeDifference = now.timeIntervalSince(targetTime)
        let timeLeft = timeDifference > 0 ? timeDifference : -timeDifference
        let hoursLeft = Int(timeLeft) / 3600
        let minutesLeft = Int(timeLeft) / 60 % 60
        let secondsLeft = Int(timeLeft) % 60
        let millisecondsLeft = Int(timeLeft * 10) % 10
                
        if timeDifference > 0 {
            // 過去
            return String(format: "\(showTitle) から \(pattern)", hoursLeft, minutesLeft, secondsLeft, millisecondsLeft)
        } else {
            // 未来
            return String(format: "\(showTitle) まで \(pattern)", hoursLeft, minutesLeft, secondsLeft, millisecondsLeft)
        }
    }
}
