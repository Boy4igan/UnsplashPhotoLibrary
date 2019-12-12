import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var favoritePhotosCollection: ULFavoriteCollection?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let favoriteViewModel = ULFavoritePhotosViewModel()
        
        favoritePhotosCollection = favoriteViewModel
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ULMainTabBarViewController(favoritePhotosViewModel: favoriteViewModel)
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        favoritePhotosCollection?.saveCollection()
    }
    
}

