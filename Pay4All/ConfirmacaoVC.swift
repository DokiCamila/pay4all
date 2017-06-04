//
//  ConfirmacaoVC.swift
//  Pay4All
//
//  Created by Carlos Doki on 04/06/17.
//  Copyright © 2017 Carlos Doki. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import Firebase

class ConfirmacaoVC: UIViewController, CLLocationManagerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var valor : String!
    var contrato = [Contrato]()
    var carteira = [PostCarteira]()
    let locationManger = CLLocationManager()
    var pickOption = [""]
    var ID = ""
    var lat = 0.0
    var lon = 0.0
    var strIDFV  = ""
    var contratoid  = ""
    var vendedor = ""
    
    @IBOutlet weak var valorLbl: UILabel!
    @IBOutlet weak var pickerText: UIPickerView!
    @IBOutlet weak var carteiraField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        locationManger.requestWhenInUseAuthorization()
        locationManger.startMonitoringSignificantLocationChanges()
        
        // Do any additional setup after loading the view.
        var myStringArr = valor.components(separatedBy: ";")
        
        self.valorLbl.text = myStringArr[0]
        lat = Double(myStringArr[1].replacingOccurrences(of: "lat=", with: ""))!
        lon = Double(myStringArr[2].replacingOccurrences(of: "lon=", with: ""))!
        strIDFV = myStringArr[3].replacingOccurrences(of: "IDFV=", with: "")
        contratoid = myStringArr[4].replacingOccurrences(of: "contrato=", with: "")
        vendedor = myStringArr[5].replacingOccurrences(of: "vendedor=", with: "")
        pickOption.removeAll()
        DataService.ds.REF_CARTEIRA.observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    print("DOKI: \(snap)")
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let cont = PostCarteira(postKey: key, postData: postDict)
                        self.pickOption.append(cont.nome)
                    }
                }
            }
        })
        
        // Do any additional setup after loading the view.
        let pickerView = UIPickerView()
        
        pickerView.delegate = self
        pickerView.reloadAllComponents()
        
        carteiraField.inputView = pickerView
        
        //          let textocompleto = qrtext.text! + ";lat=\(Location.sharedInstance.latitude!);lon=\(Location.sharedInstance.longitude!);IDFV=\(strIDFV);contrato=\(contrato);vendedor=\(vendedor)"
        
        //        DataService.ds.REF_CONTRATO.observe(.value, with: { (snapshot) in
        //            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
        //                for snap in snapshot {
        //                    print("DOKI: \(snap)")
        //                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
        //                        let key = snap.key
        //                        let cont = Contrato(postKey: key, postData: postDict)
        //                        self.contrato.append(cont)
        //                    }
        //                }
        //            }
        //        })
        
        let coordinate = CLLocation(latitude: lat, longitude: lon)
        let coordinate1 = CLLocation(latitude: (locationManger.location?.coordinate.latitude)!, longitude: (locationManger.location?.coordinate.longitude)!)
        
        let distanceInMeters = coordinate.distance(from: coordinate1) // result is in meters
        if (distanceInMeters >= 1000) {
            let refreshAlert = UIAlertController(title: "Alerta", message: "Vendedor está a mais de 1km, confirma a compra?", preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Sim", style: .default, handler: { (action: UIAlertAction!) in
                print("Handle Ok logic here")
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "Não", style: .cancel, handler: { (action: UIAlertAction!) in
                return
            }))
            
            present(refreshAlert, animated: true, completion: nil)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationAuthStatus()
    }
    
    func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManger.requestWhenInUseAuthorization()
            locationAuthStatus()
        }
    }
    
    @IBAction func confirmarPressed(_ sender: UIButton) {
        let randomNum:UInt32 = arc4random_uniform(10000) // range is 0 to 99999
        ID = String(format: "%05d", randomNum) //string works too
        ID = ID + String(round(Date().timeIntervalSince1970))
        let data = round(Date().timeIntervalSince1970)
        
        let posttransacao : Dictionary<String, AnyObject> = [
            "carteira": carteiraField.text as AnyObject,
            "data": data as AnyObject,
            "idContrato": contratoid as AnyObject,
            "latitude": lat as AnyObject,
            "longitude": lon as AnyObject,
            "user": userUUID as AnyObject,
            "valor": self.valorLbl.text as AnyObject,
            "vedendor" : vendedor as AnyObject,
            "hashBlockChain": "" as AnyObject
            ]
        let firebasePost = DataService.ds.REF_TRANSACAO.childByAutoId()
        firebasePost.setValue(posttransacao)

        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReciboVC") as! ReciboVC
        controller.valor = self.valorLbl.text
        controller.data = data
        controller.id = ID
        controller.carteira = carteiraField.text
        self.present(controller, animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickOption.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickOption[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        carteiraField.text = pickOption[row]
    }
}
