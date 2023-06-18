//
//  SettingView.swift
//  MenuBarCountDown
//

import SwiftUI

struct SettingView: View {
    // プロパティ(UserDefaultsに保持)
    @AppStorage("isShowTitle") private var isShowTitle = true
    //    @AppStorage("fontSize") private var fontSize = 12.0
    //    @AppStorage("userId") private var userId = ""
    
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
            
            //            // スライドバー
            //            Slider(value: $fontSize, in: 9...96) {
            //                Text("Font Size (\(fontSize, specifier: "%.0f") pts)")
            //            }
            //
            //            // テキスト入力エリア
            //            TextField("ユーザID", text: $userId)
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
