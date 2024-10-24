import SwiftUI

struct LanguagePicker: View {
    @EnvironmentObject var languageManager: LanguageManager
    let languages = ["English", "Spanish", "French", "German", "Chinese"]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(languages, id: \.self) { language in
                    Button(action: {
                        languageManager.selectedLanguage = language
                    }) {
                        HStack {
                            Text(language)
                            if languageManager.selectedLanguage == language {
                                Spacer()
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Choose Language", displayMode: .inline)
        }
    }
}
