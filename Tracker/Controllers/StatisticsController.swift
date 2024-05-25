import UIKit

class StatisticTableViewCell: UITableViewCell {
    
    // MARK: - UI Elements
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let borderLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.red.cgColor, UIColor.blue.cgColor, UIColor.green.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupCell() {
        contentView.addSubview(containerView)
        containerView.addSubview(valueLabel)
        containerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            valueLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            valueLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
        ])
        
        containerView.layer.insertSublayer(borderLayer, at: 0)
        containerView.backgroundColor = .systemBackground  // Set the background color to match the screen background
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        borderLayer.frame = containerView.bounds
        let borderMaskLayer = CAShapeLayer()
        borderMaskLayer.path = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: containerView.layer.cornerRadius).cgPath
        borderMaskLayer.fillColor = UIColor.clear.cgColor
        borderMaskLayer.strokeColor = UIColor.black.cgColor
        borderMaskLayer.lineWidth = 2
        borderMaskLayer.frame = containerView.bounds
        borderLayer.mask = borderMaskLayer
    }
    
    // MARK: - Configuration
    
    func configure(with statistic: Statistic) {
        valueLabel.text = "\(statistic.value)"
        titleLabel.text = statistic.title
    }
}
