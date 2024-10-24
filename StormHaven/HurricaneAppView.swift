import SwiftUI

struct HurricaneAppView: View {
    @State private var hurricaneDistance: Double = 100
    @State private var hurricaneCategory: Int = 1
    @State private var supplies: [String] = []
    
    func updateSupplies(for distance: Double, and category: Int) {
        switch category {
        case 5:
            supplies = ["Immediate evacuation required", "Emergency contacts", "Important documents", "First-aid kit", "Water for 5 days", "Non-perishable food for 5 days", "Flashlight", "Batteries", "Weather radio"]
        case 4:
            if distance < 50 {
                supplies = ["Evacuation highly recommended", "First-aid kit", "Water for 4 days", "Non-perishable food for 4 days", "Important documents", "Flashlight", "Batteries", "Weather radio"]
            } else if distance < 100 {
                supplies = ["Prepare to evacuate", "First-aid kit", "Water for 3 days", "Non-perishable food for 3 days", "Flashlight", "Batteries"]
            } else {
                supplies = ["Monitor the situation closely", "Basic first-aid kit", "Water", "Food", "Keep extra batteries"]
            }
        case 3:
            if distance < 50 {
                supplies = ["Possible evacuation", "First-aid kit", "Water for 3 days", "Non-perishable food for 3 days", "Flashlight", "Batteries"]
            } else if distance < 100 {
                supplies = ["Prepare for the storm", "Canned food", "Water", "Basic first-aid kit", "Portable phone charger"]
            } else {
                supplies = ["Monitor the storm", "Basic emergency kit", "Extra batteries", "Canned food", "Water"]
            }
        case 2:
            supplies = distance < 50 ? ["Stay prepared for potential evacuation", "Water", "Food", "First-aid kit", "Flashlight"] : ["Monitor the news", "Basic supplies", "Batteries", "Flashlight"]
        case 1:
            supplies = distance < 50 ? ["Prepare for strong winds", "Flashlight", "First-aid kit", "Water", "Batteries"] : ["Stay alert but no immediate action", "Monitor the news", "Basic emergency supplies"]
        default:
            supplies = ["Invalid category, please check the hurricane details."]
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Incoming Hurricane")
                        .font(.custom("Avenir", size: 36))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    Text("Select distance of hurricane:")
                        .font(.custom("Avenir", size: 24))
                        .foregroundColor(.white)
                    
                    Slider(value: $hurricaneDistance, in: 0...300, step: 1)
                        .padding()
                        .accentColor(.blue)
                    
                    Text("Hurricane is \(Int(hurricaneDistance)) miles away")
                        .font(.custom("Avenir", size: 20))
                        .foregroundColor(.white)
                    
                    Text("Select category of hurricane:")
                        .font(.custom("Avenir", size: 24))
                        .foregroundColor(.white)
                    
                    Picker("Hurricane Category", selection: $hurricaneCategory) {
                        ForEach(1...5, id: \.self) { category in
                            Text("\(category)").tag(category)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    Text("Selected Category: \(hurricaneCategory)")
                        .font(.custom("Avenir", size: 18))
                        .foregroundColor(.white)
                    
                    .onChange(of: hurricaneDistance) { newValue in
                        updateSupplies(for: newValue, and: hurricaneCategory)
                    }
                    .onChange(of: hurricaneCategory) { newValue in
                        updateSupplies(for: hurricaneDistance, and: newValue)
                    }
                    
                    Text("Recommended Supplies:")
                        .font(.custom("Avenir", size: 20))
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                    
                    ForEach(supplies, id: \.self) { supply in
                        Text("• \(supply)")
                            .font(.custom("Avenir", size: 18))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.blue, Color.gray]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
            )
            .onAppear {
                updateSupplies(for: hurricaneDistance, and: hurricaneCategory)
            }
        }
    }
}

struct HurricaneAppView_Previews: PreviewProvider {
    static var previews: some View {
        HurricaneAppView()
    }
}
