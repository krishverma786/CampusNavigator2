import SwiftUI
import MapKit

struct UIKitMapView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> MKMapView {
        
        let mapView = MKMapView()
        
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        mapView.showsScale = true
        
        let coordinate = CLLocationCoordinate2D(
            latitude: 30.7681,
            longitude: 76.5754
        )
        
        mapView.setRegion(
            MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(
                    latitudeDelta: 0.003,
                    longitudeDelta: 0.003
                )
            ),
            animated: false
        )
        
        return mapView
    }
    
    func updateUIView(
        _ mapView: MKMapView,
        context: Context
    ) {
        // Updates can be added later.
    }
}
