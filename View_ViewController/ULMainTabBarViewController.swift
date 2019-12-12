import UIKit

class ULMainTabBarViewController: UITabBarController {

    private let photosViewModel = ULPhotosViewModel()
    
    //MARK: - Init
    
    init(favoritePhotosViewModel: ULFavoritePhotosViewModel) {
        super.init(nibName: nil, bundle: nil)
        
        let photosCollectionViewController = ULPhotosCollectionViewController(viewModel: photosViewModel)
        let favoritePhotosCollectionViewController = ULFavoriteCollectionViewController(viewModel: favoritePhotosViewModel)
        
        
        photosViewModel.favoriteCollection = favoritePhotosViewModel
        
        viewControllers = [
            navigateVC(roootVC: photosCollectionViewController,
                       tabBarTitle: "Photos",
                       tabBarImageTitle: "photos"),
            navigateVC(roootVC: favoritePhotosCollectionViewController,
                       tabBarTitle: "Favorite",
                       tabBarImageTitle: "favorite")
        ]
    }
    
    //MARK: - Private methods
    
    func navigateVC(roootVC: UIViewController, tabBarTitle: String, tabBarImageTitle: String) -> UINavigationController {
        let navVC = UINavigationController(rootViewController: roootVC)
        
        navVC.tabBarItem.title = tabBarTitle
        navVC.tabBarItem.image = UIImage(named: tabBarImageTitle)
        
        return navVC
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
