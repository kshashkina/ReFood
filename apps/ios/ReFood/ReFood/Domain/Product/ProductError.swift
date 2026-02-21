import Foundation

public enum ProductError: Error, Equatable {
    case notFound
    case invalidData
    case network
    case unknown
}
