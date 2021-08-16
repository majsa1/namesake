//
//  AddEditView.swift
//  Namesake
//
//  Created by Marjo salo on 15/06/2021.
//

import SwiftUI
import CoreLocation

struct AddEditView: View {
    enum FilterType {
        case add, edit
    }
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Location.name, ascending: true)],
        animation: .default)
    private var locations: FetchedResults<Location>
    
    let filter: FilterType
    let person: Person?
    @State var image: Image? 
    
    @State private var imageSectionTitle = ""
    @State private var detailsSectionTitle = ""
    @State private var locationSectionTitle = ""
    @State private var navBarTitle = ""

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var notes = ""
    
    @State private var showingImagePicker = false
    @State private var showingLocationText = false
    @State private var showingAlert = false

    let imageHandler = ImageHandler()
    @State private var inputImage: UIImage?
    
    let locationFetcher = LocationFetcher()
    @State private var location = "Unknown"
    @State private var centerCoordinate = CLLocationCoordinate2D()
    
    var body: some View {
        
        NavigationView {
     
            Form {
                
                Section(header: Text(imageSectionTitle), content: {
                    EditImage(image: image)
                })
                .onTapGesture {
                    showingImagePicker = true
                }
                
                Section(header: Text(detailsSectionTitle), content: {
                    
                    TextField("First Name", text: $firstName)
                        .clearButton(text: $firstName)

                    TextField("Last Name", text: $lastName)
                        .clearButton(text: $lastName)
           
                    TextField("Notes", text: $notes)
                        .clearButton(text: $notes)
                })
                Section(header: Text(locationSectionTitle), content: {
                    HStack {
                        Text(location)
                        Spacer()
                        Button("Get") {
                            locationFetcher.lookUpCurrentLocation {
                                currentLocation in
                                getLocation(currentLocation)
                            }
                        }
                    }
                })
            }
            .onAppear(perform: prepareView)
            
            .sheet(isPresented: $showingImagePicker, onDismiss: {
                image = imageHandler.selectImage(inputImage: inputImage)
            }) {
                ImagePicker(image: $inputImage)
            }
            .navigationBarTitle(navBarTitle, displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    Button("Save") {
                        filter == .add ? addPerson() : editPerson()
                    }
                })
                ToolbarItem(placement: .navigationBarLeading, content: {
                    Button("Cancel") {
                        cancel()
                    }
                })
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Details missing"), message: Text("Please fill in all details"), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func prepareView() {
        getTitles()
        locationFetcher.start()
        
        if filter == .add {
            showingImagePicker = true
        } else {
            if let person = person {
                firstName = person.unwrappedFirst
                lastName = person.unwrappedLast
                notes = person.unwrappedNotes
                location = person.location?.unwrappedName ?? "Unknown"
                centerCoordinate.latitude = person.latitude
                centerCoordinate.longitude = person.longitude
            }
        }
    }
    
    func getTitles() {
        switch filter {
        case .add:
            imageSectionTitle = "Import image"
            detailsSectionTitle = "Enter details"
            locationSectionTitle = "Location"
            navBarTitle = "Add person"
        case .edit:
            imageSectionTitle = "Change Image"
            detailsSectionTitle = "Edit details"
            locationSectionTitle = "Change location"
            navBarTitle = "Edit person"
        }
    }
    
    func getLocation(_ currentLocation: CLPlacemark?) {
        if let place = currentLocation {
            location = "\(place.locality ?? "Unknown place"), \(place.isoCountryCode ?? "Unknown country")"
        }
        if let coordinates = locationFetcher.lastKnownLocation {
            centerCoordinate = coordinates
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
        
        let newLocation = Location(context: viewContext)
        newLocation.name = location
        newLocation.addToPeople(newPerson)
        
        save(newPerson)
    }
    
    func editPerson() {
        guard !firstName.isEmpty || !lastName.isEmpty else {
            showingAlert = true
            return
        }
        
        if let person = person {
            person.firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
            person.lastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
            person.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
            person.latitude = centerCoordinate.latitude
            person.longitude = centerCoordinate.longitude
            
            if let place = person.location {
                place.removeFromPeople(person)
             
                let newLocation = Location(context: viewContext)
                newLocation.name = location
                newLocation.addToPeople(person)
                
                if place.personArray.count == 0 {
                    viewContext.delete(place)
                }
            }
            save(person)
        }
    }
    
    func save(_ person: Person) {
        imageHandler.saveImage(inputImage: inputImage, for: person)
    
        do {
            try viewContext.save()
        } catch {
            print("Unable to add person with id \(person.unwrappedId)")
        }
        presentationMode.wrappedValue.dismiss()
    }
    
    func cancel() {
        if filter == .edit {
            image = imageHandler.loadImage(for: person ?? Person())
        }
        presentationMode.wrappedValue.dismiss()
    }
}

struct AddEditView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let previewPerson = Person(context: context)
        
        return AddEditView(filter: .add, person: previewPerson, image: nil)
    }
}
