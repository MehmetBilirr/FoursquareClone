//
//  ViewController.swift
//  FoursquareClone
//
//  Created by Mehmet Bilir on 14.04.2022.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let currentUser = Auth.auth().currentUser
        if  currentUser != nil {
            
            performSegue(withIdentifier: "toListVC", sender: nil)
        }
    }
    
    @IBAction func signInClicked(_ sender: Any) {
        
        if emailText.text != "" && passwordText.text != "" {
            let auth = Auth.auth()
            auth.signIn(withEmail: emailText.text!, password: passwordText.text!) { data, error in
                if error != nil {
                    self.alert(titleId: "Error", messageId: error?.localizedDescription ?? "Error")
                    
                    
                }else {
                    self.performSegue(withIdentifier: "toListVC", sender: nil)
                }
            }
            
        }
        
    }
    
    @IBAction func signOutClicked(_ sender: Any) {
        
        if emailText.text != "" && passwordText.text != "" {
            
            let auth = Auth.auth()
            auth.createUser(withEmail: emailText.text!, password: passwordText.text!) { data, error in
                if error != nil {
                    self.alert(titleId: "Error!", messageId: error?.localizedDescription ?? "Error!")
                    
                    
                }else {
                    self.performSegue(withIdentifier: "toListVC", sender: nil)
                }
            }
            
        }else {
            alert(titleId: "Error!", messageId: "E-mail/Password empty.")
            
        }
    }
    
    func alert(titleId:String,messageId:String){
        let alert = UIAlertController(title: titleId, message: messageId, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel)
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }
    
}

