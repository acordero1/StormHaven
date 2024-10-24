import SwiftUI

struct AboutUsView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @State private var showLanguageOptions = false
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.green, Color.gray]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .center, spacing: 20) {
                Text(languageManager.getLocalizedText(for: "What is StormHaven?"))
                    .font(.custom("Avenir", size: 36))
                    .fontWeight(.bold)
                    .padding(.top)
                    .foregroundColor(.white)
                
                Text(languageManager.getLocalizedText(for: "With the onset of Hurricane Milton and its impact on southeast states like Florida and Georgia, StormHaven aims to educate people on the importance of safety as well as provide an outlet of information on places of evacuation."))
                    .font(.custom("Avenir", size: 24))
                    .multilineTextAlignment(.center)
                    .padding()
                    .foregroundColor(.white)
                
                Text(languageManager.getLocalizedText(for: "Who made StormHaven?"))
                    .font(.custom("Avenir", size: 30))
                    .fontWeight(.bold)
                    .padding(.top)
                    .foregroundColor(.white)
                
                Text(languageManager.getLocalizedText(for: "Alejandro Cordero\n  Dushant Lohano"))
                    .font(.custom("Avenir", size: 24))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding()

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    
                    Button(action: {
                        showLanguageOptions.toggle()
                    }) {
                        Image(systemName: "globe")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    .padding()
                    .accessibility(label: Text("Change Language"))
                }
            }
            .sheet(isPresented: $showLanguageOptions) {
                LanguagePicker()
                    .environmentObject(languageManager)
            }
        }
        .navigationTitle(languageManager.getLocalizedText(for: "About Us"))
    }
}
