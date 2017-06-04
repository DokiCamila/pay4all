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

class CadastroUsuarioVC: UIViewController {
    
    @IBOutlet weak var nomeField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var confirmarEmailField: UITextField!
    @IBOutlet weak var dddField: UITextField!
    @IBOutlet weak var celularField: UITextField!
    @IBOutlet weak var senhaField: UITextField!
    @IBOutlet weak var confirmarSenhaField: UITextField!
    var ID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.

        //  Make a variable equal to a random number....
        
        let randomNum:UInt32 = arc4random_uniform(10000) // range is 0 to 99999
        
        // convert the UInt32 to some other  types
        
        ID = String(format: "%05d", randomNum) //string works too
        ID = ID + String(round(Date().timeIntervalSince1970))
        
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
    
}
