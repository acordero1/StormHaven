import SwiftUI
import CoreLocation
import MapKit

struct RedCrossLocation: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let distance: Double
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
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
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        switch status {
        case .denied:
            locationError = "Location access denied. Please enable it in settings."
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location access granted")
        default:
            break
        }
    }
}

struct NearestRedCrossView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var redCrossLocations: [RedCrossLocation] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.red, Color.gray]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                if isLoading {
                    ProgressView("Red Cross Near You")
                        .padding()
                        .foregroundColor(.white)
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.white)
                        .padding()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            ForEach(redCrossLocations.prefix(3)) { location in
                                Button(action: {
                                    openInMaps(latitude: location.latitude, longitude: location.longitude, placeName: location.name)
                                }) {
                                    RedCrossCardView(location: location)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Red Cross Near You")
            .onAppear {
                if let location = locationManager.userLocation {
                    fetchRedCrossLocations(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                } else {
                    errorMessage = "Unable to retrieve location"
                    isLoading = false
                }
            }
        }
    }
    
    func fetchRedCrossLocations(latitude: Double, longitude: Double) {
        let apiKey = getGoogleAPIKey()
        let radius = 50000
        let url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(latitude),\(longitude)&radius=\(radius)&keyword=red+cross&key=\(apiKey)"
        
        guard let requestURL = URL(string: url) else {
            self.errorMessage = "Invalid URL"
            self.isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: requestURL) { data, response, error in
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
                   let results = json["results"] as? [[String: Any]] {
                    DispatchQueue.main.async {
                        self.redCrossLocations = results.compactMap { result in
                            if let name = result["name"] as? String,
                               let vicinity = result["vicinity"] as? String,
                               let geometry = result["geometry"] as? [String: Any],
                               let location = geometry["location"] as? [String: Double],
                               let placeLat = location["lat"],
                               let placeLon = location["lng"] {
                                let userLocation = CLLocation(latitude: latitude, longitude: longitude)
                                let placeLocation = CLLocation(latitude: placeLat, longitude: placeLon)
                                let distanceInMeters = userLocation.distance(from: placeLocation)
                                let distanceInKilometers = distanceInMeters / 1000
                                
                                return RedCrossLocation(name: name, address: vicinity, latitude: placeLat, longitude: placeLon, distance: distanceInKilometers)
                            }
                            return nil
                        }
                        self.isLoading = false
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Error parsing data"
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

    func openInMaps(latitude: Double, longitude: Double, placeName: String) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = placeName
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}

struct RedCrossCardView: View {
    var location: RedCrossLocation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(location.name)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(location.address)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(String(format: "%.2f km away", location.distance))
                .font(.body)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.red.opacity(0.7))
        .cornerRadius(10)
    }
}

func getGoogleAPIKey() -> String {
    guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "GooglePlacesAPIKey") as? String else {
        fatalError("Google Places API Key is missing in Info.plist")
    }
    return apiKey
}

struct NearestRedCrossView_Previews: PreviewProvider {
    static var previews: some View {
        NearestRedCrossView()
    }
}
