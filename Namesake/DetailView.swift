//
//  DetailView.swift
//  Namesake
//
//  Created by Marjo Salo on 08/06/2021.
//

import SwiftUI
import CoreLocation
import MapKit

struct DetailView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Person.lastName, ascending: true)],
        animation: .default)
    private var people: FetchedResults<Person>
    
    @ObservedObject var person: Person

    let imageHandler = ImageHandler()
    @State var image: Image?
    
    @State private var showingEditView = false
    @State private var showingMapView = false
    
    @State private var region = MKCoordinateRegion()
    @State private var annotation = MKPointAnnotation()
    @State private var annotations = [MKPointAnnotation]()
    
    var body: some View {
        
        GeometryReader { geo in
            VStack(alignment: .center, spacing: 20) {
                    
                ZStack {
                    if showingMapView {
                        MapView(region: $region, annotation: $annotation, annotations: annotations)
                            .onAppear(perform: mapAnimation)
                
                    } else {
                        ZStack {
                            Rectangle()
                                .fill(Color.init(#colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)))
                                .overlay(Button(action: {
                                    showingEditView = true // picker instead?
                                }, label: {
                                    Image(systemName: "camera")
                                })
                                .font(.largeTitle)
                                .foregroundColor(.white))
                            
                            if image != nil {
                                image?
                                    .resizable()
                                    .scaledToFit()
                            }
                        }
                    }
                    
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            if person.location?.name != "Unknown" {
                                Button(showingMapView ? "Show image" : "Show map") {
                                    showingMapView.toggle()
                                }
                                .padding()
                            }
                        }
                    }
                }
                .frame(height: geo.size.height * 0.75)
                
                Text(person.unwrappedNotes)
                    .padding()
                
                VStack(spacing: 10) {
                    Text("Added on: \(person.unwrappedDate)")
                    if person.location != nil {
                        Text("Location: \(person.location!.unwrappedName)")
                    }
                }
                .font(.footnote)
                .padding()
            }
        }
        .onAppear(perform: getMap)
        
        .sheet(isPresented: $showingEditView, onDismiss: {
                getMap()
                image = imageHandler.loadImage(for: person)
        }) {
            AddEditView(filter: .edit, person: person, image: image)
                .environment(\.managedObjectContext, viewContext)
        }
        .toolbar {
            editButton
        }
        .navigationBarTitle(Text(person.unwrappedName), displayMode: .inline)
    }
    
    var editButton: some View {
        Button(action: {
            showingEditView = true
        }) {
           Text("Edit")
        }
    }
    
    func mapAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation {
                region.span = MKCoordinateSpan(
                    latitudeDelta: 0.05,
                    longitudeDelta: 0.05
                )
            }
        }
    }
    
    func getMap() {
        region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: person.latitude, longitude: person.longitude), span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0))
        
        for person in people {
            let pin = MKPointAnnotation()
            pin.title = person.unwrappedName
            pin.subtitle = person.location?.unwrappedName
            pin.coordinate = CLLocationCoordinate2D(latitude: person.latitude, longitude: person.longitude)
            annotations.append(pin)
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let previewPerson = Person(context: context)
        
        return DetailView(person: previewPerson, image: nil)
    }
}

