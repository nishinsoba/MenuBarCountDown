//
//  ContentView.swift
//  MenuBarCountDown
//

import SwiftUI

struct ContentView: View {
    var isOpenSetting = false
    var body: some View {
        VStack(spacing: 5) {
            Spacer().frame(height: 5)
            
            Text("Hello, world!")
                .fontWeight(.light)
            
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
