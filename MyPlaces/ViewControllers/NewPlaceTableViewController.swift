//
//  NewPlaceTableViewController.swift
//  MyPlaces
//
//  Created by Administrator on 27.10.2020.
//  Copyright © 2020 Administrator. All rights reserved.
//

import UIKit
import Cosmos

class NewPlaceTableViewController: UITableViewController {
    
    var currentPlace: Place!
    var isChangeImage = false
    var currentRating = 0.0 {
        didSet {
            ratingControl.rating = Int(currentRating)
        }
    }
    
    
    @IBOutlet var saveButton: UIBarButtonItem!
    
    @IBOutlet var placeImage: UIImageView!
    @IBOutlet var placeName: UITextField!
    @IBOutlet var placeLocation: UITextField!
    @IBOutlet var plaseType: UITextField!
    
    @IBOutlet var ratingControl: RatingControl!    
    @IBOutlet var cosmosView: CosmosView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        
        saveButton.isEnabled = false
        
        placeName.addTarget(self, action: #selector(changedNameField), for: .editingChanged)
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        
        setupEditScreen()
        
        cosmosView.settings.fillMode = .full
        cosmosView.didTouchCosmos = { rating in
            self.currentRating = rating
        }
    }
        
    // MARK: - Methods
    
    func saveNewPlace() {
        
        let image = isChangeImage ? placeImage.image : #imageLiteral(resourceName: "imagePlaceholder")
        
        let imageData = image?.pngData()
        
        let newPlace = Place(name: placeName.text!, location: placeLocation.text, type: plaseType.text, imageData: imageData, rating: Double(ratingControl.rating))
        
        if currentPlace != nil {
            try! realm.write{
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.imageData = imageData
                currentPlace.rating = newPlace.rating
            }
        } else {
            StorageManager.saveObject(newPlace)
        }
    }
    
    private func setupEditScreen() {
        
        guard currentPlace != nil else { return }
        
        setupNavigationBar()
        isChangeImage = true
                
        guard let imageData = currentPlace?.imageData, let image = UIImage(data: imageData) else { return }
        
        placeImage.image = image
        placeImage.contentMode = .scaleAspectFill
        placeName.text = currentPlace?.name
        placeLocation.text = currentPlace?.location
        plaseType.text = currentPlace?.type
        ratingControl.rating = Int(currentPlace.rating)
        cosmosView.rating = currentPlace.rating
    }
    
    private func setupNavigationBar() {
        
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        }
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
        saveButton.isEnabled = true
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            
            let cameraIcon = #imageLiteral(resourceName: "camera")
            let photoIcon = #imageLiteral(resourceName: "photo")
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(source: .camera)
            }
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true)
        } else {
            view.endEditing(true)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier, let mapVC = segue.destination as? MapViewController else { return }
        
        mapVC.MapViewControllerDelegate = self
        mapVC.incomeSegueIdentifier = identifier
        
        if identifier == "showPlace" {
            mapVC.place.name = placeName.text!
            mapVC.place.location = placeLocation.text!
            mapVC.place.type = plaseType.text!
            mapVC.place.imageData = placeImage.image?.pngData()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func canselPressed(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true)
    }
    
}

// MARK: - UITextFieldDelegate

extension NewPlaceTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc
    func changedNameField() {
        saveButton.isEnabled = placeName.text?.isEmpty == false
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension NewPlaceTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        
        if UIImagePickerController.isSourceTypeAvailable(source) {
            
            let pickerController = UIImagePickerController()
            pickerController.allowsEditing = true
            pickerController.sourceType = source
            pickerController.delegate = self
            
            present(pickerController, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        placeImage.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        placeImage.contentMode = .scaleAspectFill
        placeImage.clipsToBounds = true
        
        isChangeImage = true
                
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - MapViewControllerDelegate

extension NewPlaceTableViewController: MapViewControllerDelegate {
    
    func getAddress(_ address: String?) {
        placeLocation.text = address
    }
}
