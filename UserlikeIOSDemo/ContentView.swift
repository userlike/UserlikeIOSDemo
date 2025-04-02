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
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var customData: String = ""
    @State private var customDataError: String? = nil
    
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
                //Text("\(self.unreadChats) unread messages")
                Button(action: {
                    self.chatZIndex = 1
                }) {
                    Text("Show Chat")
                }
                .padding(.bottom, 16)
                
                TextField("Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: {
                    // NOTE: potential code injection here, name and email must be properly escaped
                    let jsCode = "setContactInfo('\(name)', '\(email)');"
                    webViewStore.webView.evaluateJavaScript(jsCode) { result, error in
                        if let error = error {
                            print("Error calling setContactInfo: \(error)")
                        } else {
                            print("Successfully called setContactInfo")
                        }
                    }
                }) {
                    Text("SetContactInfo")
                }
                .padding(.bottom, 16)
                
                // Input field for Custom Data and its button
                TextEditor(text: $customData)
                    .frame(height: 100) // Approx. 5 lines high
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    .onChange(of: customData) {
                        validateCustomData()
                    }
                    .keyboardType(.asciiCapable)
                                    
                    // Show error message if JSON is invalid.
                    if let errorMessage = customDataError {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                
                Button(action: {
                    // NOTE: potential code injection here, customData must be properly escaped
                    let jsCode = "setCustomData('\(customData)');"
                    webViewStore.webView.evaluateJavaScript(jsCode) { result, error in
                        if let error = error {
                            print("Error calling setCustomData: \(error)")
                        } else {
                            print("Successfully called setCustomData")
                        }
                    }
                }) {
                    Text("SetCustomData")
                }
                .padding(.bottom, 16)
                // Disable button if the custom data is not valid JSON.
               .disabled(customDataError != nil)
            }.padding()
        }
    }
    
    /// Validates the customData string.
    /// Sets customDataError to an error message if invalid, or nil if valid.
    private func validateCustomData() {
        if customData.isEmpty {
            customDataError = nil
            return
        }
        
        guard let data = customData.data(using: .utf8) else {
            customDataError = "Invalid encoding."
            return
        }
        do {
            _ = try JSONSerialization.jsonObject(with: data, options: [])
            customDataError = nil  // Valid JSON
        } catch {
            customDataError = "Invalid JSON format."
        }
    }
}

#Preview {
    ContentView()
}
