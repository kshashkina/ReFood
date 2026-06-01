import Foundation

enum ProductChangeEvent: AnalyticsEventProtocol {
    case screenView(flow: String)
    case backTap(flow: String)
    case photoTap(flow: String)
    case nameTap(flow: String)
    case brandTap(flow: String)
    case quantityTap(flow: String)
    case categoryTap(flow: String)
    case nutriTap(flow: String)
    case ecoTap(flow: String)
    case ingredientsTap(flow: String)
    case allergensTap(flow: String)
    case packagingAddTap(flow: String)
    case packagingShapeTap(flow: String)
    case packagingMaterialTap(flow: String)
    case packagingCodeTap(flow: String)
    case kcalTap(flow: String)
    case proteinsTap(flow: String)
    case fatsTap(flow: String)
    case carbsTap(flow: String)
    case satFatTap(flow: String)
    case sugarsTap(flow: String)
    case addedSugarsTap(flow: String)
    case saltTap(flow: String)
    case caffeineTap(flow: String)
    case continueTap(flow: String)
    
    var name: String {
        switch self {
        case .screenView: return "product_change_screen_view"
        case .backTap: return "product_change_back_tap"
        case .photoTap: return "product_change_photo_tap"
        case .nameTap: return "product_change_name_tap"
        case .brandTap: return "product_change_brand_tap"
        case .quantityTap: return "product_change_quantity_tap"
        case .categoryTap: return "product_change_category_tap"
        case .nutriTap: return "product_change_nutri_tap"
        case .ecoTap: return "product_change_eco_tap"
        case .ingredientsTap: return "product_change_ingredients_tap"
        case .allergensTap: return "product_change_allergens_tap"
        case .packagingAddTap: return "product_change_packaging_add_tap"
        case .packagingShapeTap: return "product_change_packaging_shape_tap"
        case .packagingMaterialTap: return "product_change_packaging_material_tap"
        case .packagingCodeTap: return "product_change_packaging_code_tap"
        case .kcalTap: return "product_change_kcal_tap"
        case .proteinsTap: return "product_change_proteins_tap"
        case .fatsTap: return "product_change_fats_tap"
        case .carbsTap: return "product_change_carbs_tap"
        case .satFatTap: return "product_change_sat_fat_tap"
        case .sugarsTap: return "product_change_sugars_tap"
        case .addedSugarsTap: return "product_change_add_sugars_tap"
        case .saltTap: return "product_change_salt_tap"
        case .caffeineTap: return "product_change_caffeine_tap"
        case .continueTap: return "product_change_continue_tap"
        }
    }
    
    var properties: [String: Any]? {
        switch self {
        case .screenView(let f), .backTap(let f), .photoTap(let f), .nameTap(let f), .brandTap(let f),
             .quantityTap(let f), .categoryTap(let f), .nutriTap(let f), .ecoTap(let f), .ingredientsTap(let f),
             .allergensTap(let f), .packagingAddTap(let f), .packagingShapeTap(let f), .packagingMaterialTap(let f),
             .packagingCodeTap(let f), .kcalTap(let f), .proteinsTap(let f), .fatsTap(let f), .carbsTap(let f),
             .satFatTap(let f), .sugarsTap(let f), .addedSugarsTap(let f), .saltTap(let f), .caffeineTap(let f),
             .continueTap(let f):
            return ["flow": f]
        }
    }
}
