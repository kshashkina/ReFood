import Foundation

protocol LanguageProvider {
    var currentLanguageCode: String { get }
}

struct SystemLanguageProvider: LanguageProvider {
    var currentLanguageCode: String {
        Locale.current.language.languageCode?.identifier == "uk" ? "ua" : "en"
    }
}
