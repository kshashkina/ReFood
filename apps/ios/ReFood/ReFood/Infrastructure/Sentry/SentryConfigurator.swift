import Sentry

struct SentryConfigurator {
    static func configure() {
        SentrySDK.start { options in
            options.dsn = "https://e87a2a8e2ddfb8015186601a875b76ca@o4511547376467968.ingest.de.sentry.io/4511547382890576"
            options.tracesSampleRate = 1.0
        }
    }
}
