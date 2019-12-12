import UIKit

class ULPhotoCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Override property
    
    override var isSelected: Bool {
        didSet { didChangeSelectedState() }
    }
    
    //MARK: - Public property
    
    var viewModel: ULPhotoViewModel? {
        didSet {
            guard let imageData = viewModel?.imageData else { return }
            photoImageView.image = UIImage(data: imageData)
        }
    }
    
    //MARK: - Private properties
    
    private let photoImageView      = UIImageView()
    private let checkmarkImageView  = UIImageView()
    private let checkmarkPadding    = CGFloat(8)
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubviews()
    }
    
    //MARK: - Override methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        photoImageView.frame = bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        photoImageView.image = nil
    }
    
    //MARK: - Private methods
    
    private func setupSubviews() {
        addSubviews()
        setupCheckmarkImageViewPosition()
        assignDefaultAlphaValueForImageViews()
        
        checkmarkImageView.image = UIImage(named: "checkmark")
        
    }
    
    private func setupCheckmarkImageViewPosition() {
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkImageView.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                     constant: -8).isActive = true
        checkmarkImageView.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                   constant: -8).isActive = true
    }
    
    private func addSubviews() {
        addSubview(photoImageView)
        addSubview(checkmarkImageView)
    }
    
    private func didChangeSelectedState() {
        if isSelected {
            checkmarkImageView.alpha = 1
            photoImageView.alpha = 0.7
        } else {
            assignDefaultAlphaValueForImageViews()
        }
    }
    
    private func assignDefaultAlphaValueForImageViews() {
        checkmarkImageView.alpha = 0
        photoImageView.alpha = 1
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
