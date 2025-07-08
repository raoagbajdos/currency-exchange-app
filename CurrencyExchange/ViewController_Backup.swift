import UIKit

class ViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    // Exchange Rate Section
    @IBOutlet weak var exchangeRateLabel: UILabel!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    
    // Currency Selection
    @IBOutlet weak var fromCurrencyButton: UIButton!
    @IBOutlet weak var toCurrencyButton: UIButton!
    @IBOutlet weak var swapCurrenciesButton: UIButton!
    
    // Amount Input
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var convertedAmountLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var totalCostLabel: UILabel!
    
    // Bank Account Section
    @IBOutlet weak var accountNumberTextField: UITextField!
    @IBOutlet weak var routingNumberTextField: UITextField!
    @IBOutlet weak var accountHolderNameTextField: UITextField!
    @IBOutlet weak var bankNameTextField: UITextField!
    @IBOutlet weak var accountTypeSegmentedControl: UISegmentedControl!
    
    // Action Buttons
    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var historyButton: UIButton!
    
    // Loading Indicator
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    private let exchangeRateService = ExchangeRateService.shared
    private let purchaseService = PurchaseService.shared
    
    private var selectedFromCurrency = "USD"
    private var selectedToCurrency = "EUR"
    private let supportedCurrencies = ["USD", "EUR", "GBP", "JPY", "CAD", "AUD", "CHF", "CNY", "INR", "BRL", "MXN"]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupObservers()
        loadInitialData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Currency Exchange"
        view.backgroundColor = UIColor.systemBackground
        
        // Setup text fields
        setupTextFields()
        
        // Setup buttons
        setupButtons()
        
        // Setup currency buttons
        updateCurrencyButtons()
        
        // Setup segmented control
        accountTypeSegmentedControl.selectedSegmentIndex = 0
        
        // Setup activity indicator
        activityIndicator.hidesWhenStopped = true
        
        // Add target for amount text field
        amountTextField.addTarget(self, action: #selector(amountChanged), for: .editingChanged)
    }
    
    private func setupTextFields() {
        amountTextField.keyboardType = .decimalPad
        amountTextField.placeholder = "Enter amount"
        amountTextField.borderStyle = .roundedRect
        
        accountNumberTextField.keyboardType = .numberPad
        accountNumberTextField.placeholder = "Account Number"
        accountNumberTextField.borderStyle = .roundedRect
        
        routingNumberTextField.keyboardType = .numberPad
        routingNumberTextField.placeholder = "Routing Number"
        routingNumberTextField.borderStyle = .roundedRect
        
        accountHolderNameTextField.placeholder = "Account Holder Name"
        accountHolderNameTextField.borderStyle = .roundedRect
        
        bankNameTextField.placeholder = "Bank Name"
        bankNameTextField.borderStyle = .roundedRect
    }
    
    private func setupButtons() {
        purchaseButton.backgroundColor = UIColor.systemBlue
        purchaseButton.setTitleColor(.white, for: .normal)
        purchaseButton.layer.cornerRadius = 8
        purchaseButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
        historyButton.backgroundColor = UIColor.systemGray
        historyButton.setTitleColor(.white, for: .normal)
        historyButton.layer.cornerRadius = 8
        
        refreshButton.setTitle("↻", for: .normal)
        refreshButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
    }
    
    private func updateCurrencyButtons() {
        fromCurrencyButton.setTitle(selectedFromCurrency, for: .normal)
        toCurrencyButton.setTitle(selectedToCurrency, for: .normal)
        
        fromCurrencyButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        toCurrencyButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        
        fromCurrencyButton.layer.cornerRadius = 8
        toCurrencyButton.layer.cornerRadius = 8
        
        fromCurrencyButton.layer.borderWidth = 1
        toCurrencyButton.layer.borderWidth = 1
        
        fromCurrencyButton.layer.borderColor = UIColor.systemBlue.cgColor
        toCurrencyButton.layer.borderColor = UIColor.systemBlue.cgColor
    }
    
    // MARK: - Observers
    private func setupObservers() {
        // Observe exchange rate service
        exchangeRateService.$exchangeRates
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateExchangeRateDisplay()
                self?.updateConvertedAmount()
            }
            .store(in: &cancellables)
        
        exchangeRateService.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
        
        // Observe purchase service
        purchaseService.$isProcessing
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isProcessing in
                self?.purchaseButton.isEnabled = !isProcessing
                if isProcessing {
                    self?.purchaseButton.setTitle("Processing...", for: .normal)
                } else {
                    self?.purchaseButton.setTitle("Purchase Currency", for: .normal)
                }
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Data Loading
    private func loadInitialData() {
        Task {
            await exchangeRateService.fetchExchangeRates()
        }
    }
    
    // MARK: - IBActions
    @IBAction func refreshButtonTapped(_ sender: UIButton) {
        Task {
            await exchangeRateService.fetchExchangeRates()
        }
    }
    
    @IBAction func fromCurrencyButtonTapped(_ sender: UIButton) {
        showCurrencyPicker(isFromCurrency: true)
    }
    
    @IBAction func toCurrencyButtonTapped(_ sender: UIButton) {
        showCurrencyPicker(isFromCurrency: false)
    }
    
    @IBAction func swapCurrenciesButtonTapped(_ sender: UIButton) {
        let temp = selectedFromCurrency
        selectedFromCurrency = selectedToCurrency
        selectedToCurrency = temp
        updateCurrencyButtons()
        updateConvertedAmount()
    }
    
    @IBAction func purchaseButtonTapped(_ sender: UIButton) {
        processPurchase()
    }
    
    @IBAction func historyButtonTapped(_ sender: UIButton) {
        showTransactionHistory()
    }
    
    @objc private func amountChanged() {
        updateConvertedAmount()
    }
    
    // MARK: - Currency Selection
    private func showCurrencyPicker(isFromCurrency: Bool) {
        let alertController = UIAlertController(title: "Select Currency", message: nil, preferredStyle: .actionSheet)
        
        for currency in supportedCurrencies {
            let action = UIAlertAction(title: currency, style: .default) { [weak self] _ in
                if isFromCurrency {
                    self?.selectedFromCurrency = currency
                } else {
                    self?.selectedToCurrency = currency
                }
                self?.updateCurrencyButtons()
                self?.updateConvertedAmount()
            }
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad
        if let popover = alertController.popoverPresentationController {
            popover.sourceView = isFromCurrency ? fromCurrencyButton : toCurrencyButton
            popover.sourceRect = (isFromCurrency ? fromCurrencyButton : toCurrencyButton).bounds
        }
        
        present(alertController, animated: true)
    }
    
    // MARK: - Update UI
    private func updateExchangeRateDisplay() {
        if let rate = exchangeRateService.getRate(from: selectedFromCurrency, to: selectedToCurrency) {
            exchangeRateLabel.text = String(format: "1 %@ = %.4f %@", selectedFromCurrency, rate, selectedToCurrency)
            lastUpdatedLabel.text = "Last updated: \(DateFormatter.timeFormatter.string(from: Date()))"
        } else {
            exchangeRateLabel.text = "Exchange rate unavailable"
            lastUpdatedLabel.text = ""
        }
    }
    
    private func updateConvertedAmount() {
        guard let amountText = amountTextField.text,
              let amount = Double(amountText),
              amount > 0,
              let convertedAmount = exchangeRateService.convertAmount(amount, from: selectedFromCurrency, to: selectedToCurrency) else {
            convertedAmountLabel.text = ""
            feeLabel.text = ""
            totalCostLabel.text = ""
            return
        }
        
        let fee = calculateFee(for: amount)
        let totalCost = amount + fee
        
        convertedAmountLabel.text = String(format: "%.2f %@", convertedAmount, selectedToCurrency)
        feeLabel.text = String(format: "Fee: $%.2f", fee)
        totalCostLabel.text = String(format: "Total: $%.2f", totalCost)
    }
    
    private func calculateFee(for amount: Double) -> Double {
        let baseFee = 2.99
        let percentageFee = amount * 0.015
        return baseFee + percentageFee
    }
    
    // MARK: - Purchase Processing
    private func processPurchase() {
        guard validateInputs() else { return }
        
        guard let amount = Double(amountTextField.text ?? "") else {
            showAlert(title: "Invalid Amount", message: "Please enter a valid amount.")
            return
        }
        
        let bankAccount = BankAccount(
            accountNumber: accountNumberTextField.text ?? "",
            routingNumber: routingNumberTextField.text ?? "",
            accountHolderName: accountHolderNameTextField.text ?? "",
            bankName: bankNameTextField.text ?? "",
            accountType: accountTypeSegmentedControl.selectedSegmentIndex == 0 ? .checking : .savings
        )
        
        Task {
            let result = await purchaseService.purchaseCurrency(
                amount: amount,
                fromCurrency: selectedFromCurrency,
                toCurrency: selectedToCurrency,
                bankAccount: bankAccount
            )
            
            DispatchQueue.main.async {
                switch result {
                case .success(let transaction):
                    self.showSuccessAlert(transaction: transaction)
                    self.clearForm()
                case .failure(let error):
                    self.showAlert(title: "Purchase Failed", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func validateInputs() -> Bool {
        guard let amountText = amountTextField.text, !amountText.isEmpty,
              let amount = Double(amountText), amount > 0 else {
            showAlert(title: "Invalid Amount", message: "Please enter a valid amount.")
            return false
        }
        
        guard !accountNumberTextField.text!.isEmpty,
              !routingNumberTextField.text!.isEmpty,
              !accountHolderNameTextField.text!.isEmpty,
              !bankNameTextField.text!.isEmpty else {
            showAlert(title: "Incomplete Information", message: "Please fill in all bank account details.")
            return false
        }
        
        return true
    }
    
    private func clearForm() {
        amountTextField.text = ""
        accountNumberTextField.text = ""
        routingNumberTextField.text = ""
        accountHolderNameTextField.text = ""
        bankNameTextField.text = ""
        accountTypeSegmentedControl.selectedSegmentIndex = 0
        updateConvertedAmount()
    }
    
    // MARK: - Alerts
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showSuccessAlert(transaction: PurchaseTransaction) {
        let message = """
        Transaction ID: \(transaction.id)
        Amount: \(transaction.amount) \(transaction.toCurrency)
        Will be delivered to: \(transaction.bankAccount.bankName)
        Account: ***\(String(transaction.bankAccount.accountNumber.suffix(4)))
        """
        
        let alert = UIAlertController(title: "Purchase Successful!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Transaction History
    private func showTransactionHistory() {
        let alert = UIAlertController(title: "Transaction History", message: "Transaction history feature coming soon!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Extensions
extension DateFormatter {
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}

import Combine