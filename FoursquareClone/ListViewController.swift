//
//  ListViewController.swift
//  FoursquareClone
//
//  Created by Mehmet Bilir on 14.04.2022.
//

import UIKit
import Firebase

class ListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var selectedId = ""
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedName = placeNameArray[indexPath.row]
        selectedId = documentIdArray[indexPath.row]
        print(documentIdArray[indexPath.row])
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = placeNameArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeNameArray.count
    }
    
    @objc func getDataFromFirestore(){
        
        let firestoreData = Firestore.firestore()
        firestoreData.collection("Places").order(by: "date", descending: false).addSnapshotListener { snapshot, error in
            if error != nil {
                self.alert(titleId: "Error!", messageId: error?.localizedDescription ?? "Error!")
            }else {
                if snapshot?.isEmpty != true && snapshot != nil {
                    
                    self.placeNameArray.removeAll(keepingCapacity: false)
                    self.documentIdArray.removeAll(keepingCapacity: false)
                    
                    
                    for document in snapshot!.documents {
                        
                        if let placeName = document.get("name") as? String {
                            self.placeNameArray.append(placeName)
                           
                        }
                        
                        if  let documentId = document.documentID as? String {
                            self.documentIdArray.append(documentId)
                        }
                        
                        self.tableView.reloadData()
                        
                        
                        
                        
                        
                    }
                    
                    
                    
                    
                    
                    
                    
                }
                
                
                
                
                
            }
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            let destinationVC = segue.destination as! DetailsViewController
            destinationVC.selectedName = selectedName
            destinationVC.selectedId = selectedId
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            
            let firestoreData = Firestore.firestore()
            firestoreData.collection("Places").addSnapshotListener { snapshot, error in
                if error != nil {
                    self.alert(titleId: "Error!", messageId: error?.localizedDescription ?? "Error")
                }else {
                    if snapshot?.isEmpty != true && snapshot != nil {
                        
                        for document in snapshot!.documents {
                            
                                
                            if self.documentIdArray[indexPath.row] == document.documentID {
                                
                                
                                
                                    firestoreData.collection("Places").document(self.documentIdArray[indexPath.row]).delete { error in
                                        if error != nil {
                                            self.alert(titleId: "Error!", messageId: error?.localizedDescription ??  "Error")
                                        }else {
                                            
                                            
                                            self.tableView.reloadData()
                                            
                                            
                                        }
                                    }
                                
                                
                                }
                                
                            
                            
                            
                        }
                    }
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
