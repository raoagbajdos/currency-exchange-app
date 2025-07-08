import Foundation

class PurchaseService: ObservableObject {
    static let shared = PurchaseService()
    
    @Published var transactions: [PurchaseTransaction] = []
    @Published var isProcessing = false
    
    private let exchangeRateService = ExchangeRateService.shared
    
    init() {}
    
    // MARK: - Purchase Currency
    func purchaseCurrency(
        amount: Double,
        fromCurrency: String,
        toCurrency: String,
        bankAccount: BankAccount
    ) async -> Result<PurchaseTransaction, PurchaseError> {
        
        DispatchQueue.main.async {
            self.isProcessing = true
        }
        
        do {
            // Validate inputs
            try validatePurchaseInputs(amount: amount, fromCurrency: fromCurrency, toCurrency: toCurrency, bankAccount: bankAccount)
            
            // Get current exchange rate
            guard let exchangeRate = exchangeRateService.getRate(from: fromCurrency, to: toCurrency) else {
                throw PurchaseError.exchangeRateNotAvailable
            }
            
            // Calculate costs
            let fee = calculateTransactionFee(amount: amount)
            let totalCost = amount + fee
            
            // Create transaction
            let transaction = PurchaseTransaction(
                id: UUID().uuidString,
                fromCurrency: fromCurrency,
                toCurrency: toCurrency,
                amount: amount,
                exchangeRate: exchangeRate,
                totalCost: totalCost,
                bankAccount: bankAccount,
                timestamp: Date(),
                status: .pending
            )
            
            // Process payment
            let processedTransaction = try await processPayment(transaction: transaction)
            
            // Add to transactions list
            DispatchQueue.main.async {
                self.transactions.append(processedTransaction)
                self.isProcessing = false
            }
            
            // Simulate bank transfer initiation
            await initiateBankTransfer(transaction: processedTransaction)
            
            return .success(processedTransaction)
            
        } catch {
            DispatchQueue.main.async {
                self.isProcessing = false
            }
            
            if let purchaseError = error as? PurchaseError {
                return .failure(purchaseError)
            } else {
                return .failure(.unknown(error.localizedDescription))
            }
        }
    }
    
    // MARK: - Input Validation
    private func validatePurchaseInputs(amount: Double, fromCurrency: String, toCurrency: String, bankAccount: BankAccount) throws {
        // Validate amount
        guard amount > 0 else {
            throw PurchaseError.invalidAmount
        }
        
        guard amount <= 10000 else { // Daily limit
            throw PurchaseError.amountExceedsLimit
        }
        
        // Validate currencies
        guard !fromCurrency.isEmpty && !toCurrency.isEmpty else {
            throw PurchaseError.invalidCurrency
        }
        
        guard fromCurrency != toCurrency else {
            throw PurchaseError.sameCurrency
        }
        
        // Validate bank account
        guard !bankAccount.accountNumber.isEmpty &&
              !bankAccount.routingNumber.isEmpty &&
              !bankAccount.accountHolderName.isEmpty else {
            throw PurchaseError.invalidBankAccount
        }
        
        // Additional bank account validation
        guard BankAccountValidator.validateAccountNumber(bankAccount.accountNumber) else {
            throw PurchaseError.invalidAccountNumber
        }
        
        guard BankAccountValidator.validateRoutingNumber(bankAccount.routingNumber) else {
            throw PurchaseError.invalidRoutingNumber
        }
        
        guard BankAccountValidator.validateAccountHolderName(bankAccount.accountHolderName) else {
            throw PurchaseError.invalidAccountHolderName
        }
    }
    
    // MARK: - Fee Calculation
    private func calculateTransactionFee(amount: Double) -> Double {
        let baseFee = 2.99 // Base fee
        let percentageFee = amount * 0.015 // 1.5% of transaction
        return baseFee + percentageFee
    }
    
    // MARK: - Payment Processing
    private func processPayment(transaction: PurchaseTransaction) async throws -> PurchaseTransaction {
        // Simulate payment processing delay
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Simulate payment validation
        let success = Bool.random() ? true : true // For demo, always succeed
        
        if success {
            var updatedTransaction = transaction
            updatedTransaction = PurchaseTransaction(
                id: transaction.id,
                fromCurrency: transaction.fromCurrency,
                toCurrency: transaction.toCurrency,
                amount: transaction.amount,
                exchangeRate: transaction.exchangeRate,
                totalCost: transaction.totalCost,
                bankAccount: transaction.bankAccount,
                timestamp: transaction.timestamp,
                status: .processing
            )
            return updatedTransaction
        } else {
            throw PurchaseError.paymentFailed
        }
    }
    
    // MARK: - Bank Transfer
    private func initiateBankTransfer(transaction: PurchaseTransaction) async {
        // Simulate bank transfer processing
        try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
        
        // Update transaction status
        DispatchQueue.main.async {
            if let index = self.transactions.firstIndex(where: { $0.id == transaction.id }) {
                self.transactions[index] = PurchaseTransaction(
                    id: transaction.id,
                    fromCurrency: transaction.fromCurrency,
                    toCurrency: transaction.toCurrency,
                    amount: transaction.amount,
                    exchangeRate: transaction.exchangeRate,
                    totalCost: transaction.totalCost,
                    bankAccount: transaction.bankAccount,
                    timestamp: transaction.timestamp,
                    status: .completed
                )
            }
        }
        
        // Send notification (in real app, this would be push notification)
        await sendTransferNotification(transaction: transaction)
    }
    
    // MARK: - Notifications
    private func sendTransferNotification(transaction: PurchaseTransaction) async {
        // In a real app, this would send a push notification
        print("Currency transfer completed: \(transaction.amount) \(transaction.toCurrency) delivered to account ending in \(String(transaction.bankAccount.accountNumber.suffix(4)))")
    }
    
    // MARK: - Transaction History
    func getTransactionHistory() -> [PurchaseTransaction] {
        return transactions.sorted { $0.timestamp > $1.timestamp }
    }
    
    func getTransactionById(_ id: String) -> PurchaseTransaction? {
        return transactions.first { $0.id == id }
    }
    
    // MARK: - Supported Currencies
    func getSupportedCurrencies() -> [String] {
        return ["USD", "EUR", "GBP", "JPY", "CAD", "AUD", "CHF", "CNY", "INR", "BRL", "MXN"]
    }
}

// MARK: - Purchase Errors
enum PurchaseError: Error, LocalizedError {
    case invalidAmount
    case amountExceedsLimit
    case invalidCurrency
    case sameCurrency
    case invalidBankAccount
    case invalidAccountNumber
    case invalidRoutingNumber
    case invalidAccountHolderName
    case exchangeRateNotAvailable
    case paymentFailed
    case networkError
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return "Invalid amount. Please enter a positive value."
        case .amountExceedsLimit:
            return "Amount exceeds daily limit of $10,000."
        case .invalidCurrency:
            return "Invalid currency selection."
        case .sameCurrency:
            return "Cannot exchange between the same currency."
        case .invalidBankAccount:
            return "Invalid bank account information."
        case .invalidAccountNumber:
            return "Invalid account number format."
        case .invalidRoutingNumber:
            return "Invalid routing number."
        case .invalidAccountHolderName:
            return "Invalid account holder name."
        case .exchangeRateNotAvailable:
            return "Exchange rate not available. Please try again."
        case .paymentFailed:
            return "Payment processing failed. Please try again."
        case .networkError:
            return "Network error. Please check your connection."
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
}