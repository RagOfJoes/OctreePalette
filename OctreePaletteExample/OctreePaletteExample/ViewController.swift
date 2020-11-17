//
//  ViewController.swift
//  OctreePaletteExample
//
//  Created by Victor Ragojos on 11/16/20.
//

import UIKit

class ViewController: UIViewController {
    // MARK: - Internal Properties
    private let data: [Data] = [
        Data(image: UIImage(named: "Graffiti")!, type: .theme),
        Data(image: UIImage(named: "Paint")!, type: .theme),
        Data(image: UIImage(named: "Rocket")!, type: .theme),
        Data(image: UIImage(named: "Yeezus")!, type: .theme),
        Data(image: UIImage(named: "Test")!, type: .theme)
    ]
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delaysContentTouches = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(Cell.self, forCellWithReuseIdentifier: "Cell")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.clipsToBounds = true
        collectionView.backgroundColor = .systemBackground
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        
        return collectionView
    }()
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        setupConstraints()
    }
}

// MARK: - Setup Functions
extension ViewController {
    fileprivate func setupConstraints() {
        let collectionViewConstraint: [NSLayoutConstraint] = [
            self.collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.collectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
        ]
        NSLayoutConstraint.activate(collectionViewConstraint)
    }
}

// MARK: - UICollectionViewDelegate
extension ViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = 200
        let window = UIApplication.shared.windows[0]
        return CGSize(width: window.frame.width, height: height)
    }
}

// MARK: - UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! Cell
        cell.configure(image: data[indexPath.item].image)
        return cell
    }
}
