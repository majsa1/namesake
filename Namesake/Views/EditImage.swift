//
//  EditImage.swift
//  Namesake
//
//  Created by Marjo Salo on 10/06/2021.
//

import SwiftUI

struct EditImage: View {
    let image: Image?
    
    var body: some View {
        ZStack {
            if image != nil {
                image?
                    .resizable()
                    .cornerRadius(8.0)
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(Color.init(#colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)))
                    .frame(height: 300)
                    .cornerRadius(8.0)
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Image(systemName: "camera")
                        .padding()
                        .font(.largeTitle)
                        .foregroundColor(.white)
                }
            }
            
        }
    }
}

struct EditImage_Previews: PreviewProvider {
    static var previews: some View {
        EditImage(image: nil)
    }
}
