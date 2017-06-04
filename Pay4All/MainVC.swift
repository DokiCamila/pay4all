//
//  ViewController.swift
//  Pay4All
//
//  Created by Carlos Doki on 02/06/17.
//  Copyright © 2017 Carlos Doki. All rights reserved.
//

import UIKit

class MainVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func exitPressed(_ sender: Any) {
        exit(0)
    }

    @IBAction func geraQRPressed(_ sender: Any) {
        performSegue(withIdentifier: "GeraQRSegue", sender: nil)
    }
    @IBAction func historicoPressed(_ sender: Any) {
        performSegue(withIdentifier: "HistoricoVCSegue", sender: nil)
    }
}

