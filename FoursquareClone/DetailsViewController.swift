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
import CoreLocation
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
    var selectedId = ""
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
        
        if selectedName != "" {

            
            let firestoreData = Firestore.firestore()
            firestoreData.collection("Places").addSnapshotListener { snapshot, error in
                if error != nil {
                    self.alert(titleId: "Error!", messageId: error?.localizedDescription ?? "Error")
                }else {
                   if snapshot?.isEmpty != true && snapshot != nil {
                        
                        for document in snapshot!.documents {
                            if self.selectedId == document.documentID {
                            
                            if let name = document.get("name") as? String {
                                self.placeNameText.text = name
                            }
                            if let comment = document.get("comment") as? String {
                                self.commentText.text = comment
                            }
                            if let placeType = document.get("type") as? String {
                                self.placeTypeText.text = placeType
                            }
                            if let latitude = document.get("latitude") as? Double {
                                self.chosenLatitude = latitude
                            }
                            if let longitude = document.get("longitude") as? Double {
                                self.chosenLongitude = longitude
                            }
                            if let imageUrl = document.get("imageUrl") as? String   {
                                self.imageView.sd_setImage(with: URL(string: imageUrl))
                            }
                                let annotaion = MKPointAnnotation()
                                let coordinate = CLLocationCoordinate2D(latitude: self.chosenLatitude, longitude: self.chosenLongitude)
                                annotaion.coordinate = coordinate
                                annotaion.title = self.placeNameText.text
                                annotaion.subtitle = self.commentText.text
                                self.mapView.addAnnotation(annotaion)
                                self.locationManager.stopUpdatingLocation()
                                let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                let region = MKCoordinateRegion(center: coordinate, span: span)
                                self.mapView.setRegion(region, animated: true)
                                }
                            
                            
                        }
                    }
                }
            }
        }
        
        
        
    }
    
    
    @objc func chooseLocation(gestureRecognizer:UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            let touchedPoint = gestureRecognizer.location(in: self.mapView)
            let touchedCoordinates = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            chosenLatitude = touchedCoordinates.latitude
            chosenLongitude = touchedCoordinates.longitude
            let annotation = MKPointAnnotation()
            annotation.title = placeNameText.text
            annotation.subtitle = commentText.text
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.tintColor = UIColor.black
            
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
            
        }else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if selectedName != "" {
            let newRequestLocation = CLLocation(latitude: chosenLatitude, longitude: chosenLongitude)
            CLGeocoder().reverseGeocodeLocation(newRequestLocation) { placemarks, error in
                if let placemark = placemarks {
                    if placemark.count > 0 {
                        let newPlacemark = MKPlacemark(placemark: placemark[0])
                        let item = MKMapItem(placemark: newPlacemark)
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                        item.openInMaps(launchOptions: launchOptions)
                    }
                }
            }
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
                            let firestorePost = ["name" : self.placeNameText.text,"comment" : self.commentText.text, "type" : self.placeTypeText.text, "imageUrl" : imageUrl,"latitude" : self.chosenLatitude,"longitude" : self.chosenLongitude,"date" : FieldValue.serverTimestamp()] as [String:Any]
                            
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
