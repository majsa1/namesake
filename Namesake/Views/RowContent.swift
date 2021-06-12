//
//  RowContent.swift
//  Namesake
//
//  Created by Marjo Salo on 10/06/2021.
//

import SwiftUI

struct RowContent: View { 
    let person: Person
    
    let imageHandler = ImageHandler()
    var image: Image? {
        imageHandler.loadImage(for: person)
    }
    
    var body: some View {
        NavigationLink(destination: DetailView(person: person, image: image)) {
            HStack {
                if image != nil {
                    image?
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .cornerRadius(6)
                } else {
                    Rectangle()
                        .fill(Color.init(#colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)))
                        .frame(width: 60, height: 60)
                        .cornerRadius(6)
                        .overlay(Image(systemName: "person")
                                    .foregroundColor(.white))
                }
                Text(person.unwrappedName)
                    .padding(.leading, 5.0)
            }
        }
    }
}

struct RowContent_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let previewPerson = Person(context: context)
        
        RowContent(person: previewPerson)
    }
}
