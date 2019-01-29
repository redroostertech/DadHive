//
//  HomeViewController.swift
//  DadHive
//
//  Created by Michael Westbrooks II on 11/20/17.
//  Copyright © 2017 RedRooster Technologies Inc. All rights reserved.
//

import UIKit
import BouncyLayout

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    let layout = BouncyLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: self.view.frame.width, height: 150)
        layout.minimumInteritemSpacing = 20
        layout.minimumLineSpacing = 20
        mainCollectionView.setCollectionViewLayout(layout, animated: true)
        let nibName = UINib(nibName: "HomeCellCollectionViewCell", bundle: nil)
        mainCollectionView.register(nibName, forCellWithReuseIdentifier: "homeCell")
        
        mainCollectionView.setCollectionViewLayout(layout, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeCell", for: indexPath) as! HomeCellCollectionViewCell
        return cell
    }

}
