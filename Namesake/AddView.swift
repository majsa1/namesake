//
//  AddView.swift
//  Namesake
//
//  Created by Marjo Salo on 08/06/2021.
//

import SwiftUI
import CoreLocation

struct AddView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Location.name, ascending: true)],
        animation: .default)
    private var locations: FetchedResults<Location>
    
    let imageHandler = ImageHandler()
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var notes = ""
    
    @State private var image: Image?
    @State private var inputImage: UIImage?
    
    @State private var showingImagePicker = true
    @State private var showingLocationText = false
    @State private var showingAlert = false
    
    let locationFetcher = LocationFetcher()
    @State private var location = "Unknown"
    @State private var centerCoordinate = CLLocationCoordinate2D()
    
    var body: some View {
        
        NavigationView {
     
            Form {
                Section(header: Text("Import image"), content: {
                    EditImage(image: image)
                })
                .onTapGesture {
                    showingImagePicker = true
                }
                
                Section(header: Text("Enter details"), content: {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    TextField("Notes", text: $notes)
                })
                
                Section(header: Text("Location"), content: {
                    HStack {
                        if showingLocationText {
                           Text(location)
                        } else { 
                            Spacer()
                            Button("Get") {
                                locationFetcher.lookUpCurrentLocation { currentLocation in
                                    if let place = currentLocation {
                                        location = "\(place.locality ?? "Unknown place"), \(place.isoCountryCode ?? "Unknown country")"
                                        showingLocationText = true
                                    }
                                }
                                if let coordinates = locationFetcher.lastKnownLocation {
                                    centerCoordinate = coordinates
                                }
                            }
                        }
                    }
                })
            }
            .onAppear(perform: locationFetcher.start)
        
            .fullScreenCover(isPresented: $showingImagePicker, onDismiss: { image = imageHandler.selectImage(inputImage: inputImage) }) {
                ImagePicker(image: $inputImage)
            }
            .navigationBarTitle("Add Person", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    Button("Save") {
                        addPerson()
                    }
                })
                ToolbarItem(placement: .navigationBarLeading, content: {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                })
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Details missing"), message: Text("Please fill in all details"), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func addPerson() {
        guard !firstName.isEmpty || !lastName.isEmpty else {
            showingAlert = true
            return
        }
        
        let newPerson = Person(context: viewContext)
        newPerson.firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        newPerson.lastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        newPerson.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        newPerson.id = UUID().uuidString
        newPerson.date = Date()
        newPerson.latitude = centerCoordinate.latitude
        newPerson.longitude = centerCoordinate.longitude
        
        if let existingLocation = locations.first(where: { $0.name == location }) {
            existingLocation.addToPeople(newPerson) 
        } else {
            let newLocation = Location(context: viewContext)
            newLocation.name = location
            newLocation.addToPeople(newPerson)
        }
        imageHandler.saveImage(inputImage: inputImage, for: newPerson)
    
        do {
            try viewContext.save() 
        } catch {
            print("Unable to add person with id \(newPerson.unwrappedId)")
        }
        presentationMode.wrappedValue.dismiss()
    }
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView()
    }
}
