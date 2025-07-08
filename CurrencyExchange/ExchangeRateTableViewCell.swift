import UIKit

class ExchangeRateTableViewCell: UITableViewCell {
    
    // MARK: - UI Elements
    private let fromCurrencyLabel = UILabel()
    private let toCurrencyLabel = UILabel()
    private let rateLabel = UILabel()
    private let changeLabel = UILabel()
    private let trendIndicator = UILabel()
    private let arrowLabel = UILabel()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Configure labels
        fromCurrencyLabel.font = UIFont.boldSystemFont(ofSize: 16)
        fromCurrencyLabel.textColor = .label
        
        toCurrencyLabel.font = UIFont.boldSystemFont(ofSize: 16)
        toCurrencyLabel.textColor = .label
        
        rateLabel.font = UIFont.systemFont(ofSize: 15)
        rateLabel.textColor = .secondaryLabel
        rateLabel.textAlignment = .right
        
        changeLabel.font = UIFont.systemFont(ofSize: 13)
        changeLabel.textAlignment = .right
        
        trendIndicator.font = UIFont.systemFont(ofSize: 12)
        trendIndicator.textAlignment = .center
        
        arrowLabel.text = "→"
        arrowLabel.font = UIFont.systemFont(ofSize: 14)
        arrowLabel.textColor = .systemBlue
        arrowLabel.textAlignment = .center
        
        // Add to content view
        [fromCurrencyLabel, arrowLabel, toCurrencyLabel, rateLabel, changeLabel, trendIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // From currency (left)
            fromCurrencyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            fromCurrencyLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -8),
            fromCurrencyLabel.widthAnchor.constraint(equalToConstant: 50),
            
            // Arrow
            arrowLabel.leadingAnchor.constraint(equalTo: fromCurrencyLabel.trailingAnchor, constant: 8),
            arrowLabel.centerYAnchor.constraint(equalTo: fromCurrencyLabel.centerYAnchor),
            arrowLabel.widthAnchor.constraint(equalToConstant: 20),
            
            // To currency
            toCurrencyLabel.leadingAnchor.constraint(equalTo: arrowLabel.trailingAnchor, constant: 8),
            toCurrencyLabel.centerYAnchor.constraint(equalTo: fromCurrencyLabel.centerYAnchor),
            toCurrencyLabel.widthAnchor.constraint(equalToConstant: 50),
            
            // Rate (right side)
            rateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            rateLabel.centerYAnchor.constraint(equalTo: fromCurrencyLabel.centerYAnchor),
            rateLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
            // Change percentage
            changeLabel.trailingAnchor.constraint(equalTo: rateLabel.trailingAnchor),
            changeLabel.topAnchor.constraint(equalTo: rateLabel.bottomAnchor, constant: 2),
            changeLabel.widthAnchor.constraint(equalTo: rateLabel.widthAnchor),
            
            // Trend indicator
            trendIndicator.trailingAnchor.constraint(equalTo: changeLabel.leadingAnchor, constant: -8),
            trendIndicator.centerYAnchor.constraint(equalTo: changeLabel.centerYAnchor),
            trendIndicator.widthAnchor.constraint(equalToConstant: 15)
        ])
    }
    
    // MARK: - Configuration
    func configure(with model: ExchangeRateDisplayModel) {
        fromCurrencyLabel.text = model.fromCurrency
        toCurrencyLabel.text = model.toCurrency
        rateLabel.text = model.rate
        
        if let change = model.changePercentage {
            changeLabel.text = change
            changeLabel.textColor = model.trend.color
            trendIndicator.text = model.trend.symbol
            trendIndicator.textColor = model.trend.color
        } else {
            changeLabel.text = ""
            trendIndicator.text = ""
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        fromCurrencyLabel.text = nil
        toCurrencyLabel.text = nil
        rateLabel.text = nil
        changeLabel.text = nil
        trendIndicator.text = nil
    }
}
