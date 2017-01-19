//
//  ViewController.swift
//  spectiv1
//
//  Created by Jason Haugen on 11/10/16.
//  Copyright © 2016 Jason Haugen. All rights reserved.
//

import UIKit
import Firebase

class SearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate{
        
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchCollection: UICollectionView!
    @IBOutlet weak var bestCollection: UICollectionView!
    
    
    var selection: Int = 0;
    let rootRef = FIRDatabase.database().reference()
    
    let tap = UITapGestureRecognizer()
    
    //Photos in collection view
    var photos: [VotePhoto] = []
    var photoSubmitters: [String] = []
    var photoNames: [String] = []

    
    var bestPhotos: [VotePhoto] = []
    var bestPhotoSubmitters: [String] = []
    var bestPhotoNames: [String] = []
    
    var userEmail: String!
    var newSearch: Bool = false
    
    let oneDayAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())?.description.components(separatedBy: " ")[0]
    let twoDayAgo = Calendar.current.date(byAdding: .day, value: -3, to: Date())?.description.components(separatedBy: " ")[0]
    let threeDayAgo = Calendar.current.date(byAdding: .day, value: -4, to: Date())?.description.components(separatedBy: " ")[0]
    let fourDayAgo = Calendar.current.date(byAdding: .day, value: -5, to: Date())?.description.components(separatedBy: " ")[0]
    
    var bestValue = -1
    var bestUser = FIRDataSnapshot()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        searchCollection.backgroundColor = UIColor.white
        searchCollection.reloadData()
        searchCollection.dataSource = self
        searchCollection.delegate = self
        
        bestCollection.backgroundColor = UIColor.white
        bestCollection.reloadData()
        bestCollection.dataSource = self
        bestCollection.delegate = self
        
        self.view.addSubview(searchCollection)
        self.view.addSubview(bestCollection)
        
        searchBar.delegate = self
        
        tap.addTarget(self, action: #selector(SearchViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        tap.isEnabled = false
        
        userEmail = UserDefaults.standard.object(forKey: "currentUserEmail") as! String!
        
        // for best photos
        DispatchQueue.global(qos:  .userInitiated).async {
            self.fetchBestImages()
            self.bestCollection.reloadData()
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ======================================
    // Collection View Delegate/Data Source Functions
    // ======================================
    
    //Set number of cells in collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == bestCollection){
            return self.bestPhotos.count
        }
        return self.photos.count
    }
    
    //Set number of sections in collection view
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //Fill cells based on index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(collectionView == searchCollection){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchCell", for: indexPath) as! VoteCell
            let photo: VotePhoto = indexPathPhoto(indexPath: indexPath as NSIndexPath)
            
            if (photo.submitterName == "") { //error check
                return cell
            }
            
            cell.searchImageView.image = photo.photoImage.image
            cell.submitterName = photo.submitterName

            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bestCell", for: indexPath) as! VoteCell
            let photo: VotePhoto = indexPathBestPhoto(indexPath: indexPath as NSIndexPath)
            
            if (photo.submitterName == "") { //error check
                return cell
            }
            
            cell.searchImageView.image = photo.photoImage.image
            cell.submitterName = photo.submitterName
            
            return cell
        }
        
    }
    
    //Selected cell, push cell view
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailView = self.storyboard?.instantiateViewController(withIdentifier: "detailView") as! DetailViewController
        
        //Search selection
        if(collectionView == searchCollection){
            let p = indexPathPhoto(indexPath: indexPath as NSIndexPath)
            detailView.submitterName = p.submitterName
            detailView.image = p.photoImage.image
            detailView.photoName = self.searchBar.text
            self.navigationController?.pushViewController(detailView, animated: true)
        }
        else{
            let q = indexPathBestPhoto(indexPath: indexPath as NSIndexPath)
            detailView.submitterName = q.submitterName
            detailView.image = q.photoImage.image
            detailView.photoName = bestPhotoNames[indexPath.row]
            self.navigationController?.pushViewController(detailView, animated: true)
        }
        
        
        //FIXME best cell selection
        
        
    }
    
    // ======================================
    // Collection View Layout Functions
    // ======================================
    
    //Edge insets
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    //Cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth: CGFloat = (self.view.frame.width - 40) / 4.0
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    //Line spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }

    // ======================================
    // SearchBar Functions
    // ======================================
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(!newSearch){
            newSearch = true
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        tap.isEnabled = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if(newSearch){
            clearSearchResults()
            searchCollection.reloadData()
            DispatchQueue.global(qos:  .userInitiated).async {
                self.fetchImages()
                self.searchCollection.reloadData()
                self.newSearch = false
            }
        }
    }
    
    func clearSearchResults(){
        photos.removeAll()
        photoNames.removeAll()
        photoSubmitters.removeAll()
    }
    
    func fetchImages(){
        rootRef.observeSingleEvent(of: .value, with: { snapshot in
            let enumerator = snapshot.children
            while let elem = enumerator.nextObject() as? FIRDataSnapshot {
                if elem.key != "Follow"{
                    self.queryForSubject(date: elem.key)
                }
            }
        })
    }
    
    func fetchBestImages(){
        rootRef.observeSingleEvent(of: .value, with: { snapshot in
            let enumerator = snapshot.children
            
            while let elem = enumerator.nextObject() as? FIRDataSnapshot {
                if elem.key == self.oneDayAgo {
                    self.queryForBestSubject(date: elem.key)
                }
                
                self.bestValue = -1
                self.bestUser = FIRDataSnapshot()
                
                if elem.key == self.twoDayAgo {
                    self.queryForBestSubject(date: elem.key)
                }
                
                self.bestValue = -1
                self.bestUser = FIRDataSnapshot()
                
                if elem.key == self.threeDayAgo {
                    self.queryForBestSubject(date: elem.key)
                }
                
                self.bestValue = -1
                self.bestUser = FIRDataSnapshot()
                
                if elem.key == self.fourDayAgo {
                    self.queryForBestSubject(date: elem.key)
                }
            }
        })
    }
    
    func queryForBestSubject(date: String) {
        rootRef.child(date).observeSingleEvent(of: .value, with: { snapshot in
            let enumerator = snapshot.children
            while let elem = enumerator.nextObject() as? FIRDataSnapshot {
                self.getBestSubmissions(date: date, subject: elem.key)
            }
        })
    }
    
    func getBestSubmissions(date: String, subject: String){
        let storage = FIRStorage.storage().reference()
        
        rootRef.child(date).child(subject).observeSingleEvent(of: .value, with: { snapshot in
            let enumerator = snapshot.children
            while let user = enumerator.nextObject() as? FIRDataSnapshot {
                if (user.value as? Int)! > self.bestValue {
                    self.bestUser = user
                    self.bestValue = (user.value as? Int)!
                }
            }
            
            let imageRef = storage.child("user_images/\(self.bestUser.key)/\(subject).JPG")
            
            imageRef.data(withMaxSize: 1 * 1024 * 1024 * 1024) { (data, error) -> Void in
                    if (error == nil) {
                        let image = UIImageView(image: UIImage(data: data!))
                        self.bestPhotos.append(VotePhoto(submitterName: self.bestUser.key, photoImage: image))
                        self.bestPhotoSubmitters.append(self.bestUser.key)
                        self.bestPhotoNames.append(subject)
                        self.bestCollection.reloadData()
                    }
            }
        })
    }
    
    func queryForSubject(date: String) {
        rootRef.child(date).observeSingleEvent(of: .value, with: { snapshot in
            let enumerator = snapshot.children
            while let elem = enumerator.nextObject() as? FIRDataSnapshot {
                if elem.key == self.searchBar.text{
                    self.getSubmissions(date: date, subject: elem.key)
                }
            }
        })
    }
    
    func getSubmissions(date: String, subject: String){
        let storage = FIRStorage.storage().reference()
        
        rootRef.child(date).child(subject).observeSingleEvent(of: .value, with: { snapshot in
            let enumerator = snapshot.children
            while let user = enumerator.nextObject() as? FIRDataSnapshot {
                let imageRef = storage.child("user_images/\(user.key)/\(subject).JPG")
                imageRef.data(withMaxSize: 1 * 1024 * 1024 * 1024) { (data, error) -> Void in
                    if (error == nil) {
                        let image = UIImageView(image: UIImage(data: data!))
                        self.photos.append(VotePhoto(submitterName: user.key, photoImage: image))
                        self.photoSubmitters.append(user.key)
                        self.photoNames.append(subject)
                        self.searchCollection.reloadData()
                    }
                    else{
                        print("Error downloading image")
                    }
                }

            }
        })
    }

    // ======================================
    // Helper Functions
    // ======================================
    
    //Get photo based on index path
    func indexPathPhoto(indexPath: NSIndexPath) -> VotePhoto {
        if (photos.count != 0) {
            return photos[indexPath.row]
        } else {
            return VotePhoto(submitterName: "", photoImage: UIImageView(image: UIImage(named: "")))
        }
    }
    
    func indexPathBestPhoto(indexPath: NSIndexPath) -> VotePhoto {
        if (bestPhotos.count != 0) {
            return bestPhotos[indexPath.row]
        } else {
            return VotePhoto(submitterName: "", photoImage: UIImageView(image: UIImage(named: "")))
        }
    }
    
    func dismissKeyboard() {
        searchBar.endEditing(true)
        tap.isEnabled = false
    }
    
    func emailToFolder(email: String) -> String{
        let strippedText = email.components(separatedBy: CharacterSet.punctuationCharacters).joined(separator: "").components(separatedBy: " ").filter{!$0.isEmpty}
        var folder = ""
        for block in strippedText{
            folder+=block
        }
        
        return folder
    }

    // helper function
    func getDate()->String{
        let gmt = NSDate()
        let array = gmt.description.components(separatedBy: " ")
        let day = array[0]
        return day
    }
}

