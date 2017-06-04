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

class ConfirmacaoVC: UIViewController, CLLocationManagerDelegate {
    
    var valor : String!
    var contrato = [Contrato]()
    let locationManger = CLLocationManager()
    
    @IBOutlet weak var valorLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        locationManger.requestWhenInUseAuthorization()
        locationManger.startMonitoringSignificantLocationChanges()
        
        // Do any additional setup after loading the view.
        var myStringArr = valor.components(separatedBy: ";")
        
        self.valorLbl.text = myStringArr[0]
        let lat = Double(myStringArr[1].replacingOccurrences(of: "lat=", with: ""))
        let lon = Double(myStringArr[2].replacingOccurrences(of: "lon=", with: ""))
        let strIDFV = myStringArr[3].replacingOccurrences(of: "IDFV=", with: "")
        let contrato = myStringArr[4].replacingOccurrences(of: "contrato=", with: "")
        let vendedor = myStringArr[5].replacingOccurrences(of: "vendedor=", with: "")
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
        
        let coordinate = CLLocation(latitude: lat!, longitude: lon!)
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
    
    
}
