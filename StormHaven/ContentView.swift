import SwiftUI

struct ContentView: View {
    @State private var isActive = false
    @State private var opacity = 1.0

    var body: some View {
        ZStack {
            MainTabView()
                .opacity(isActive ? 1 : 0)
            SplashScreenView()
                .opacity(opacity)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeInOut(duration: 1.5)) {
                    self.opacity = 0.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.isActive = true
                }
            }
        }
    }
}

struct SplashScreenView: View {
    @State private var scaleEffect = 0.8
    @State private var opacity = 0.5

    var body: some View {
        VStack {
            Image(systemName: "tornado")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.white)
                .padding(.bottom, 20)
            
            Text("StormHaven")
                .font(.custom("Avenir", size: 36))
                .foregroundColor(.white)
                .shadow(radius: 10)

        }
        .scaleEffect(scaleEffect)
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                self.scaleEffect = 1.0
                self.opacity = 1.0
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.black]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
        )
    }
}

struct MainTabView: View {
    @StateObject var languageManager = LanguageManager()
    init() {
        UITabBar.appearance().backgroundColor = UIColor.systemGray6
    }
    
    var body: some View {
        TabView {
            HurricaneAppView()
                .tabItem {
                    Label("Hurricane", systemImage: "cloud.bolt.fill")
                }
            
            NearestRedCrossView()
                .tabItem {
                    Label("Red Cross", systemImage: "cross.circle.fill")
                }
            
            HurricaneTrackingView()
                .tabItem {
                    Label("Tracker", systemImage: "map.fill")
                }

            AboutUsView()
                .tabItem {
                    Label("About Us", systemImage: "person.crop.circle.fill")
                }
        }
        .environmentObject(languageManager)
        .accentColor(.blue)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
