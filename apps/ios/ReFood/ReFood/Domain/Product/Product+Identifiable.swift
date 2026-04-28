import Foundation

extension Product: Identifiable {
    public var id: String { barcode ?? UUID().uuidString }
}
