import SwiftUI

class LanguageManager: ObservableObject {
    @Published var selectedLanguage: String = "English"
    
    func getLocalizedText(for text: String) -> String {
        switch selectedLanguage {
        case "Spanish":
            return translateToSpanish(text)
        case "French":
            return translateToFrench(text)
        case "German":
            return translateToGerman(text)
        case "Chinese":
            return translateToChinese(text)
        default:
            return text
        }
    }
    
    private func translateToSpanish(_ text: String) -> String {
        switch text {
        case "What is StormHaven?": return "¿Qué es StormHaven?"
        case "Who made StormHaven?": return "¿Quién hizo StormHaven?"
        case "With the onset of Hurricane Milton and its impact on southeast states like Florida and Georgia, StormHaven aims to educate people on the importance of safety as well as provide an outlet of information on places of evacuation.": return "Con la llegada del huracán Milton y su impacto en los estados del sureste como Florida y Georgia, StormHaven tiene como objetivo educar a la gente sobre la importancia de la seguridad, así como proporcionar información sobre los lugares de evacuación."
        default: return text
        }
    }
    
    private func translateToFrench(_ text: String) -> String {
        switch text {
        case "What is StormHaven?": return "Qu'est-ce que StormHaven?"
        case "Who made StormHaven?": return "Qui a créé StormHaven?"
        case "With the onset of Hurricane Milton and its impact on southeast states like Florida and Georgia, StormHaven aims to educate people on the importance of safety as well as provide an outlet of information on places of evacuation.": return "Avec le début de l'ouragan Milton et son impact sur les États du sud-est comme la Floride et la Géorgie, StormHaven vise à sensibiliser la population à l'importance de la sécurité et à fournir des informations sur les lieux d'évacuation."
        default: return text
        }
    }

    private func translateToGerman(_ text: String) -> String {
        switch text {
        case "What is StormHaven?": return "Was ist StormHaven?"
        case "Who made StormHaven?": return "Wer hat StormHaven gemacht?"
        case "With the onset of Hurricane Milton and its impact on southeast states like Florida and Georgia, StormHaven aims to educate people on the importance of safety as well as provide an outlet of information on places of evacuation.": return "Angesichts des Ausbruchs des Hurrikans Milton und seiner Auswirkungen auf südöstliche Bundesstaaten wie Florida und Georgia möchte StormHaven die Menschen über die Bedeutung der Sicherheit aufklären und eine Informationsquelle über Evakuierungsorte bereitstellen."
        default: return text
        }
    }

    private func translateToChinese(_ text: String) -> String {
        switch text {
        case "What is StormHaven?": return "什么是StormHaven?"
        case "Who made StormHaven?": return "谁制作了StormHaven?"
        case "With the onset of Hurricane Milton and its impact on southeast states like Florida and Georgia, StormHaven aims to educate people on the importance of safety as well as provide an outlet of information on places of evacuation.": return "随着飓风米尔顿的到来及其对佛罗里达州和佐治亚州等东南部州的影响，StormHaven 旨在教育人们安全的重要性，并提供有关疏散地点的信息。"
        default: return text
        }
    }
}
