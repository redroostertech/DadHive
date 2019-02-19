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
    fileprivate var user: User!

    init(collectionViewLayout layout: UICollectionViewLayout, cellID id: String, andUserData userData: User) {
        super.init(collectionViewLayout: layout)
        reuseIdentifier = id
        user = userData
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        switch reuseIdentifier {
        case "DHCarouselImage":
            self.collectionView?.register(UINib(nibName: "DHCarouselImage",
                                                bundle: nil),
                                          forCellWithReuseIdentifier: reuseIdentifier)
            self.collectionView!.reloadData()
        case "DHCarouselItem":
            self.collectionView?.register(UINib(nibName: "DHCarouselItem",
                                                bundle: nil),
                                          forCellWithReuseIdentifier: reuseIdentifier)
            self.collectionView!.reloadData()
        default:
            return
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch reuseIdentifier {
        case "DHCarouselImage":
            return self.user.media?.count ?? 1
        case "DHCarouselCell":
            return self.user.media?.count ?? 1
        default:
            return 1
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch reuseIdentifier {
        case "DHCarouselImage":
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? DHCarouselImage else {
                return UICollectionViewCell()
            }
            if let pictures = self.user.media {
                let item = pictures[indexPath.row]
                cell.media = item.url
                cell.backgroundColor = .red
            } else {
                //  Set empty url
            }
            return cell
        case "DHCarouselItem":
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? DHCarouselItem else {
                return UICollectionViewCell()
            }
            if let info = self.user.infoSectionTwo {
                let item = info[indexPath.row]
                cell.loadData = item
            } else {
                // Set empty string
            }
            return cell
        default:
            return UICollectionViewCell()
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch reuseIdentifier {
        case "DHCarouselImage":
            return CGSize(width: kWidthOfScreen, height: 300.0)
        case "DHCarouselItem":
            return CGSize(width: 150.0, height: 91.0)
        default:
            return .zero
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch reuseIdentifier {
        case "DHCarouselImage":
            return  0
        case "DHCarouselItem":
            return 4
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        switch reuseIdentifier {
        case "DHCarouselImage":
            return  0
        case "DHCarouselItem":
            return 4
        default:
            return 0
        }
    }

}
