struct NetworkRunner {

    static func execute<T>(_ block: () async throws -> T) async throws -> T {
        do {
            return try await block()
        } catch {
            AppLogger.log(error)
            throw error
        }
    }
}
