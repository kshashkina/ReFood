import Foundation
import Security
import UIKit

struct KeychainDeviceIDManager: DeviceIDProviderProtocol {
    private let key = "com.refood.device.unique.id"
    
    func getDeviceID() -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let data = dataTypeRef as? Data, let existingID = String(data: data, encoding: .utf8) {
            return existingID
        }
        
        let newID = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        guard let data = newID.data(using: .utf8) else { return newID }
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemAdd(addQuery as CFDictionary, nil)
        
        return newID
    }
    
    func resetDeviceID() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
