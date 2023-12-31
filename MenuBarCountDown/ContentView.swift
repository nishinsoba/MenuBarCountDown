//
//  ContentView.swift
//  MenuBarCountDown
//

import SwiftUI
import EventKit

struct ContentView: View {
    var isOpenSetting = false
    @State private var pleaseUpdateText = "Checking for updates..."
    let versionStr = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    @State private var eventCountDowns: [String] = []
    @State var preferencesWindow:NSWindow?
    @State var preferencesWindowCont:NSWindowController?
    let preferencesView = PreferencesView()
    static var timer:Timer = Timer()
    
    
    var body: some View {
        VStack(spacing: 5) {
            
            Spacer().frame(height: 5)
            
            VStack(alignment: .trailing){
                ForEach(eventCountDowns, id: \.self) { eventContDown in
                    Text(eventContDown)
                }
            }
            
            Divider()
            
            Group {
                Text("Your version :  \(versionStr)☀️")
                    .fontWeight(.light)
                
                Divider()
                
                // JSONテキスト
                Text(pleaseUpdateText).frame(height: 40)
                
                
                Divider()
                
                // リリースページ
                Text("[MenuBarCountDown releases page](https://github.com/nishinsoba/MenuBarCountDown/releases)")
            }
            
            Divider()
            
            HStack(spacing: 10){
                // 設定画面を開く
                Button(action: {
                    NSApplication.shared.activate(ignoringOtherApps: true)
                    self.showPreferencesWindow()
                }) {
                    Text("Preferences…")
                }
                .buttonStyle(DefaultButtonStyle())
                
                // アプリケーション終了
                Button(action: {NSApp.terminate(self)}) {
                    Text("Quit")
                }
                .buttonStyle(DefaultButtonStyle())
                
            }
            
            Divider()
            
            Spacer().frame(height: 5)
            
        }
        .frame(width: 300)
        .onAppear{
            contentAppear()
            setCalendarCheck()
        }
    }
    
    // onAppear時に行いたい処理をまとめたもの
    func contentAppear(){
        print("contentAppear")
        // 最新バージョンチェック
        // HTTP GETリクエスト
        let url = URL(string: "https://raw.githubusercontent.com/nishinsoba/MenuBarCountDown/main/MenuBarCountDown/version.json")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                // JSONデータの処理
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let latestVersion = json["version"] as? String {
                        DispatchQueue.main.async {
                            if latestVersion > versionStr{
                                // アップデート通知
                                pleaseUpdateText = "Please update!\nA new version ✨\(latestVersion)✨ is available."
                            }else{
                                // アップデート不要
                                pleaseUpdateText = "Your version is already the latest.\nHave a nice day!"
                            }
                        }
                    }
                    
                }
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        task.resume()
        
        // カウントダウン単位設定チェック
        let timeUnit = UserDefaults.standard.string(forKey: "timeUnit") ?? "0.1s"
        
        var pattern = ""
        var interval = 0.1
        switch timeUnit {
        case "0.1s":
            pattern = "%02i h %02i m %02i.%01i s"
            interval = 0.1
        case "1s":
            pattern = "%02i h %02i m %02i s"
            interval = 1
        case "1m":
            pattern = "%02i h %02i m"
            interval = 60
        default:
            pattern = "%02i h %02i m %02i.%01i s"
            interval = 0.1
        }
        
        let events = CalendarManager.shared.getCalendarData()
        eventCountDowns = []
        events.forEach { event in
                // 表示用文字列を作成して一旦eventCountDownsに詰める
                eventCountDowns.append(TimerManager.shared.makeTimerStr(targetTime: event.startDate, showTitle: event.title, pattern: pattern))
        }
        // 表示用文字列をリアルタイムに更新する
        ContentView.timer.invalidate()
        DispatchQueue.main.async {
            ContentView.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
                events.enumerated().forEach{ index, event in
                    // eventCountDownsの中身を更新する
                    eventCountDowns[index] = TimerManager.shared.makeTimerStr(targetTime: event.startDate, showTitle: event.title, pattern: pattern)
                }
            }
        }
    }
    
    // カレンダーの更新チェック
    func setCalendarCheck(){
        DispatchQueue.main.async {
            Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
                contentAppear()
            }
        }
    }
    
    func showPreferencesWindow(){
        if let window = self.preferencesWindow, let windowCont = self.preferencesWindowCont {
            // すでに設定画面が存在するならアクティブにする
            NSApplication.shared.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
        } else {
            // 存在していなければ生成して表示する
            self.preferencesWindow = NSWindow(contentRect: NSMakeRect(0, 0, 480, 300),styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView], backing: NSWindow.BackingStoreType.buffered, defer: false)
            self.preferencesWindow!.title = "preferences"
            self.preferencesWindow!.isOpaque = false
            self.preferencesWindow!.center()
            self.preferencesWindow!.contentView = NSHostingView(rootView: self.preferencesView)
            self.preferencesWindow!.isMovableByWindowBackground = true
            self.preferencesWindow!.makeKeyAndOrderFront(nil)
            
            self.preferencesWindowCont = NSWindowController(window:self.preferencesWindow)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
