//
//  ListViewController.swift
//  FoursquareClone
//
//  Created by Mehmet Bilir on 14.04.2022.
//

import UIKit
import Firebase

class ListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var selectedName = ""
    var documentIdArray = [String]()
    var placeNameArray = [String]()
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))

        navigationController?.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItem.Style.done, target: self, action: #selector(logOut))
        
        getDataFromFirestore()
    }
    
    @objc func logOut(){
        
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "toLoginVC", sender: nil)
        }catch{
            print("error")
        }
        
    }
    
    @objc func addButtonClicked(){
        selectedName = ""
        
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
        
    }
    
    func getDataFromFirestore(){
        
        let firestoreData = Firestore.firestore()
        firestoreData.collection("Places").addSnapshotListener { snapshot, error in
            if error != nil {
                self.alert(titleId: "Error!", messageId: error?.localizedDescription ?? "Error!")
            }else {
                if snapshot?.isEmpty != true && snapshot != nil {
                    
                    
                    self.documentIdArray.removeAll(keepingCapacity: false)
                    self.placeNameArray.removeAll(keepingCapacity: false)
                    
                    for document in snapshot!.documents {
                        
                        let documentId = document.documentID
                        
                        self.documentIdArray.append(documentId)
                        
                        
                        
                        if let placeName = document.get("name") as? String {
                            self.placeNameArray.append(placeName)
                           
                        }
                    }
                    self.tableView.reloadData()
                    
                    
                }
                
                
                
                
                
            }
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    func alert(titleId:String,messageId:String){
        let alert = UIAlertController(title: titleId, message: messageId, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel)
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }
    

   

}
