import Foundation

final class ProductRepositoryImpl: ProductRepository {

    func getProduct(byBarcode barcode: String) async throws -> Product {
        do {
            let data = try await ProductAPI.fetchProductData(barcode: barcode)
            let decoder = JSONDecoder()
            let response = try decoder.decode(ProductResponse.self, from: data)
            var finalProduct = response.product
            finalProduct.barcode = barcode
            return finalProduct

        } catch let error as NetworkError {
            if case let .httpStatus(code, _) = error, code == 404 {
                throw ProductError.notFound
            }
            throw ProductError.network

        } catch is DecodingError {
            throw ProductError.invalidData

        } catch {
            throw ProductError.unknown
        }
    }
}
