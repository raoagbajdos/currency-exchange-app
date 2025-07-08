import UIKit

class ViewController: UIViewController {
    
    // Services
    private let exchangeRateService = ExchangeRateService()
    private let purchaseService = PurchaseService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Currency Exchange"
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupUI()
    }
    
    private func setupNavigationBar() {
        // Add navigation button to view all exchange rates
        let ratesButton = UIBarButtonItem(
            title: "📊 Daily Rates", 
            style: .plain, 
            target: self, 
            action: #selector(showAllRates)
        )
        navigationItem.rightBarButtonItem = ratesButton
    }
    
    private func setupUI() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = "Currency Exchange"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 28)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Subtitle
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Buy foreign currency with bank account delivery"
        subtitleLabel.font = UIFont.systemFont(ofSize: 16)
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Main action buttons
        let buyButton = UIButton(type: .system)
        buyButton.setTitle("💰 Buy Currency", for: .normal)
        buyButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        buyButton.backgroundColor = .systemGreen
        buyButton.setTitleColor(.white, for: .normal)
        buyButton.layer.cornerRadius = 12
        buyButton.addTarget(self, action: #selector(buyButtonTapped), for: .touchUpInside)
        buyButton.translatesAutoresizingMaskIntoConstraints = false
        
        let sellButton = UIButton(type: .system)
        sellButton.setTitle("💸 Sell Currency", for: .normal)
        sellButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        sellButton.backgroundColor = .systemOrange
        sellButton.setTitleColor(.white, for: .normal)
        sellButton.layer.cornerRadius = 12
        sellButton.addTarget(self, action: #selector(sellButtonTapped), for: .touchUpInside)
        sellButton.translatesAutoresizingMaskIntoConstraints = false
        
        let dailyRatesButton = UIButton(type: .system)
        dailyRatesButton.setTitle("📊 Daily Exchange Rates", for: .normal)
        dailyRatesButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        dailyRatesButton.backgroundColor = .systemBlue
        dailyRatesButton.setTitleColor(.white, for: .normal)
        dailyRatesButton.layer.cornerRadius = 12
        dailyRatesButton.addTarget(self, action: #selector(showAllRates), for: .touchUpInside)
        dailyRatesButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Purchase section
        let purchaseTitleLabel = UILabel()
        purchaseTitleLabel.text = "Quick Currency Purchase"
        purchaseTitleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        purchaseTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Currency selection
        let fromLabel = UILabel()
        fromLabel.text = "From Currency:"
        fromLabel.font = UIFont.systemFont(ofSize: 16)
        fromLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let fromCurrencyButton = UIButton(type: .system)
        fromCurrencyButton.setTitle("USD - US Dollar", for: .normal)
        fromCurrencyButton.backgroundColor = .systemGray6
        fromCurrencyButton.layer.cornerRadius = 8
        fromCurrencyButton.contentHorizontalAlignment = .left
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.title = "USD - US Dollar"
            config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
            fromCurrencyButton.configuration = config
        } else {
            fromCurrencyButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        }
        fromCurrencyButton.translatesAutoresizingMaskIntoConstraints = false
        
        let toLabel = UILabel()
        toLabel.text = "To Currency:"
        toLabel.font = UIFont.systemFont(ofSize: 16)
        toLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let toCurrencyButton = UIButton(type: .system)
        toCurrencyButton.setTitle("EUR - Euro", for: .normal)
        toCurrencyButton.backgroundColor = .systemGray6
        toCurrencyButton.layer.cornerRadius = 8
        toCurrencyButton.contentHorizontalAlignment = .left
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.title = "EUR - Euro"
            config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
            toCurrencyButton.configuration = config
        } else {
            toCurrencyButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        }
        toCurrencyButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Amount input
        let amountLabel = UILabel()
        amountLabel.text = "Amount:"
        amountLabel.font = UIFont.systemFont(ofSize: 16)
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let amountTextField = UITextField()
        amountTextField.placeholder = "Enter amount"
        amountTextField.borderStyle = .roundedRect
        amountTextField.keyboardType = .decimalPad
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        
        // Purchase button
        let purchaseButton = UIButton(type: .system)
        purchaseButton.setTitle("Purchase Currency", for: .normal)
        purchaseButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        purchaseButton.backgroundColor = .systemGreen
        purchaseButton.setTitleColor(.white, for: .normal)
        purchaseButton.layer.cornerRadius = 12
        purchaseButton.addTarget(self, action: #selector(purchaseButtonTapped), for: .touchUpInside)
        purchaseButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Deposit button
        let depositButton = UIButton(type: .system)
        depositButton.setTitle("🏦 Deposit into Bank Account", for: .normal)
        depositButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        depositButton.backgroundColor = .systemPurple
        depositButton.setTitleColor(.white, for: .normal)
        depositButton.layer.cornerRadius = 12
        depositButton.addTarget(self, action: #selector(depositButtonTapped), for: .touchUpInside)
        depositButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add all views
        [titleLabel, subtitleLabel, buyButton, sellButton, dailyRatesButton, purchaseTitleLabel, fromLabel, fromCurrencyButton, toLabel, toCurrencyButton, amountLabel, amountTextField, purchaseButton, depositButton].forEach {
            contentView.addSubview($0)
        }
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20),
            
            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            subtitleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20),
            
            // Buy button
            buyButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 30),
            buyButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buyButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            buyButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Sell button
            sellButton.topAnchor.constraint(equalTo: buyButton.bottomAnchor, constant: 12),
            sellButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            sellButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            sellButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Daily rates button
            dailyRatesButton.topAnchor.constraint(equalTo: sellButton.bottomAnchor, constant: 12),
            dailyRatesButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dailyRatesButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            dailyRatesButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Purchase section
            purchaseTitleLabel.topAnchor.constraint(equalTo: dailyRatesButton.bottomAnchor, constant: 40),
            purchaseTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            // From currency
            fromLabel.topAnchor.constraint(equalTo: purchaseTitleLabel.bottomAnchor, constant: 20),
            fromLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            fromCurrencyButton.topAnchor.constraint(equalTo: fromLabel.bottomAnchor, constant: 8),
            fromCurrencyButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            fromCurrencyButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            fromCurrencyButton.heightAnchor.constraint(equalToConstant: 44),
            
            // To currency
            toLabel.topAnchor.constraint(equalTo: fromCurrencyButton.bottomAnchor, constant: 16),
            toLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            toCurrencyButton.topAnchor.constraint(equalTo: toLabel.bottomAnchor, constant: 8),
            toCurrencyButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            toCurrencyButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            toCurrencyButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Amount
            amountLabel.topAnchor.constraint(equalTo: toCurrencyButton.bottomAnchor, constant: 16),
            amountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            amountTextField.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 8),
            amountTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            amountTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            amountTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Purchase button
            purchaseButton.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 30),
            purchaseButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            purchaseButton.widthAnchor.constraint(equalToConstant: 280),
            purchaseButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Deposit button
            depositButton.topAnchor.constraint(equalTo: purchaseButton.bottomAnchor, constant: 12),
            depositButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            depositButton.widthAnchor.constraint(equalToConstant: 280),
            depositButton.heightAnchor.constraint(equalToConstant: 50),
            depositButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    @objc private func showAllRates() {
        let exchangeRatesVC = ExchangeRatesViewController()
        
        // Create navigation controller if not already in one
        if let navigationController = navigationController {
            navigationController.pushViewController(exchangeRatesVC, animated: true)
        } else {
            let navController = UINavigationController(rootViewController: exchangeRatesVC)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true)
        }
    }
    
    @objc private func buyButtonTapped() {
        let alert = UIAlertController(
            title: "Buy Currency",
            message: "Navigate to currency purchase section below or check daily rates first!",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Check Rates First", style: .default) { _ in
            self.showAllRates()
        })
        
        alert.addAction(UIAlertAction(title: "Continue Below", style: .default) { _ in
            // Scroll to purchase section
            DispatchQueue.main.async {
                if let scrollView = self.view.subviews.first as? UIScrollView {
                    scrollView.setContentOffset(CGPoint(x: 0, y: 300), animated: true)
                }
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func sellButtonTapped() {
        let alert = UIAlertController(
            title: "Sell Currency",
            message: "Selling feature coming soon! For now, check our daily exchange rates.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "View Daily Rates", style: .default) { _ in
            self.showAllRates()
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func purchaseButtonTapped() {
        let alert = UIAlertController(
            title: "Purchase Currency",
            message: "Confirm your currency purchase. Please verify the exchange rate and amount before proceeding.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Check Latest Rates", style: .default) { _ in
            self.showAllRates()
        })
        
        alert.addAction(UIAlertAction(title: "Confirm Purchase", style: .default) { _ in
            // Handle purchase logic here
            let confirmAlert = UIAlertController(
                title: "Purchase Successful!",
                message: "Your currency purchase has been processed. You can now deposit it into your bank account.",
                preferredStyle: .alert
            )
            confirmAlert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(confirmAlert, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func depositButtonTapped() {
        let alert = UIAlertController(
            title: "Bank Account Deposit",
            message: "Select your bank account for currency deposit. Your purchased currency will be delivered to your selected account.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Select Bank Account", style: .default) { _ in
            // Handle bank account selection
            let bankAlert = UIAlertController(
                title: "Bank Account Selection",
                message: "Please set up your bank account details for deposit. This feature connects to your banking information.",
                preferredStyle: .alert
            )
            bankAlert.addAction(UIAlertAction(title: "Set Up Account", style: .default))
            bankAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(bankAlert, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "View Account Details", style: .default) { _ in
            // Show current bank account info
            let infoAlert = UIAlertController(
                title: "Account Information",
                message: "Routing: 987654321\nAccount: ****6789\nType: Checking\nStatus: Active",
                preferredStyle: .alert
            )
            infoAlert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(infoAlert, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}
