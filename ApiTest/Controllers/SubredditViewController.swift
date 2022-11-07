import UIKit

final class SubredditViewController: UIViewController, Storyboarded {
    enum TableSection: Int {
        case items
        case loader
    }
    
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var tableView: UITableView!
    
    weak var coordinator: MainCoordinator?
    
    private let refreshControl = UIRefreshControl()
    private let pageLimit = 30
    
    private var currentLastLink: String? = nil
    private var searchText: String {
        get {
            searchTextField.text ?? ""
        }
    }
    
    private var items = [Child] () {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func fetchData(isPoolToRefresh: Bool = false,
                           after: String = "",
                           completed: ((Bool) -> Void)? = nil) {
        guard searchText.count > 2 else { return }
        
        RedditService.shared.getSubredditNew(searchText,link: after) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let subreddit):
                guard let children = subreddit.data?.children else { return }
                
                if isPoolToRefresh {
                    self.items.removeAll()
                }
                
                self.items.append(contentsOf: children)
                self.currentLastLink = subreddit.data?.after
                completed?(true)
            case .failure(let error):
                AlertManager.shared.showAlert(coordinator: self.coordinator, title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                completed?(false)
            }
        }
    }
    
    private func setupView() {
        tableView.delegate = self
        tableView.dataSource = self
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(callPullToRefresh), for: .valueChanged)
    }
    
    @objc private func callPullToRefresh() {
        fetchData(isPoolToRefresh: true) { [weak self] isSuccess  in
            guard let self else { return }
            
            self.refreshControl.endRefreshing()
            self.refreshControl.isHidden = true
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        fetchData(isPoolToRefresh: true)
    }
}

extension SubredditViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let listSection = TableSection(rawValue: section) else { return 0 }
        switch listSection {
        case .items:
            return items.count
        case .loader:
            return items.count >= pageLimit ? 1 : 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = TableSection(rawValue: indexPath.section) else { return UITableViewCell() }
        
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        
        switch section {
        case .items:
            let item = items[indexPath.row]
            cell.textLabel?.text = item.data?.title
            cell.textLabel?.textColor = .label
        case .loader:
            cell.textLabel?.text = "Loading..."
            cell.textLabel?.textColor = .systemBlue
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let section = TableSection(rawValue: indexPath.section) else { return }
        guard !items.isEmpty else { return }
        
        if section == .loader {
            fetchData(after: currentLastLink ?? "") { [weak self] success in
                if !success {
                    self?.hideBottomLoader()
                }
            }
        }
    }

    private func hideBottomLoader() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            let lastListIndexPath = IndexPath(row: self.items.count - 1, section: TableSection.items.rawValue)
            self.tableView.scrollToRow(at: lastListIndexPath, at: .bottom, animated: true)
        }
    }
}
