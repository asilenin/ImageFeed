import UIKit

final class ImagesListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    
    private var photos: [Photo] = []
    private let imagesListService = ImagesListService.shared

    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    var imagesObserver: NSObjectProtocol?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        imagesObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: imagesListService,
            queue: .main
        ) { [weak self] _ in
            //self?.updateTableViewAnimated()
            guard let self = self else { return }
            self.photos = self.imagesListService.photos
            self.tableView.reloadData()
        }
        
        if let token = OAuth2TokenStorage.shared.token {
            imagesListService.fetchPhotosNextPage(token: token) { _ in }
        } else {
            print("❌ [ImagesListViewController][viewDidLoad] No OAuth token found — cannot load photos.")
        }
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
    
    private func updateTableViewAnimated() {
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

extension ImagesListViewController: UITableViewDataSource {
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
        //configCell(for: cell, with: indexPath)
        //cell.configure(with: model, dateFormatter: dateFormatter)
        return cell
         
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { result in
        switch result {
        case .success:
            self.photos = self.imagesListService.photos
            cell.setIsLiked(self.photos[indexPath.row].isLiked)
            UIBlockingProgressHUD.dismiss()
        case .failure:
           UIBlockingProgressHUD.dismiss()
           // Покажем, что что-то пошло не так
           // TODO: Показать ошибку с использованием UIAlertController
           }
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        /*guard let image = UIImage(named: photosName[indexPath.row]) else {
            return 0
        }*/
        guard indexPath.row < photos.count else { return 0 }
        let photo = photos[indexPath.row]

        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        //let imageWidth = image.size.width
        let imageWidth = photo.size.width
        guard imageWidth > 0 else { return 0 }
        let scale = imageViewWidth / imageWidth
        //let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}

extension ImagesListViewController {    
    private func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                completion(UIImage(data: data))
            } else {
                completion(nil)
            }
        }.resume()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            if let token = OAuth2TokenStorage.shared.token {
                imagesListService.fetchPhotosNextPage(token: token) { _ in }
            } else {
                print("❌ [ImagesListViewController][tableView forRowAt]: No OAuth token found — cannot load photos.")
            }
        }
    }
}
