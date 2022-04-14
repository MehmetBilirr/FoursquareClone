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
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))

        navigationController?.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItem.Style.done, target: self, action: #selector(logOut))
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
    

   

}
