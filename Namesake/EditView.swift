//
//  EditView.swift
//  Namesake
//
//  Created by Marjo Salo on 08/06/2021.
//

import SwiftUI
import CoreLocation

struct EditView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Location.name, ascending: true)],
        animation: .default)
    private var locations: FetchedResults<Location>
    
    let person: Person
    @Binding var image: Image?
    
    let imageHandler = ImageHandler()
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var notes = ""

    @State private var inputImage: UIImage?
    @State private var showingImagePicker = false
    
    let locationFetcher = LocationFetcher()
    @State private var location = "Unknown"
    @State private var centerCoordinate = CLLocationCoordinate2D()
    
    var body: some View {
        
        NavigationView {
     
            Form {
                
                Section(header: Text("Change image"), content: {
                    EditImage(image: image)
                })
                .onTapGesture {
                    showingImagePicker = true
                }
                
                Section(header: Text("Edit details"), content: {
                    
                    TextField("First Name", text: $firstName)
                        .clearButton(text: $firstName)

                    TextField("Last Name", text: $lastName)
                        .clearButton(text: $lastName)
           
                    TextField("Notes", text: $notes)
                        .clearButton(text: $notes)
                })
                Section(header: Text("Edit location"), content: {
                    HStack {
                        Text(location)
                        Spacer()
                        Button("Get") { 
                            locationFetcher.lookUpCurrentLocation { currentLocation in
                                if let place = currentLocation {
                                    location = "\(place.locality ?? "Unknown place"), \(place.isoCountryCode ?? "Unknown country")"
                                }
                                if let coordinates = locationFetcher.lastKnownLocation {
                                    centerCoordinate = coordinates 
                                }
                            }
                        }
                    }
                })
            }
            .onAppear(perform: prepareView)
            
            .sheet(isPresented: $showingImagePicker, onDismiss: { image = imageHandler.selectImage(inputImage: inputImage) ?? image }) {
                ImagePicker(image: $inputImage)
            }
            .navigationBarTitle("Edit Person", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    Button("Save") {
                        editPerson()
                        presentationMode.wrappedValue.dismiss()
                    }
                })
                ToolbarItem(placement: .navigationBarLeading, content: {
                    Button("Cancel") {
                        image = imageHandler.loadImage(for: person)
                        presentationMode.wrappedValue.dismiss()
                    }
                })
            }
        }
    }
    
    func prepareView() {
        locationFetcher.start()
        firstName = person.unwrappedFirst
        lastName = person.unwrappedLast
        notes = person.unwrappedNotes
        location = person.location?.unwrappedName ?? "Unknown"
        centerCoordinate.latitude = person.latitude
        centerCoordinate.longitude = person.longitude
    }
    
    func editPerson() {
        person.firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        person.lastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        person.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        person.latitude = centerCoordinate.latitude
        person.longitude = centerCoordinate.longitude
        
        if let place = person.location {
            place.removeFromPeople(person)
         
            if let existingLocation = locations.first(where: { $0.name == location }) {
                existingLocation.addToPeople(person)
            } else {
                let newLocation = Location(context: viewContext)
                newLocation.name = location
                newLocation.addToPeople(person)
            }
            
            if place.personArray.count == 0 {
                viewContext.delete(place)
            }
        }
      
        imageHandler.saveImage(inputImage: inputImage, for: person)
    
        do {
            try viewContext.save() 
        } catch {
            print("Unable to edit person with id \(person.unwrappedId)")
        }
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let previewPerson = Person(context: context)
        
        return EditView(person: previewPerson, image: .constant(nil))
    }
}
