//
//  DHCarousel.swift
//  DadHive
//
//  Created by Michael Westbrooks on 12/23/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import UIKit


class DHCarousel: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    fileprivate var reuseIdentifier = ""
    fileprivate var media: [Media]!

    init(collectionViewLayout layout: UICollectionViewLayout, cellID id: String, andMedia mediaData: [Media]) {
        super.init(collectionViewLayout: layout)
        reuseIdentifier = id
        media = mediaData
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.register(UINib(nibName: "DHCarouselImage",
                                            bundle: nil),
                                        forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.reloadData()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.media.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? DHCarouselImage else {
            return UICollectionViewCell()
        }
        let item = media[indexPath.row]
        cell.media = item.url
        cell.backgroundColor = .red
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: kWidthOfScreen, height: 350.0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return  0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

}
