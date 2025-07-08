import UIKit

class ExchangeRatesViewController: UIViewController {
    
    // MARK: - UI Components
    private var tableView: UITableView!
    private var refreshButton: UIBarButtonItem!
    private var loadingIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    private var exchangeRates: [ExchangeRateDisplayModel] = []
    private let oandaWebScraper = OandaWebScraper()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadExchangeRates()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "📊 Daily Exchange Rates"
        view.backgroundColor = .systemBackground
        
        // Create table view
        tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ExchangeRateTableViewCell.self, forCellReuseIdentifier: "ExchangeRateCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Create loading indicator
        loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)
        
        // Create refresh button
        refreshButton = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(refreshTapped)
        )
        navigationItem.rightBarButtonItem = refreshButton
        
        // Setup constraints
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Data Loading
    private func loadExchangeRates() {
        showLoading(true)
        
        Task {
            do {
                let rates = try await oandaWebScraper.fetchAllExchangeRates()
                
                await MainActor.run {
                    self.exchangeRates = rates
                    self.tableView.reloadData()
                    self.showLoading(false)
                }
            } catch {
                await MainActor.run {
                    self.showError(error)
                    self.showLoading(false)
                }
            }
        }
    }
    
    private func showLoading(_ show: Bool) {
        if show {
            loadingIndicator.startAnimating()
            refreshButton.isEnabled = false
        } else {
            loadingIndicator.stopAnimating()
            refreshButton.isEnabled = true
        }
    }
    
    @objc private func refreshTapped() {
        loadExchangeRates()
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error Loading Rates",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { _ in
            self.loadExchangeRates()
        })
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    @IBAction func refreshButtonTapped(_ sender: UIBarButtonItem) {
        loadExchangeRates()
    }
}

// MARK: - UITableViewDataSource
extension ExchangeRatesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exchangeRates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExchangeRateCell", for: indexPath) as! ExchangeRateTableViewCell
        let rate = exchangeRates[indexPath.row]
        cell.configure(with: rate)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ExchangeRatesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let rate = exchangeRates[indexPath.row]
        showRateDetails(for: rate)
    }
    
    private func showRateDetails(for rate: ExchangeRateDisplayModel) {
        let alert = UIAlertController(
            title: "\(rate.fromCurrency) → \(rate.toCurrency)",
            message: """
            Exchange Rate: \(rate.rate)
            Last Updated: \(rate.lastUpdated)
            
            1 \(rate.fromCurrency) = \(rate.rate) \(rate.toCurrency)
            """,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Data Models
struct ExchangeRateDisplayModel {
    let fromCurrency: String
    let toCurrency: String
    let rate: String
    let lastUpdated: String
    let changePercentage: String?
    let trend: RateTrend
}

enum RateTrend {
    case up, down, neutral
    
    var color: UIColor {
        switch self {
        case .up: return .systemGreen
        case .down: return .systemRed
        case .neutral: return .systemGray
        }
    }
    
    var symbol: String {
        switch self {
        case .up: return "▲"
        case .down: return "▼"
        case .neutral: return "●"
        }
    }
}
