//
//  CalendarManager.swift
//  MenuBarCountDown
//

import Foundation
import EventKit

class CalendarManager {
    static let shared = CalendarManager()
    let eventStore: EKEventStore = EKEventStore()
    private init(){}
    
    /// カレンダー取得の権限があるかチェックし、許可されていればgetCalendarDataを呼ぶ
    func requestCalendarAccess() {
        if authorizationStatus() {
            // カレンダーの更新を監視
            setCalendarCheck()
            // カレンダー情報取得許可ずみ
            NotificationCenter.default.post(name: .updateTimer, object:nil)
        }else{
            // カレンダー情報取得許可ダイアログ表示
            eventStore.requestAccess(to: .event, completion: { granted, error in
                if granted {
                    print("allowed now")
                    // カレンダーの更新を監視
                    self.setCalendarCheck()
                    NotificationCenter.default.post(name: .updateTimer, object: nil)
                }
                else {
                    print("Not allowed")
                }
            })
        }
    }
    
    /// カレンダー取得の権限の状態を確認する
    /// - Returns: 許可されていればtrue
    func authorizationStatus() -> Bool {
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch status {
        case .authorized:
            print("Authorized")
            return true
        case .notDetermined:
            print("Not determined")
            return false
        case .restricted:
            print("Restricted")
            return false
        case .denied:
            print("Denied")
            return false
        @unknown default:
            print("Unknown default")
            return false
        }
    }
    
    
    /// ローカルのカレンダーアプリからイベントのデータを取得する
    func getCalendarData() -> [EKEvent] {
        let calendars = eventStore.calendars(for: .event)
        // 検索条件
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = 23
        components.minute = 59
        let endOfDay = calendar.date(from: components)!
        
        let predicate = eventStore.predicateForEvents(
            withStart: Date(),
            end: endOfDay,
            calendars: calendars)
        let events = eventStore.events(matching: predicate)
        return events
    }
    
    
    /// 取得したイベントデータをもとに表示するイベントを返す
    /// - Parameter events: 取得したイベントデータの配列
    /// - Returns: 表示するイベントデータ（開始時間が最も現在時刻に近いイベントとなる）
    func getEventToDisplay(events: [EKEvent]) -> EKEvent{
        for event in events {
            if let eventStartDate = event.startDate {
                // 現時刻より先にあるイベントの開始時刻とタイトルをタイマーにセット
                if Date() < eventStartDate {
                    return event
                }
            }
        }
        // 予定がなければ定時までカウントダウンする
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: Date())
        let defaultQuittingTime = calendar.date(bySettingHour: 19, minute: 0, second: 0, of: calendar.date(from: components)!)!

        let userDefaults = UserDefaults.standard
        let quittingTime = userDefaults.object(forKey: "quittingTime") as? Date ?? defaultQuittingTime
        // 定時のEKEventオブジェクト作成
        let event = EKEvent(eventStore: eventStore)
        event.title = "定時"
        event.startDate = quittingTime
        return event
        
    }
    
    // カレンダーの更新チェック
    func setCalendarCheck(){
        DispatchQueue.main.async {
            Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
                NotificationCenter.default.post(name: .updateTimer, object:nil)
            }
        }
    }
}

