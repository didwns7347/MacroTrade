//
//  MessageView.swift
//  JSMacroChart
//
//  Created by yangjs on 9/23/25.
//
import SwiftUI
struct MessageView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
            }
            
            Text(message.content)
                .padding(12)
                .background(message.role == .user ? Color.blue : Color(UIColor.secondarySystemBackground))
                .foregroundColor(message.role == .user ? .white : .primary)
                .cornerRadius(16)
                .textSelection(.enabled)
            
            if message.role == .assistant {
                Spacer()
            }
        }
    }
}
#Preview {
    MessageView(message: ChatMessage(role: .assistant, content: "hello?"))
}
