import Foundation

protocol ULFavoritePhotosViewModelDelegate:  AnyObject {
    func didReceiveItemsAt(indexPaths: [IndexPath])
}

class ULFavoriteCollectionViewController: ULBasePhotosCollectionViewController, ULFavoritePhotosViewModelDelegate {
    
    //MARK: - Private property
    
    private lazy var favoriteViewModel = viewModel as! ULFavoritePhotosViewModel
    
    //MARK: - Override method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        favoriteViewModel.delegate = self
    }
    
    //MARK: - Favorite photos view model delegate
    
    func didReceiveItemsAt(indexPaths: [IndexPath]) {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.insertItems(at: indexPaths)
        }
    }
}
