//
//  ContentView.swift
//  MenuBarCountDown
//

import SwiftUI

struct ContentView: View {
    var isOpenSetting = false
    @State private var pleaseUpdateText = "Checking for updates..."
    let versionStr = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    var body: some View {
        VStack(spacing: 5) {
            Spacer().frame(height: 5)
            
            Text("Your version :  \(versionStr)☀️")
                .fontWeight(.light)
            
            Divider()
            
            // JSONテキスト
            Text(pleaseUpdateText).frame(height: 40)
            
            
            Divider()
            
            HStack(spacing: 10){
                // 設定画面を開く
                Button(action: {
                    NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                    NSApp.windows.forEach { if ($0.canBecomeMain) {$0.orderFrontRegardless() } }
                }) {
                    Text(NSLocalizedString("Preferences…", comment: "設定画面"))
                }
                .buttonStyle(DefaultButtonStyle())
                
                // アプリケーション終了
                Button(action: {NSApp.terminate(self)}) {
                    Text(NSLocalizedString("Quit", comment: "終了"))
                }
                .buttonStyle(DefaultButtonStyle())
            }
            
            Spacer().frame(height: 5)
        }
        .onAppear{
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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
