import UIKit

class ULPhotosCollectionViewController: ULBasePhotosCollectionViewController, ULPhotosViewModelDelegate, UISearchBarDelegate, UICollectionViewDataSourcePrefetching {
    
    //MARK: - Private properties
    
    private lazy var photosViewModel = viewModel as! ULPhotosViewModel
    private var addBarButtonItem: UIBarButtonItem!
    
    //MARK: - init
    
    override init(viewModel: ULBasePhotosViewModel) {
        super.init(viewModel: viewModel)
        
        photosViewModel.delegate = self
        setupBarItems()
    }
    
    //MARK: - Override methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchController()
        collectionView.prefetchDataSource = self
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 willDisplay cell: UICollectionViewCell,
                                 forItemAt indexPath: IndexPath) {
        
        if indexPath.row == photosViewModel.numberOfItems - 1  {
            photosViewModel.loadNextPhotosPage()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, didSelectItemAt: indexPath)
        
        addBarButtonItem.isEnabled = true
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, didDeselectItemAt: indexPath)
        
        if !photosViewModel.haveSelectedPhotos() {
            addBarButtonItem.isEnabled = false
        }
    }
    
    
    //MARK: - Photos view model delegate
    
    func willStartFetchPhotos() {
        print(#function)
    }
    
    func didReceiveNewPhotos(atIndexPaths indexPaths: [IndexPath]) {
        DispatchQueue.main.async {
            self.collectionView.insertItems(at: indexPaths)
        }
    }
    
    func didFinishLoadingPhotos(withError error: Error) {
        DispatchQueue.main.async {
            fatalError(error.localizedDescription)
        }
    }
    
    func didUpdatePhotoViewModelAt(indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.collectionView.reloadItems(at: [indexPath])
        }
    }
    
    func didRemoveAllPhotos() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    //MARK: - Search bar delegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text else { return }
        
        photosViewModel.removeAllPhotos()
        photosViewModel.fetchPhotos(by: query)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        photosViewModel.cancelReceivingPhotos()
    }
    
    //MARK: - Data Source prefetching
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        photosViewModel.prefetchItemsAt(indexPaths: indexPaths)
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        photosViewModel.cancelPrefetchingItemsAt(indexPaths: indexPaths)
    }
    
    //MARK: - Handle events
    
    @objc func addButtonTap(_ button: UIBarButtonItem) {
        guard let selectedIndexPaths = collectionView.indexPathsForSelectedItems else { return }
        
        photosViewModel.moveSelectedPhotosToFavoriteCollections()
        selectedIndexPaths.forEach { collectionView.deselectItem(at: $0, animated: true) }
    }
    
    //MARK: - Private methods
    
    private func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
    }
    
    private func setupBarItems() {
        addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                           target: self,
                                           action: #selector(addButtonTap(_:)))
        
        navigationItem.rightBarButtonItem = addBarButtonItem
        addBarButtonItem.isEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
