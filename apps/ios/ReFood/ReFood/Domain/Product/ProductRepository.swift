public protocol ProductRepository {
    func getProduct(byBarcode barcode: String) async throws -> Product
}
