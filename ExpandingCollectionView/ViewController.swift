//
//  ViewController.swift
//  ExpandingCollectionView
//
//  Created by mert can çifter on 13.04.2023.
//

import UIKit
import SDWebImage
import SnapKit

class Section {
    let title: String
    var opened: Bool
    
    init(title: String, opened: Bool) {
        self.title = title
        self.opened = opened
    }
}



class ViewController: UIViewController {

    // MARK: Properties
    
    private lazy var collectionView = UICollectionView(frame: .zero,collectionViewLayout:
         UICollectionViewCompositionalLayout { (sectionNumber, env) -> NSCollectionLayoutSection? in
        
        let item = NSCollectionLayoutItem.init(layoutSize: .init(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(300)))
        item.contentInsets.bottom = 16
        item.contentInsets.trailing = 16

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(10000)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 32, leading: 16, bottom: 0, trailing: 0)

        section.boundarySupplementaryItems = [
            .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading),
        ]
        
       return section
        
    })
    
    private var sections = [Section]()

    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        configureModels()
        
        view.addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.identifier)

        collectionView.register(CollectionHeaderReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: CollectionHeaderReusableView.identifier)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    // MARK: Helpers
    
    func configureModels() {
        self.sections = [
            Section(title: "Header 1", opened: false),
            Section(title: "Header 2", opened: false),
            Section(title: "Header 3", opened: false),
            Section(title: "Header 4", opened: false)
        ]
    }


}


// MARK: UICollectionViewDelegate

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CollectionHeaderReusableView.identifier, for: indexPath) as! CollectionHeaderReusableView
        
        let section = sections[indexPath.section]
        
        header.sectionModel = section
        header.delegate = self
        header.titleLabel.text = section.title
        
        let bottom = UIImage(systemName: "arrow.down")
        let up = UIImage(systemName: "arrow.up")
        
        if section.opened {
            header.button.setImage(UIImage(systemName: "arrow.up"), for: .normal)

        }else {
            header.button.setImage(UIImage(systemName: "arrow.down"), for: .normal)
        }
        
        return header
    }
    
        
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if sections[section].opened {
            return 4
        }else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
                
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath) as? CollectionViewCell else {
            return UICollectionViewCell()
        }
        return cell
    }
}


extension ViewController: HeaderViewDelegate {
    func onClick(sectionModel: Section) {
                
        sections.forEach { model in
            if model === sectionModel {
                model.opened.toggle()
                collectionView.reloadData()
            }
        }
    }
}



// MARK: - UICollectionReusableView

protocol HeaderViewDelegate: AnyObject {
    func onClick(sectionModel: Section)
}

class CollectionHeaderReusableView: UICollectionReusableView {
    
    weak var delegate: HeaderViewDelegate?

    
    static let identifier = "CollectionHeaderReusableView"

    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    let button : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.down"), for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

        return button
    }()
    
    var sectionModel: Section?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureSubviews()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func buttonTapped(){
        if let sectionModel = sectionModel {
            delegate?.onClick(sectionModel: sectionModel)
        }
    }
}

extension CollectionHeaderReusableView {
    func configureSubviews() {
        
        addSubview(titleLabel)
        addSubview(button)
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(snp.left).offset(10)
            make.center.equalTo(self)
        }
        
        button.snp.makeConstraints { make in
            make.right.equalTo(snp.right).offset(-20)
            make.centerY.equalTo(self)
        }
        
    
    }
}


// MARK: - UICollectionViewCell


class CollectionViewCell: UICollectionViewCell {
    
    static let identifier = String(describing: CollectionViewCell.self)

    // MARK: - Properties
        
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 20
        return view
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
}

extension CollectionViewCell {
    func configureSubviews() {
        imageView.sd_setImage(with: URL(string: "https://picsum.photos/200/300"))
        
        contentView.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top)
            make.right.equalTo(contentView.snp.right)
            make.left.equalTo(contentView.snp.left)
            make.bottom.equalTo(contentView.snp.bottom)
        }

    }
}
