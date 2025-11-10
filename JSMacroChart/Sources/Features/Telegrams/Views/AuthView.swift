//
//  AuthView.swift
//  JSMacroChart
//
//  Created by yangjs on 11/10/25.
//
import SwiftUI
struct AuthView: View {
    let title: String
        let placeholder: String
        @Binding var text: String
        var isSecure: Bool = false
        let action: () -> Void
   
        var body: some View {
            VStack(spacing: 15) {
                Text(title).font(.headline)
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
                Button("Send", action: action)
            }
            .textFieldStyle(.roundedBorder)
        }
}
#Preview {
    AuthView(
        title: "test",
        placeholder: "test",
        text: .constant(""),
        action: {}
    )
}
