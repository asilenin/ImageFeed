import UIKit

public protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImageListPresenterProtocol? { get set }
    
    func updateTableViewAnimated()
    func reloadRows(at indexPaths: [IndexPath])
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
}

final class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol {
    
    // MARK: - Public Properties
    var presenter: ImageListPresenterProtocol?
    var photos: [Photo] = []
    
    // MARK: - Private Properties
    private let imagesListService = ImagesListService.shared
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var imagesObserver: NSObjectProtocol?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - @IBOutlet
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        imagesObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: imagesListService,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.photos = self.imagesListService.photos
            self.tableView.reloadData()
        }
        
        presenter?.viewDidLoad()
        presenter?.initiateFetchPhotosNextPage()
        
    }
    
    deinit {
        if let obs = imagesObserver {
            NotificationCenter.default.removeObserver(obs)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                preconditionFailure("❌ [ImagesListViewController][prepare]: Invalid segue destination")
            }
            let photo = photos[indexPath.row]
            viewController.imageURL = URL(string: photo.fullImageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Helpers
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.performBatchUpdates({
                    tableView.insertRows(at: indexPaths, with: .automatic)
                })
            }
        }
    }
}

extension ImagesListViewController {
    
    // MARK: - Public Methods
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.cellDidEndDisplaying(at: indexPath)
    }
    
    func configure(presenter: ImageListPresenterProtocol) {
        self.presenter = presenter
        self.presenter?.viewController = self
    }
}

extension ImagesListViewController: UITableViewDataSource {
    
    // MARK: - Public Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier,for: indexPath)
                as? ImagesListCell else {
            return UITableViewCell()
        }
        
        let model = photos[indexPath.row]
        cell.delegate = self
        cell.configureCell(with: model, dateFormatter: dateFormatter)
        return cell
         
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    
    // MARK: - Public Methods
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        //let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        print("Presenter is \(presenter == nil ? "nil" : "set")")
        presenter?.didTapLike(at: indexPath)
    }
    func reloadRows(at indexPaths: [IndexPath]) {
        tableView.reloadRows(at: indexPaths, with: .automatic)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    
    // MARK: - Public Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.row < photos.count else { return 0 }
        let photo = photos[indexPath.row]
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        guard imageWidth > 0 else { return 0 }
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}
