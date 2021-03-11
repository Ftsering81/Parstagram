//
//  CameraViewController.swift
//  Parstagram
//
//  Created by Fnu Tsering on 3/11/21.
//

import UIKit
import AlamofireImage

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var commentField: UITextField!
    
    @IBAction func onShare(_ sender: Any) {
    }
    
    @IBAction func onCameraButton(_ sender: Any) {
        let picker = UIImagePickerController() //this is a special built-in view controller that allows us to launch a camera or pick a photo from the photo library
        picker.delegate = self //this says when the user is done taking the photo, call me back on a function that that has the photo
        picker.allowsEditing = true //allowsEditing presents a second screen to the user after they take the photo to allow them to "edit" the photo before sharing.
        
        //After creating the UIImagePickerController, what we need to do is check to see if the camera is available before running in the simulator, otherwise it will crash
        if UIImagePickerController.isSourceTypeAvailable(.camera) { // This says if the camera is available, then use that for a photo.
            picker.sourceType = .camera
        } else { //if the camera is not available like in the simulators, get the photos from the photo library
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil) //presents the UIImagePickerController picker which will show us the photo library in the simulator and allows us to choose a photo.
            
        }
        //Even though we can choose a photo bc of onCameraButton(), it doesn't show up on our image view. In order to be able to display the photo, we have to implement this function:
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //this will hand you back a dictionary that has the image and a lot of other data about the image. We only want the actual image asset, so we will select just that from the dictionary info.
        let image = info[.editedImage] as! UIImage //cast as an image
        
        //once we have the image, we want to resize it because this image is like 10 megabyte image aka too big and if we try to upload it, it will cause issues. So to resize and display the image, we will use the pod AlamofireImage.
        let size = CGSize(width: 300, height: 300) //CGSize means Core Graphic Size
        let scaledImage = image.af_imageScaled(to: size) //scales down to the size specified in size variable
        imageView.image = scaledImage
        
        dismiss(animated: true, completion: nil) //we might need to dismiss that camera view
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
