//
//  UserlikeIOSDemoApp.swift
//  UserlikeIOSDemo
//
//  Created by Daniel Hepper on 11.05.24.
//

import SwiftUI

@main
struct UserlikeIOSDemoApp: App {
    init() {
        // Slightly better JSON editor
        DispatchQueue.main.async {
            UITextView.appearance().smartQuotesType = .no
            UITextView.appearance().smartDashesType = .no
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
