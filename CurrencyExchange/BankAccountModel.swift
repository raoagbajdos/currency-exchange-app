import Foundation

struct BankAccountDetails {
    let accountNumber: String
    let routingNumber: String
    let accountHolderName: String
    let bankName: String
    let accountType: String
    
    var isValid: Bool {
        return !accountNumber.isEmpty &&
               !routingNumber.isEmpty &&
               !accountHolderName.isEmpty &&
               !bankName.isEmpty &&
               accountNumber.count >= 8 &&
               routingNumber.count == 9
    }
}

class BankAccountValidator {
    static func validateAccountNumber(_ accountNumber: String) -> Bool {
        // Basic validation: 8-17 digits
        let regex = "^[0-9]{8,17}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: accountNumber)
    }
    
    static func validateRoutingNumber(_ routingNumber: String) -> Bool {
        // US routing number validation: 9 digits with checksum
        guard routingNumber.count == 9,
              let _ = Int(routingNumber) else {
            return false
        }
        
        // ABA routing number checksum validation
        let digits = routingNumber.compactMap { Int(String($0)) }
        let checksum = (3 * (digits[0] + digits[3] + digits[6]) +
                       7 * (digits[1] + digits[4] + digits[7]) +
                       (digits[2] + digits[5] + digits[8])) % 10
        
        return checksum == 0
    }
    
    static func validateAccountHolderName(_ name: String) -> Bool {
        let regex = "^[a-zA-Z\\s]{2,50}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: name)
    }
}