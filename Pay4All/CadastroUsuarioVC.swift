//
//  CadastroUsuarioVC.swift
//  Pay4All
//
//  Created by Carlos Doki on 03/06/17.
//  Copyright © 2017 Carlos Doki. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import CoreImage

class CadastroUsuarioVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageAdd: UIImageView!
    @IBOutlet weak var nomeField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var confirmarEmailField: UITextField!
    @IBOutlet weak var dddField: UITextField!
    @IBOutlet weak var celularField: UITextField!
    @IBOutlet weak var senhaField: UITextField!
    @IBOutlet weak var confirmarSenhaField: UITextField!
    
    var ID = ""
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<AnyObject, UIImage> = NSCache()
    var imageSelected = false
    var newMedia: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //  Make a variable equal to a random number....
        
        let randomNum:UInt32 = arc4random_uniform(10000) // range is 0 to 99999
        
        // convert the UInt32 to some other  types
        
        ID = String(format: "%05d", randomNum) //string works too
        ID = ID + String(round(Date().timeIntervalSince1970))
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
//        imagePicker.delegate = self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePicker.delegate = self
    }
    
    
    @IBAction func cadastrarBtn(_ sender: UIButton) {
        if emailField.text != confirmarEmailField.text {
            let alertController = UIAlertController(title: "Alerta", message: "Email digitados não conferem!", preferredStyle: .alert)
            //We add buttons to the alert controller by creating UIAlertActions:
            let actionOk = UIAlertAction(title: "OK",
                                         style: .default,
                                         handler: nil) //You can use a block here to handle a press on this button
            
            alertController.addAction(actionOk)
            
            self.present(alertController, animated: true, completion: nil)
            return
            
        }
        if senhaField.text != confirmarSenhaField.text {
            let alertController = UIAlertController(title: "Alerta", message: "Senhas digitadas não conferem!", preferredStyle: .alert)
            //We add buttons to the alert controller by creating UIAlertActions:
            let actionOk = UIAlertAction(title: "OK",
                                         style: .default,
                                         handler: nil) //You can use a block here to handle a press on this button
            
            alertController.addAction(actionOk)
            
            self.present(alertController, animated: true, completion: nil)
            return
        }
        if (emailField.text ==  "" || confirmarEmailField.text == "" ||
            senhaField.text == "" || confirmarSenhaField.text == "") {
            let alertController = UIAlertController(title: "Alerta", message: "Campos em branco!", preferredStyle: .alert)
            //We add buttons to the alert controller by creating UIAlertActions:
            let actionOk = UIAlertAction(title: "OK",
                                         style: .default,
                                         handler: nil) //You can use a block here to handle a press on this button
            
            alertController.addAction(actionOk)
            
            self.present(alertController, animated: true, completion: nil)
            return
        }
        if let email = emailField.text, let pwd = senhaField.text, let nome = nomeField.text, let ddd = dddField.text, let celular = celularField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if error == nil {
                    print("DOKI: User authenticated with Firebase")
                    if let user = user {
                        let userData = ["provider": user.providerID,
                                        "ddd" : ddd,
                                        "celular" : celular,
                                        "nome" : nome,
                                        "id": self.ID]
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: {(user, error) in
                        if error != nil {
                            print("DOKI: Unable to authenticated using email - \(error)")
                        } else {
                            print("DOKI: Sucessfully authenticated with Firebase")
                            if let user = user {
                                let userData = ["provider": user.providerID,
                                                "ddd" : ddd,
                                                "celular" : celular,
                                                "nome" : nome,
                                                "id" : self.ID]
                                self.completeSignIn(id: user.uid, userData: userData)
                            }
                            self.dismiss(animated: true, completion: nil)
                        }
                    })
                }
            })
        }
    }
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("DOKI: Data saved to keychain \(keychainResult)")
        //performSegue(withIdentifier: "gotoFeed", sender: nil)
    }
    
    @IBAction func voltarPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        self.dismiss(animated: true, completion: nil)
        
        if mediaType.isEqual(to: kUTTypeImage as String) {
            let image = info[UIImagePickerControllerOriginalImage]
                as! UIImage
            
            //self.detect()
            
            imageAdd.image = image
            
            if (newMedia == true) {
                UIImageWriteToSavedPhotosAlbum(image, self,
                                               #selector(CadastroUsuarioVC.image(image:didFinishSavingWithError:contextInfo:)), nil)
            } else if mediaType.isEqual(to: kUTTypeMovie as String) {
                // Code to support video here
            }
            
        }
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo:UnsafeRawPointer) {
        
        if error != nil {
            let alert = UIAlertController(title: "Save Failed",
                                          message: "Failed to save image",
                                          preferredStyle: UIAlertControllerStyle.alert)
            
            let cancelAction = UIAlertAction(title: "OK",
                                             style: .cancel, handler: nil)
            
            alert.addAction(cancelAction)
            self.present(alert, animated: true,
                         completion: nil)
        }
    }
    
    @IBAction func imagePressed(_ sender: Any) {
        //present(imagePicker, animated: true, completion: nil)
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.camera) {
            
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.sourceType =
                UIImagePickerControllerSourceType.camera
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true,
                         completion: nil)
            newMedia = true
        }
    }
    
    func detect() {
        let imageOptions =  NSDictionary(object: NSNumber(value: 5) as NSNumber, forKey: CIDetectorImageOrientation as NSString)
        
        let pic =  imageAdd.image!
        let filter = CIFilter(name: "CISepiaTone")
        filter?.setValue(CIImage(image: pic), forKey: kCIInputImageKey)
        filter?.setValue(0.8, forKey: kCIInputIntensityKey)
        let ctx = CIContext(options:nil)
        let cgImage = ctx.createCGImage(filter!.outputImage!, from:filter!.outputImage!.extent)
        
        let personciImage = cgImage
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
        let faces = faceDetector?.features(in: convertCGImageToCIImage(inputImage: personciImage!))
        
        if let face = faces?.first as? CIFaceFeature {
            print("Achei  \(face.bounds)")
            
            let alert = UIAlertController(title: "Diga X!", message: "Detectei o rosto!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            if face.hasSmile {
                print("Rosto está sorrindo");
            }
            
            if face.hasLeftEyePosition {
                print("Olho esquerdo está \(face.leftEyePosition)")
            }
            
            if face.hasRightEyePosition {
                print("Olho direiro está  \(face.rightEyePosition)")
            }
        } else {
            let alert = UIAlertController(title: "Sem Rosto!", message: "Rosto não detectado", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
    
    func convertCGImageToCIImage(inputImage: CGImage) -> CIImage! {
        var ciImage = CIImage(cgImage: inputImage)
        return ciImage
    }

}
