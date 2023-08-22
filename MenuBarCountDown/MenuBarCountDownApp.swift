//
//  MenuBarCountDownApp.swift
//  MenuBarCountDown
//

import SwiftUI
import EventKit

@main
struct MenuBarCountDownApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        Settings{
            PreferencesView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem!
    var popover = NSPopover()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Dockにアプリを表示しない
        NSApp.setActivationPolicy(.accessory)
        // Notificationの受信設定
        NotificationCenter.default.addObserver(self, selector: #selector(updateTimer), name: .updateTimer, object: nil)
        
        // ポップオーバーウインドウの設定
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: ContentView())
        
        // ステータスバーの設定
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        guard let button = self.statusBarItem.button else { return }
        button.font = NSFont.monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        button.title = "Reading Calendar Data..."
        // アクションの設定
        button.action = #selector(menuButtonAction(sender: ))
        // カレンダーアプリから取得
        CalendarManager.shared.requestCalendarAccess()
    }
    
    /// カレンダーからイベント情報を取得しタイマーに反映する
    /// NotificationCenterからの通知を受け取った際に起動
    @objc func updateTimer() {
        print("received notification")
        let events = CalendarManager.shared.getCalendarData()
        let event = CalendarManager.shared.getEventToDisplay(events: events)
        
        TimerManager.shared.setUp(statusBarItem: statusBarItem)
        TimerManager.shared.timerStart(targetTime: event.startDate, eventTitle: event.title)
        
    }
    
    @objc func menuButtonAction(sender: AnyObject) {
        
        guard let button = self.statusBarItem.button else { return }
        if self.popover.isShown {
            self.popover.performClose(sender)
        } else {
            // ポップアップを表示
            self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            // 他の位置をクリックすると消える
            self.popover.contentViewController?.view.window?.makeKey()
        }
    }
    
}

