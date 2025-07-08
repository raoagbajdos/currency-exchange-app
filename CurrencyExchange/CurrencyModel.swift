import Foundation

// MARK: - Currency Models
struct Currency: Codable {
    let code: String
    let name: String
    let symbol: String
    let rate: Double
    let lastUpdated: Date
}

struct ExchangeRate: Codable {
    let baseCurrency: String
    let rates: [String: Double]
    let lastUpdated: Date
}

// MARK: - Bank Account Model
struct BankAccount {
    let accountNumber: String
    let routingNumber: String
    let accountHolderName: String
    let bankName: String
    let accountType: AccountType
}

enum AccountType: String, CaseIterable {
    case checking = "Checking"
    case savings = "Savings"
}

// MARK: - Purchase Transaction Model
struct PurchaseTransaction {
    let id: String
    let fromCurrency: String
    let toCurrency: String
    let amount: Double
    let exchangeRate: Double
    let totalCost: Double
    let bankAccount: BankAccount
    let timestamp: Date
    let status: TransactionStatus
}

enum TransactionStatus: String {
    case pending = "Pending"
    case processing = "Processing"
    case completed = "Completed"
    case failed = "Failed"
}

// MARK: - API Response Models
struct ExchangeRateAPIResponse: Codable {
    let success: Bool
    let timestamp: Int
    let base: String
    let date: String
    let rates: [String: Double]
}

struct CurrencyListResponse: Codable {
    let success: Bool
    let currencies: [String: String]
}