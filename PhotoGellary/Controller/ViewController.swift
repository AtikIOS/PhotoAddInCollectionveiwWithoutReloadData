//
//  ViewController.swift
//  PhotoGellary
//
//  Created by TONMOY BISHWAS on 13/8/24.
//

import UIKit
import PhotosUI

class ViewController: UIViewController {
    
//MARK: Variables
    var images: [UIImage] = []

    
//MARK: Ibout lets
    @IBOutlet weak var myCollectionView: UICollectionView!{
        didSet{
            self.myCollectionView.dataSource = self
            self.myCollectionView.delegate = self
            self.myCollectionView.register(CustomCollectionViewCell.nib(), forCellWithReuseIdentifier: CustomCollectionViewCell.identifier)
        }
    }
    
    
//MARK: View Controller Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadImages()
        print("Document directory: ", FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }


    
//MARK: Add Photo using PHPicker
    @IBAction func btnAddPhoto(_ sender: UIBarButtonItem) {
        phpickerController()
    }
    
//MARK: PHPicker Configure
    func phpickerController() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 5
        config.filter = .images
        
        let phpickerVC = PHPickerViewController(configuration: config)
        phpickerVC.delegate = self
        self.present(phpickerVC, animated: true)
    }
    
    
//MARK: Save images into Document Directory
    func saveImages( image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 1.0) else { return }
        
        let imageName = UUID().uuidString
        let fileURL = getDocumentDirectory().appendingPathComponent(imageName, conformingTo: .png)
        
        do{
            try data.write(to: fileURL)
        } catch{
            print(error)
        }
    }
    
    
//MARK: Get the Document Directory URL
    func getDocumentDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0]
    }
    
    
//MARK: Fatch images from the Docuemnt Directory and store this into a variable
    func loadImages() {
        let fileManager = FileManager.default
        let documentURL = getDocumentDirectory()
        
        do{
            let fileURLs = try fileManager.contentsOfDirectory(at: documentURL, includingPropertiesForKeys: nil)
            
            for fileURL in fileURLs {
                if let image = UIImage(contentsOfFile: fileURL.path) {
                    self.images.append(image)
                }
            }
        } catch{
            print(error)
        }
    }
}


//MARK: PHPicker View Controller Delegate Methods
extension ViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        var newImages: [UIImage] = []
        let dispatchGroup = DispatchGroup()
        
        for result in results {
            dispatchGroup.enter()
            let provider = result.itemProvider
            provider.canLoadObject(ofClass: UIImage.self)
            provider.loadObject(ofClass: UIImage.self) { object, error in
                if let image = object as? UIImage {
                    self.saveImages(image: image)
                    
                    DispatchQueue.main.async {
                        newImages.append(image)
                    }
                }
                
                dispatchGroup.leave()
            }
        }
    
        dispatchGroup.notify(queue: .main) {
            self.insertImageIntoCollectionView(newImages: newImages)
        }
        
        
        if results.isEmpty {
            picker.dismiss(animated: true)
            return
        }
    }
}




//MARK: UICollection View Delegate, Datasource and Delegate Flow Layout Methods
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomCollectionViewCell.identifier, for: indexPath) as! CustomCollectionViewCell
        
        cell.imgPhoto.image = images[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var sz = self.myCollectionView.frame.size.width / 3
        sz -= 2
        
        return CGSize(width: sz, height: sz)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        2
    }
    

    

    func insertImageIntoCollectionView(newImages: [UIImage]) {
        var indexPaths: [IndexPath] = []
        let startIndex = self.images.count
        
        for i in 0..<newImages.count {
            let indexPath = IndexPath(item: startIndex+i, section: 0)
            
            indexPaths.append(indexPath)
            self.images.append(newImages[i])
        }
        
        myCollectionView.performBatchUpdates {
            myCollectionView.insertItems(at: indexPaths)
        } completion: { _ in
            for indexPath in indexPaths {
                if let cell = self.myCollectionView.cellForItem(at: indexPath) as? CustomCollectionViewCell {
                    cell.imgPhoto.image = self.images[indexPath.item]
                }
            }
        }

    }
}
