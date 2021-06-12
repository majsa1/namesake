//
//  ClearButton.swift
//  Namesake
//
//  Created by Marjo Salo on 08/06/2021.
//

import SwiftUI

struct ClearButton: ViewModifier {
    @Binding var text: String
    
    func body(content: Content) -> some View {
        
        HStack {
            content
            Button(action: {
                text = ""
            }, label: {
                if text != "" {
                    Image(systemName: "multiply.circle.fill")
                        .foregroundColor(.gray)
                }
            })
        }
    }
}

extension View {
    func clearButton(text: Binding<String>) -> some View {
        self.modifier(ClearButton(text: text))
    }
}
