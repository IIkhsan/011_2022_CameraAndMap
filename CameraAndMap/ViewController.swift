//
//  ViewController.swift
//  CameraAndMap
//
//  Created by ilyas.ikhsanov on 29.03.2022.
//

import UIKit
import MapKit
import Photos
import PhotosUI

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMapView()
    }
    
    private func configureMapView() {
        mapView.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(CustomAnnotation.self))
        
        let coordinate = CLLocationCoordinate2D(latitude: 55.805569, longitude: 48.943055)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        mapView.delegate = self
        
        let span = MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
        mapView.setRegion(MKCoordinateRegion(center: coordinate, span: span), animated: true)
    }
    
    private func getPhotoFromLibrary() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 1
        config.filter = .images
        let vc = PHPickerViewController(configuration: config)
        vc.delegate = self
        present(vc, animated: true)
    }
    
    private func getPhotoFromCamera() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @IBAction func setPhotoToPlace(_ sender: Any) {
        let alert = UIAlertController()
        alert.addAction(UIAlertAction(title: "Library", style: .default, handler: { _ in
            self.getPhotoFromLibrary()
        }))
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.getPhotoFromCamera()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private func addAnnotation(image: UIImage) {
        let center = self.mapView.centerCoordinate
        let imageAnnotation = CustomAnnotation(coordinate: center)
        imageAnnotation.title = Date().formatted()
        imageAnnotation.image = image
        
        DispatchQueue.main.async {
            self.mapView.addAnnotation(imageAnnotation)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        addAnnotation(image: image)
    }
}

// MARK: - MKMapViewDelegate

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }
        
        if let annotation = annotation as? CustomAnnotation {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: NSStringFromClass(CustomAnnotation.self), for: annotation)
            return annotationView
        } else {
            return nil
        }
    }
}

extension ViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        results.forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                guard let image = reading as? UIImage, error == nil else {
                    return
                }
                self.addAnnotation(image: image)
            }
        }
    }

}
