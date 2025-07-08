import Foundation
import Network

class ExchangeRateService: ObservableObject {
    static let shared = ExchangeRateService()
    
    @Published var exchangeRates: [String: Double] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let baseURL = "http://api.exchangerate-api.com/v4/latest/"
    private let fallbackURL = "https://api.fixer.io/latest"
    
    // Cache for exchange rates
    private var rateCache: [String: (rates: [String: Double], timestamp: Date)] = [:]
    private let cacheExpirationTime: TimeInterval = 3600 // 1 hour
    
    init() {
        startPeriodicUpdates()
    }
    
    // MARK: - Main Exchange Rate Fetching
    func fetchExchangeRates(baseCurrency: String = "USD") async {
        // Check cache first
        if let cachedData = rateCache[baseCurrency],
           Date().timeIntervalSince(cachedData.timestamp) < cacheExpirationTime {
            DispatchQueue.main.async {
                self.exchangeRates = cachedData.rates
            }
            return
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            let rates = try await fetchFromPrimaryAPI(baseCurrency: baseCurrency)
            
            DispatchQueue.main.async {
                self.exchangeRates = rates
                self.isLoading = false
            }
            
            // Cache the results
            rateCache[baseCurrency] = (rates: rates, timestamp: Date())
            
        } catch {
            // Try fallback methods
            await tryFallbackMethods(baseCurrency: baseCurrency)
        }
    }
    
    // MARK: - Primary API Method
    private func fetchFromPrimaryAPI(baseCurrency: String) async throws -> [String: Double] {
        guard let url = URL(string: "\(baseURL)\(baseCurrency)") else {
            throw ExchangeRateError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ExchangeRateError.invalidResponse
        }
        
        let apiResponse = try JSONDecoder().decode(ExchangeRateAPIResponse.self, from: data)
        
        if apiResponse.success {
            return apiResponse.rates
        } else {
            throw ExchangeRateError.apiError("API returned unsuccessful response")
        }
    }
    
    // MARK: - Fallback Methods
    private func tryFallbackMethods(baseCurrency: String) async {
        // Try web scraping as fallback
        do {
            let rates = try await scrapeExchangeRates(baseCurrency: baseCurrency)
            DispatchQueue.main.async {
                self.exchangeRates = rates
                self.isLoading = false
            }
            return
        } catch {
            print("Web scraping failed: \(error)")
        }
        
        // Use hardcoded fallback rates as last resort
        let fallbackRates = getFallbackRates(baseCurrency: baseCurrency)
        DispatchQueue.main.async {
            self.exchangeRates = fallbackRates
            self.isLoading = false
            self.errorMessage = "Using cached exchange rates. Please check your internet connection."
        }
    }
    
    // MARK: - Web Scraping Method
    private func scrapeExchangeRates(baseCurrency: String) async throws -> [String: Double] {
        // Scrape from xe.com or similar public source
        let urlString = "https://www.xe.com/currencyconverter/convert/?Amount=1&From=\(baseCurrency)&To=EUR"
        
        guard let url = URL(string: urlString) else {
            throw ExchangeRateError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let html = String(data: data, encoding: .utf8) ?? ""
        
        // Parse HTML to extract exchange rates
        var rates: [String: Double] = [:]
        
        // Basic pattern matching for common currencies
        let patterns = [
            "EUR": "EUR.*?(\\d+\\.\\d+)",
            "GBP": "GBP.*?(\\d+\\.\\d+)",
            "JPY": "JPY.*?(\\d+\\.\\d+)",
            "CAD": "CAD.*?(\\d+\\.\\d+)",
            "AUD": "AUD.*?(\\d+\\.\\d+)"
        ]
        
        for (currency, pattern) in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
               let range = Range(match.range(at: 1), in: html) {
                let rateString = String(html[range])
                rates[currency] = Double(rateString)
            }
        }
        
        // Add some default rates if scraping fails
        if rates.isEmpty {
            rates = getFallbackRates(baseCurrency: baseCurrency)
        }
        
        return rates
    }
    
    // MARK: - Fallback Rates
    private func getFallbackRates(baseCurrency: String) -> [String: Double] {
        // Hardcoded approximate rates for major currencies (relative to USD)
        let usdRates: [String: Double] = [
            "EUR": 0.92,
            "GBP": 0.79,
            "JPY": 149.50,
            "CAD": 1.36,
            "AUD": 1.52,
            "CHF": 0.88,
            "CNY": 7.24,
            "INR": 83.15,
            "BRL": 5.12,
            "MXN": 17.45
        ]
        
        if baseCurrency == "USD" {
            return usdRates
        } else {
            // Convert rates relative to base currency
            var convertedRates: [String: Double] = [:]
            let baseRate = usdRates[baseCurrency] ?? 1.0
            
            for (currency, rate) in usdRates {
                if currency != baseCurrency {
                    convertedRates[currency] = rate / baseRate
                }
            }
            convertedRates["USD"] = 1.0 / baseRate
            
            return convertedRates
        }
    }
    
    // MARK: - Utility Methods
    func getRate(from fromCurrency: String, to toCurrency: String) -> Double? {
        if fromCurrency == toCurrency {
            return 1.0
        }
        
        if fromCurrency == "USD" {
            return exchangeRates[toCurrency]
        } else if toCurrency == "USD" {
            return 1.0 / (exchangeRates[fromCurrency] ?? 1.0)
        } else {
            // Convert through USD
            guard let fromRate = exchangeRates[fromCurrency],
                  let toRate = exchangeRates[toCurrency] else {
                return nil
            }
            return toRate / fromRate
        }
    }
    
    func convertAmount(_ amount: Double, from fromCurrency: String, to toCurrency: String) -> Double? {
        guard let rate = getRate(from: fromCurrency, to: toCurrency) else {
            return nil
        }
        return amount * rate
    }
    
    // MARK: - Periodic Updates
    private func startPeriodicUpdates() {
        Timer.scheduledTimer(withTimeInterval: 1800, repeats: true) { _ in // Update every 30 minutes
            Task {
                await self.fetchExchangeRates()
            }
        }
    }
}

// MARK: - Error Types
enum ExchangeRateError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case noData
    case apiError(String)
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .noData:
            return "No data received"
        case .apiError(let message):
            return "API Error: \(message)"
        case .networkError:
            return "Network connection error"
        }
    }
}