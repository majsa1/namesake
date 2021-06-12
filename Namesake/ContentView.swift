//
//  ContentView.swift
//  Namesake
//
//  Created by Marjo Salo on 08/06/2021.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Location.name, ascending: true)],
        animation: .default)
    private var locations: FetchedResults<Location>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Person.lastName, ascending: true)],
        animation: .default)
    private var people: FetchedResults<Person>
    
    let imageHandler = ImageHandler()
    @State private var showingAddView = false
    @State private var sortByName = false

    var body: some View {
        
        NavigationView {
            List {
                if !sortByName {
                    ForEach(locations) { location in
                        Section(header: Text(location.unwrappedName)) {
                            ForEach(location.personArray, content: RowContent.init)
                            .onDelete {
                                deleteFromSection(at: $0, in: location)
                            }
                        }
                    }
                } else {
                    ForEach(people, content: RowContent.init)
                    .onDelete(perform: deleteFromList)
                }
            }
        
            .navigationBarTitle("Namesake")
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    toggleButton
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    addButton
                }
            }
            .sheet(isPresented: $showingAddView) {
                AddView()
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }
    
    var toggleButton: some View {
        Button(action: {
            sortByName.toggle()
        }, label: {
            Text(sortByName ? "Show location" : "Show list")
        })
    }
    
    var addButton: some View {
        Button(action: {
            showingAddView = true
        }) {
            Label("Add Person", systemImage: "plus")
        }
    }
    
    func deleteFromList(at offsets: IndexSet) {
        for offset in offsets {
            let person = people[offset]
            let location = person.location
            delete(person: person, location: location)
        }
    }

    func deleteFromSection(at offsets: IndexSet, in location: Location) {
        for offset in offsets {
            let person = location.personArray[offset]
            delete(person: person, location: location)
        }
    }
    
    func delete(person: Person, location: Location?) {
        
        if let place = person.location {
            place.removeFromPeople(person)
        
            if place.personArray.isEmpty {
                viewContext.delete(place)
            }
        }
        imageHandler.deleteImage(person: person)
        viewContext.delete(person)
    
        do {
            try viewContext.save()
        } catch {
            print("Unable to delete person with id \(person.unwrappedId)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView()
    }
}
