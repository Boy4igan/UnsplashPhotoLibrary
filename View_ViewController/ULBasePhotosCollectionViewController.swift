import UIKit

class ULBasePhotosCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    //MARK: - Protected property
    
    unowned var viewModel: ULBasePhotosViewModel
    
    //MARK: - Private properties
    
    private let cellIdentifier  = "photo cell"
    private let itemPerRow      = 2
    private let sectionInsets   = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    
    //MARK: - Init
    
    init(viewModel: ULBasePhotosViewModel) {
        self.viewModel = viewModel
        
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    //MARK: - Override methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        title = navigationController?.tabBarItem.title
        
        collectionView.allowsMultipleSelection = true
        collectionView.register(ULPhotoCollectionViewCell.self,
                                forCellWithReuseIdentifier: cellIdentifier)
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let photoCell = photoCellAt(indexPath: indexPath), photoCell.viewModel?.imageData == nil {
            return false
        }
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectItem(atIndexPath: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        viewModel.deselecItem(atIndexPath: indexPath)
    }
    
    //MARK: - Data source
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableBasePhotoCell(at: indexPath)
        
        cell.backgroundColor = .lightGray
        cell.viewModel = viewModel.photoViewModelAt(indexPath: indexPath)
        
        return cell
    }
    
    //MARK: - Flow layout delegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let photoSize       = viewModel.photoSize(atIndexPath: indexPath)
        let paddingWidth    = sectionInsets.left * CGFloat(itemPerRow + 1)
        let availableWidth  = collectionView.frame.width - paddingWidth
        let itemWidth       = availableWidth / CGFloat(itemPerRow)
        let itemHeight      = itemWidth * CGFloat(photoSize.height) / CGFloat(photoSize.width)
        
        return CGSize(width: itemWidth, height: itemHeight)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    
    //MARK: - Private methods
    
    private func dequeueReusableBasePhotoCell(at indexPath: IndexPath) -> ULPhotoCollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier,
                                                  for: indexPath) as! ULPhotoCollectionViewCell
    }
    
    private func photoCellAt(indexPath: IndexPath) -> ULPhotoCollectionViewCell? {
        return collectionView.cellForItem(at: indexPath) as? ULPhotoCollectionViewCell
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
