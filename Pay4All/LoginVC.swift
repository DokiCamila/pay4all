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

class LoginVC: UIViewController {

    @IBOutlet weak var usuarioText: UITextField!
    @IBOutlet weak var senhaText: UITextField!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func entrarBtn(_ sender: UIButton) {
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
}
