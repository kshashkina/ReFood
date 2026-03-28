import Foundation


final class AIComparisonRepositoryImpl: AIComparisonRepository {

    func getComparison(barcodeA: String, barcodeB: String) async throws -> AIComparisonAnalysis {
        do {
            let data = try await AIComparisonAPI.fetchComparisonData(barcodeA: barcodeA, barcodeB: barcodeB)
                        let decoder = JSONDecoder()
            let response = try decoder.decode(AIComparisonResponse.self, from: data)
                        guard let analysis = response.analysis else {
                throw ProductError.invalidData
            }
            return analysis
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
