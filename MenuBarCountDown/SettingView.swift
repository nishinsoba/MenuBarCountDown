//
//  SettingView.swift
//  MenuBarCountDown
//

import SwiftUI

struct SettingView: View {
    // プロパティ(UserDefaultsに保持)
    @AppStorage("isShowTitle") private var isShowTitle = true
    @AppStorage("timeUnit") private var timeUnit = "0.1s"
    let timeUnits = ["0.1s", "1s", "1m"]
    
    // Date型はAppStorageでは扱えないため手動でuserDefaultsに読み書きする
    let userDefaults = UserDefaults.standard
    @State private var quittingTime:Date
    init(){
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: Date())
        let defaultQuittingTime = calendar.date(bySettingHour: 19, minute: 0, second: 0, of: calendar.date(from: components)!)!
        
        _quittingTime = State(initialValue: userDefaults.object(forKey: "quittingTime") as? Date ?? defaultQuittingTime)
    }
    
    var body: some View {
        // フォーム
        Form {
            // トグルスイッチ
            Toggle("予定タイトルを表示する", isOn: $isShowTitle)
                .onChange(of: isShowTitle) { value in
                    // タイマー表示更新
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .updateTimer, object:nil)
                    }
                }
            
            Spacer()
            
            // プルダウン
            Picker("カウント時間の単位: ", selection: $timeUnit) {
                ForEach(timeUnits, id: \.self) { unit in
                    Text(unit).tag(unit)
                }
            }.onChange(of: timeUnit) {
                value in
                // タイマー表示更新
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .updateTimer, object:nil)
                }
            }
            
            Spacer()
            
            DatePicker("定時: ", selection: $quittingTime, displayedComponents: [.hourAndMinute])
                .datePickerStyle(CompactDatePickerStyle())
                .onChange(of: quittingTime) { value in
                    userDefaults.set(quittingTime, forKey: "quittingTime")
                    // タイマー表示更新
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .updateTimer, object:nil)
                    }
                }
            
            
        }
        .padding(20)
        .frame(width: 350, height: 100)
        
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
