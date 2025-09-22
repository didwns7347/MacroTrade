//
//  FloatingButton.swift
//  JSMacroChart
//
//  Created by yangjs on 9/19/25.
//

import SwiftUI

struct FloatingButton: View {
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            ScrollView {
                VStack {
                    ForEach(0..<50) { i in
                        Text("리스트 \(i)")
                            .padding()
                    }
                }
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        print("FAB 눌림")
                    }) {
                        HStack {
                            Image(systemName: "sparkle")
                            Text("AI 자산 진단")
                            
                        }.padding()
                            .font(.headline)
                        
                        
                    }
                    .background(Color.accentColor)
                    .foregroundColor(Color(UIColor.systemGray6))
                    .clipShape(.capsule)
                    .padding()
                }
            }
        }
    }
}

#Preview {
    FloatingButton()
}
