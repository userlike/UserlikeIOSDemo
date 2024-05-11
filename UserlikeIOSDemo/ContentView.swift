//
//  ContentView.swift
//  UserlikeIOSDemo
//
//  Created by Daniel Hepper on 11.05.24.
//

import SwiftUI

struct ContentView: View {
    
    @State var chatZIndex: Double = -1
    @State var unreadChats: Int = 0
    @StateObject var webViewStore = WebViewStore()
    
    var body: some View {
        ZStack {
            UserlikeViewWrapper(webViewStore: webViewStore, onUnread: { unread in
                unreadChats = unread
            },
                                onMinimize: {
                chatZIndex = -1
            }).zIndex(chatZIndex)
            Color.white                            .ignoresSafeArea()
            VStack {
                Button(action: {
                    self.chatZIndex = 1
                }) {
                    Text("Show Chat")
                }
                Text("\(self.unreadChats) unread messages")
            }.padding()
        }
    }
}

#Preview {
    ContentView()
}
