public protocol ProductRepository {
    func getProduct(byBarcode barcode: String) async throws -> Product
    func addProduct(_ product: ProductAdd) async throws
}
