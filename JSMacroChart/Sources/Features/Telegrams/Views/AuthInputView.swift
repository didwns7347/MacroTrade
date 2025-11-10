
import SwiftUI

struct AuthInputView: View {
    let title: String
    let subtitle: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // MARK: - Header
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // MARK: - Input Field
            VStack(alignment: .leading) {
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .keyboardType(.default)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(.phonePad)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            Spacer()

            // MARK: - Action Button
            Button(action: action) {
                HStack {
                    Spacer()
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                    } else {
                        Text("Continue")
                            .fontWeight(.semibold)
                    }
                    Spacer()
                }
            }
            .padding()
            .background(isLoading ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .disabled(isLoading)
        }
        .padding()
    }
}

#Preview {
    AuthInputView(
        title: "Enter Phone",
        subtitle: "You will receive a confirmation code.",
        placeholder: "+1 234 567 8900",
        text: .constant(""),
        isLoading: false,
        action: {}
    )
}
