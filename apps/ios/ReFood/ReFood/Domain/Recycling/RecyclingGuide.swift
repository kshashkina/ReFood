import SwiftUI

enum RecyclingCategory {
    case plastic, glass, metal, paper, cardboard, mixed, unknown
    
    var titleEn: String {
        switch self {
        case .plastic: return "Plastic"
        case .glass: return "Glass"
        case .metal: return "Metal / Aluminum"
        case .paper: return "Paper"
        case .cardboard: return "Cardboard"
        case .mixed: return "Mixed / Composite"
        case .unknown: return "Unknown Material"
        }
    }
    
    var titleUa: String {
        switch self {
        case .plastic: return "Пластик"
        case .glass: return "Скло"
        case .metal: return "Метал / Алюміній"
        case .paper: return "Папір"
        case .cardboard: return "Картон"
        case .mixed: return "Змішані матеріали / Композит"
        case .unknown: return "Невідомий матеріал"
        }
    }
    
    var prepStepsEn: [String] {
        switch self {
        case .plastic:
            return ["Empty all crumbs and food residue", "Crumple or flatten to save space", "Check for a recycling symbol (triangle with a number)"]
        case .glass:
            return ["Empty contents completely", "Remove the lid (sort it separately)", "Lightly rinse if greasy or sticky"]
        case .metal:
            return ["Empty completely", "Foil wrappers can be rolled into a ball", "Crush aluminum cans if possible"]
        case .paper:
            return ["Ensure the paper is clean and dry", "Remove any plastic windows or tape", "Fold compactly"]
        case .cardboard:
            return ["Remove plastic inserts from the box", "Flatten the box completely", "Ensure it's dry"]
        case .mixed:
            return ["Check local rules for composite packaging", "Separate components if they easily come apart"]
        case .unknown:
            return ["Look for a recycling symbol on the packaging", "Follow your local recycling guidelines"]
        }
    }
    
    var prepStepsUa: [String] {
        switch self {
        case .plastic:
            return ["Звільніть упаковку від крихт та залишків їжі", "Зіжмакайте або стисніть, щоб вона займала менше місця", "Перевірте наявність маркування (трикутник із цифрою)"]
        case .glass:
            return ["Повністю спорожніть", "Зніміть кришку (її сортують окремо)", "Сполосніть, якщо всередині липко або жирно"]
        case .metal:
            return ["Звільніть від залишків продукту", "Фольгу можна зібгати в щільну кульку", "Бляшанки краще стиснути"]
        case .paper:
            return ["Переконайтеся, що папір чистий і абсолютно сухий", "Видаліть залишки скотчу або пластикові віконця", "Складіть компактно"]
        case .cardboard:
            return ["Дістаньте з коробки пластикові вставки (якщо є)", "Повністю розкладіть коробку, щоб вона стала пласкою", "Слідкуйте, щоб картон не намок"]
        case .mixed:
            return ["Перевірте місцеві правила щодо змішаних упаковок", "Якщо частини легко відділяються (напр. картон і плівка) — розділіть їх"]
        case .unknown:
            return ["Шукайте маркування переробки на упаковці", "Дотримуйтесь місцевих правил сортування"]
        }
    }
    
    static func from(material: String?) -> RecyclingCategory {
        guard let mat = material?.lowercased() else { return .unknown }
        
        if mat.contains("plastic") || mat.contains("pet") || mat.contains("pp") || mat.contains("pe") || mat.contains("pvc") || mat.contains("пластик") {
            return .plastic
        } else if mat.contains("glass") || mat.contains("скло") {
            return .glass
        } else if mat.contains("metal") || mat.contains("aluminium") || mat.contains("alu") || mat.contains("steel") || mat.contains("tin") || mat.contains("метал") || mat.contains("алюм") || mat.contains("фольг") {
            return .metal
        } else if mat.contains("cardboard") || mat.contains("carton") || mat.contains("картон") {
            return .cardboard
        } else if mat.contains("paper") || mat.contains("папір") || mat.contains("бумага") {
            return .paper
        } else if mat.contains("composite") || mat.contains("mixed") || mat.contains("tetra") || mat.contains("композит") || mat.contains("змішан") {
            return .mixed
        }
        
        return .unknown
    }
}
