//
//  MarkDownView.swift
//  JSMacroChart
//
//  Created by yangjs on 10/21/25.
//

import SwiftUI
import MarkdownUI

struct MarkdownViewer: View {
    let markdown: String
    
    var body: some View {
        Markdown(markdown)
    }
}

#Preview {
    MarkdownViewer(markdown: """
    # Title
    **Bold Text**, *Italic*
    - List 1
    - List 2

    [Link](https://apple.com)
    """)
}
