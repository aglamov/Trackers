import UIKit

class StatisticsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var statistics: [(title: String, value: String)] = []
    private var trackerRecordStore: TrackerRecordStore!
    private var isEmpty: Bool = true
    let statisticsTitle = NSLocalizedString("statistics_title", comment: "Title for the statistics screen")
    let noDataMessage = NSLocalizedString("no_data_message", comment: "Message shown when there is no data to analyze")
    
    private lazy var emptyScreenImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "EmptyStatistics")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var emptyScreenText: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = noDataMessage
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private lazy var emptyScreenView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyScreenImage)
        view.addSubview(emptyScreenText)
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = statisticsTitle
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.sizeToFit()
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(StatisticTableViewCell.self, forCellReuseIdentifier: "StatisticCell")
        return tableView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAndDisplayStatistics()
        checkEmptyState()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStatisticsScreen()
    }
    
    private func setupStatisticsScreen() {
        view.backgroundColor = UIColor.systemBackground
        setupNavigationBar()
        addSubviews()
        constraintSubviews()
    }
    
    private func setupNavigationBar() {
        let titleBarButton = UIBarButtonItem(customView: titleLabel)
        navigationItem.leftBarButtonItem = titleBarButton
    }
    
    private func addSubviews() {
        view.addSubview(emptyScreenView)
        view.addSubview(tableView)
    }
    
    private func constraintSubviews() {
        NSLayoutConstraint.activate([
            emptyScreenView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyScreenView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyScreenView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyScreenView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            emptyScreenImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyScreenImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyScreenText.topAnchor.constraint(equalTo: emptyScreenImage.bottomAnchor, constant: 8),
            emptyScreenText.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            tableView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
   
    private func checkEmptyState() {
        //let isEmpty = statistics.isEmpty
        emptyScreenImage.isHidden = !isEmpty
        emptyScreenText.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    private func fetchAndDisplayStatistics() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            trackerRecordStore = try TrackerRecordStore(context: context)
            
            let stats = trackerRecordStore.computeStatistics()
            
            statistics = [
                (title: "Лучший период", value: "\(stats.bestPeriod)"),
                (title: "Идеальные дни", value: "\(stats.perfectDays)"),
                (title: "Трекеров завершено", value: "\(stats.trackersCompleted)"),
                (title: "Среднее значение", value: String(format: "%.2f", stats.averageValue))
            ]
            if stats.trackersCompleted == 0 {isEmpty = true}
            else {isEmpty = false}
            checkEmptyState()
            tableView.reloadData()
        } catch {
            checkEmptyState()
            print("Ошибка при создании TrackerRecordStore: \(error.localizedDescription)")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statistics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StatisticCell", for: indexPath) as? StatisticTableViewCell else {
            return UITableViewCell()
        }
        let statistic = statistics[indexPath.row]
        cell.configure(with: statistic)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100 // 80 for cell height and 20 for spacing (10+10)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
