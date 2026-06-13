import Sentry

struct AppLogger: ErrorLogger {
    static func log(_ error: Error) {
        SentrySDK.capture(error: error)
    }
}
