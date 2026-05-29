import Amplify
import AWSCognitoAuthPlugin
import AWSAPIPlugin

struct AmplifyConfigurator {
    static func configure() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSAPIPlugin())
            try Amplify.configure()
        } catch {
        }
    }
}
