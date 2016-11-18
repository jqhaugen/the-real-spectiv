//
//  ViewController.swift
//  spectiv1
//
//  Created by Jason Haugen on 11/10/16.
//  Copyright © 2016 Jason Haugen. All rights reserved.
//

import UIKit
import Firebase

class SearchViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
        
    @IBOutlet weak var theCollection: UICollectionView!
    
    var selection: Int = 0;
    let rootRef = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        theCollection.backgroundColor = UIColor.white
        theCollection.reloadData()
        
        theCollection.dataSource = self
        theCollection.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ======================================
    // collection view functions
    // ======================================
    
    // required function to figure out how many cells in the collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15;
    }
    
    // required function to figure out what to put in each cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PictureCollectionViewCell
        
        // dynamically change the image of a cell
        //cell.theImage.image = ?????
        
        return cell
    }
    
    // set the var selection to whatever the user tapped on to know what index in myArray to pass along to the detail view
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selection = indexPath.item
    }
    
    
    
}

