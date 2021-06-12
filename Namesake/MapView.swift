//
//  MapView.swift
//  Namesake
//
//  Created by Marjo Salo on 08/06/2021.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var annotation: MKPointAnnotation
    var annotations: [MKPointAnnotation]
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        view.setRegion(region, animated: true)
        
        if annotations.count != view.annotations.count {
            view.removeAnnotations(view.annotations)
            view.addAnnotations(annotations)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        let parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier = "Placemark"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }
            return annotationView
        }
    }
}

extension MKPointAnnotation {
    static var example: MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.title = "Preview"
        annotation.subtitle = "Amsterdam"
        annotation.coordinate = CLLocationCoordinate2D(latitude: 52.3702157, longitude: 4.8951679)
        return annotation
    }
}

struct MapView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        MapView(region: .constant(MKCoordinateRegion(center: MKPointAnnotation.example.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))), annotation: .constant(MKPointAnnotation.example), annotations: [MKPointAnnotation.example])
    }
}
