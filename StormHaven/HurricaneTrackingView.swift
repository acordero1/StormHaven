import SwiftUI
import CoreLocation
import MapKit

struct Hurricane: Identifiable {
    let id = UUID()
    let name: String
    let status: String
    let latitude: Double
    let longitude: Double
}

class UserLocationFetcher: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    
    @Published var userLocation: CLLocation? = nil
    @Published var locationError: String? = nil
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        userLocation = location
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationError = "Failed to get your location: \(error.localizedDescription)"
    }
}

struct HurricaneTrackingView: View {
    @StateObject private var userLocationFetcher = UserLocationFetcher()
    @State private var hurricanes: [Hurricane] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.yellow, Color.gray]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                if isLoading {
                    ProgressView("Fetching global hurricane data...")
                        .padding()
                        .foregroundColor(.white)
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.white)
                        .padding()
                } else if let userLocation = userLocationFetcher.userLocation {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            ForEach(hurricanes) { hurricane in
                                HurricaneCardView(hurricane: hurricane, userLocation: userLocation)
                            }
                        }
                        .padding()
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("🔵 = Your Location")
                                .font(.caption)
                                .foregroundColor(.white)
                            Text("🔴 = Storm Location")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        .padding()
                    }
                } else {
                    Text("Fetching your location...")
                        .font(.custom("Avenir", size: 24))
                        .foregroundColor(.white)
                        .padding()
                }
            }
            .navigationTitle("Current Storms")
            .onAppear {
                fetchHurricaneData()
            }
        }
    }

    func fetchHurricaneData() {
        let apiUrl = "https://www.nhc.noaa.gov/CurrentStorms.json"
        
        guard let url = URL(string: apiUrl) else {
            self.errorMessage = "Invalid URL"
            self.isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Error fetching data: \(error.localizedDescription)"
                    self.isLoading = false
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received from the server"
                    self.isLoading = false
                }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let activeStorms = json["activeStorms"] as? [[String: Any]] {
                    DispatchQueue.main.async {
                        self.hurricanes = activeStorms.compactMap { storm in

                            if let name = storm["name"] as? String,
                               let classification = storm["classification"] as? String,
                               let latitude = storm["latitudeNumeric"] as? Double,
                               let longitude = storm["longitudeNumeric"] as? Double {

                                return Hurricane(name: name, status: getReadableStatus(from: classification), latitude: latitude, longitude: longitude)
                            }
                            return nil
                        }
                        self.isLoading = false
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Error parsing data structure"
                        self.isLoading = false
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Error parsing data: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }.resume()
    }

    func getReadableStatus(from classification: String) -> String {
        switch classification {
        case "HU":
            return "Hurricane"
        case "TD":
            return "Tropical Depression"
        case "TS":
            return "Tropical Storm"
        case "EX":
            return "Extratropical Cyclone"
        case "LO":
            return "Low Pressure System"
        case "DB":
            return "Disturbance"
        default:
            return "Unknown"
        }
    }
}

struct HurricaneCardView: View {
    var hurricane: Hurricane
    var userLocation: CLLocation

    var body: some View {
        let hurricaneLocation = CLLocation(latitude: hurricane.latitude, longitude: hurricane.longitude)
        let distance = userLocation.distance(from: hurricaneLocation) * 0.000621371

        VStack(alignment: .leading, spacing: 10) {
            Text(hurricane.name)
                .font(.custom("Avenir", size: 36))
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Type: \(hurricane.status)")
                .font(.custom("Avenir", size: 24))
                .foregroundColor(.white)
                .fontWeight(.bold)
            
            Text(String(format: "Distance: %.2f miles away", distance))
                .font(.custom("Avenir", size: 24))
                .foregroundColor(.white)
                .fontWeight(.bold)
            
            Text("Storm Location:")
                .font(.custom("Avenir", size: 20))
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            InteractiveMapView(latitude: hurricane.latitude, longitude: hurricane.longitude, userLocation: userLocation)
                .frame(height: 200)
                .cornerRadius(10)
        }
        .padding()
        .background(Color.orange.opacity(0.7))
        .cornerRadius(10)
    }
}

struct InteractiveMapView: View {
    let latitude: Double
    let longitude: Double
    let userLocation: CLLocation

    @State private var region: MKCoordinateRegion = MKCoordinateRegion()

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: [
            MapAnnotationItem(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), pinColor: .red),
            MapAnnotationItem(coordinate: userLocation.coordinate, pinColor: .blue)
        ]) { item in
            MapMarker(coordinate: item.coordinate, tint: item.pinColor)
        }
        .onAppear {
            let stormLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            region = MKCoordinateRegion(center: stormLocation, latitudinalMeters: 100000, longitudinalMeters: 100000)
        }
    }
}

struct MapAnnotationItem: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
    var pinColor: Color
}

struct HurricaneTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        HurricaneTrackingView()
    }
}
