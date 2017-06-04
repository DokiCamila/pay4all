//
//  LoginVC.swift
//  Pay4All
//
//  Created by Carlos Doki on 03/06/17.
//  Copyright © 2017 Carlos Doki. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import LocalAuthentication

class LoginVC: UIViewController {

    @IBOutlet weak var usuarioText: UITextField!
    @IBOutlet weak var senhaText: UITextField!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func senhaPressed(_ sender: Any) {
//        // 1. Create a authentication context
//        let authenticationContext = LAContext()
//        
//        var error:NSError?
//        
//        // 2. Check if the device has a fingerprint sensor
//        // If not, show the user an alert view and bail out!
//        guard authenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
//            
//            showAlertViewIfNoBiometricSensorHasBeenDetected()
//            return
//            
//        }
//        
//        // 3. Check the fingerprint
//        authenticationContext.evaluatePolicy(
//            .deviceOwnerAuthenticationWithBiometrics,
//            localizedReason: "Only awesome people are allowed",
//            reply: { [unowned self] (success, error) -> Void in
//                
//                if( success ) {
//                    
//                    // Fingerprint recognized
//                    // Go to view controller
//                    self.navigateToAuthenticatedViewController()
//                    
//                }else {
//                    
//                    // Check if there is an error
//                    if let error = error {
//                        
//                        let message = self.errorMessageForLAErrorCode(errorCode: error as! Int)
//                        self.showAlertViewAfterEvaluatingPolicyWithMessage(message: message)
//                        
//                    }
//                    
//                }
//                
//        })
    }
    
    @IBAction func entrarBtn(_ sender: UIButton) {
//            // 1. Create a authentication context
//            let authenticationContext = LAContext()
//
//            var error:NSError?
//            
//            // 2. Check if the device has a fingerprint sensor
//            // If not, show the user an alert view and bail out!
//            guard authenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
//                
//                showAlertViewIfNoBiometricSensorHasBeenDetected()
//                return
//                
//            }
//            
//            // 3. Check the fingerprint
//            authenticationContext.evaluatePolicy(
//                .deviceOwnerAuthenticationWithBiometrics,
//                localizedReason: "Only awesome people are allowed",
//                reply: { [unowned self] (success, error) -> Void in
//                    
//                    if( success ) {
//                        
//                        // Fingerprint recognized
//                        // Go to view controller
//                        self.navigateToAuthenticatedViewController()
//                        
//                    }else {
//                        
//                        // Check if there is an error
//                        if let error = error {
//                            
//                            let message = self.errorMessageForLAErrorCode(errorCode: error as! Int)
//                            self.showAlertViewAfterEvaluatingPolicyWithMessage(message: message)
//                            
//                        }
//                        
//                    }
//                    
//            })
            

            
        if let email = usuarioText.text, let pwd = senhaText.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if error == nil {
                    print("DOKI: User authenticated with Firebase")
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: {(user, error) in
                        if error != nil {
                            print("DOKI: Unable to authenticated using email - \(error)")
                        } else {
                            print("DOKI: Sucessfully authenticated with Firebase")
                            if let user = user {
                                let userData = ["provider": user.providerID]
                                self.completeSignIn(id: user.uid, userData: userData)
                            }
                        }
                    })
                }
            })
        }
    }
    
    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("DOKI: unable to authentication with Firebase - \(error)")
            } else {
                print("DOKI: Sucessfully authentication with Firebase")
                if let user = user {
                    let userData = [
                        "provider": credential.provider,
                        "username": user.displayName,
                        "photoUrl": user.photoURL?.absoluteString
                    ]
                    self.completeSignIn(id: user.uid, userData: userData as! Dictionary<String, String>)
                }
            }
        })
    }
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        userUUID = id
        print("DOKI: Data saved to keychain \(keychainResult)")
        performSegue(withIdentifier: "EntrarSegue", sender: nil)
    }
    
    
    func showAlertViewIfNoBiometricSensorHasBeenDetected(){
        
        showAlertWithTitle(title: "Error", message: "This device does not have a TouchID sensor.")
        
    }
    
    /**
     This method will present an UIAlertViewController to inform the user that there was a problem with the TouchID sensor.
     
     - parameter error: the error message
     
     */
    func showAlertViewAfterEvaluatingPolicyWithMessage( message:String ){
        
        showAlertWithTitle(title: "Error", message: message)
        
    }
    
    /**
     This method presents an UIAlertViewController to the user.
     
     - parameter title:  The title for the UIAlertViewController.
     - parameter message:The message for the UIAlertViewController.
     
     */
    func showAlertWithTitle( title:String, message:String ) {
        
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertVC.addAction(okAction)
        
        DispatchQueue.main.async() { () -> Void in
            
            self.present(alertVC, animated: true, completion: nil)
            
        }
        
    }
    
    /**
     This method will return an error message string for the provided error code.
     The method check the error code against all cases described in the `LAError` enum.
     If the error code can't be found, a default message is returned.
     
     - parameter errorCode: the error code
     - returns: the error message
     */
    func errorMessageForLAErrorCode( errorCode:Int ) -> String{
        
        var message = ""
        
        switch errorCode {
            
        case LAError.appCancel.rawValue:
            message = "Authentication was cancelled by application"
            
        case LAError.authenticationFailed.rawValue:
            message = "The user failed to provide valid credentials"
            
        case LAError.invalidContext.rawValue:
            message = "The context is invalid"
            
        case LAError.passcodeNotSet.rawValue:
            message = "Passcode is not set on the device"
            
        case LAError.systemCancel.rawValue:
            message = "Authentication was cancelled by the system"
            
        case LAError.touchIDLockout.rawValue:
            message = "Too many failed attempts."
            
        case LAError.touchIDNotAvailable.rawValue:
            message = "TouchID is not available on the device"
            
        case LAError.userCancel.rawValue:
            message = "The user did cancel"
            
        case LAError.userFallback.rawValue:
            message = "The user chose to use the fallback"
            
        default:
            message = "Did not find error code on LAError object"
            
        }
        
        return message
        
    }
    
    /**
     This method will push the authenticated view controller onto the UINavigationController stack
     */
    func navigateToAuthenticatedViewController(){
        
        if let loggedInVC = storyboard?.instantiateViewController(withIdentifier: "EntrarSegue") {
            
            DispatchQueue.main.async() { () -> Void in
                
                self.navigationController?.pushViewController(loggedInVC, animated: true)
                
            }
            
        }
        
    }
}
