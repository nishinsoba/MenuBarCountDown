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
    
    var body: some View {
        // フォーム
        Form {
            // トグルスイッチ
            Toggle("予定タイトルを表示する", isOn: $isShowTitle)
                .onChange(of: isShowTitle) { value in
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
