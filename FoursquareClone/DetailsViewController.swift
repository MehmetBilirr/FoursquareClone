//
//  DetailsViewController.swift
//  FoursquareClone
//
//  Created by Mehmet Bilir on 14.04.2022.
//

import UIKit
import MapKit
import Firebase
import SDWebImage
class DetailsViewController: UIViewController, MKMapViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CLLocationManagerDelegate {
    
    
    var chosenLatitude = Double()
    var chosenLongitude = Double()
    var locationManager = CLLocationManager()
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var placeTypeText: UITextField!
    @IBOutlet weak var placeNameText: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    var selectedName = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        imageView.isUserInteractionEnabled = true
        let imageRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        imageView.addGestureRecognizer(imageRecognizer)
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 3
        mapView.addGestureRecognizer(gestureRecognizer)
        
    }
    
    
    @objc func chooseLocation(gestureRecognizer:UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            let touchedPoint = gestureRecognizer.location(in: self.mapView)
            let touchedCoordinates = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            chosenLatitude = touchedCoordinates.latitude
            chosenLongitude = touchedCoordinates.longitude
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinates
            self.mapView.addAnnotation(annotation)
            
        }
    }
    
    @objc func chooseImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
        }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true)
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if selectedName == "" {
            
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan.init(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        }
    }
    
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        
        let storage = Storage.storage()
        let storageReference = storage.reference()
        let mediaFolder = storageReference.child("media")
        if let data = imageView.image?.jpegData(compressionQuality: 0.5) {
            let uuid = UUID().uuidString
            let imageFolder = mediaFolder.child("\(uuid).jpg")
            imageFolder.putData(data, metadata: nil) { metadata, error in
                if error != nil {
                    self.alert(titleId: "Error", messageId: error?.localizedDescription ?? "Error")
                    
                }else {
                    imageFolder.downloadURL { url, error in
                        if error != nil {
                            self.alert(titleId: "Error!", messageId: error?.localizedDescription ?? "Error")
                        }else {
                            let imageUrl = url?.absoluteString
                            
                            let firestore = Firestore.firestore()
                            let firestorePost = ["name" : self.placeNameText.text,"comment" : self.commentText.text, "type" : self.placeTypeText.text, "imageUrl" : imageUrl,"latitude" : self.chosenLatitude,"longitude" : self.chosenLongitude] as [String:Any]
                            
                            let firestoreFolder = firestore.collection("Places").addDocument(data: firestorePost) { error in
                                if error != nil {
                                    self.alert(titleId: "Error", messageId: error?.localizedDescription ?? "Error")
                                }else {
                                    self.navigationController?.popViewController(animated: true)
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
