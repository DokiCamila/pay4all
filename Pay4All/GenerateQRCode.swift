//
//  GenerateQRCode.swift
//  Pay4All
//
//  Created by Carlos Doki on 03/06/17.
//  Copyright © 2017 Carlos Doki. All rights reserved.
//

import UIKit

class GenerateQRCode: UIViewController {
    var qrcodeImage: CIImage!
    
    @IBOutlet weak var qrtext: UITextField!
    @IBOutlet weak var imaQRCode: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func displayQRcode(_ sender: UIButton) {
        if qrcodeImage == nil {
            if qrtext.text == "" {
                return
            }
            
            let data = qrtext.text!.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
            
            let filter = CIFilter(name: "CIQRCodeGenerator")
            filter!.setValue(data, forKey: "inputMessage")
            filter!.setValue("Q", forKey: "inputCorrectionLevel")
            qrcodeImage = filter!.outputImage
            
            let scaleX = imaQRCode.frame.size.width / qrcodeImage.extent.size.width
            let scaleY = imaQRCode.frame.size.height / qrcodeImage.extent.size.height
            let transformedImage = qrcodeImage.applying(CGAffineTransform(scaleX: scaleX, y: scaleY))
            imaQRCode.image = convert(cmage: transformedImage)
            qrtext.resignFirstResponder()
            //displayQRCodeImage()
        }
        else {
            self.imaQRCode.image = nil
            self.qrcodeImage = nil
        }
    }
    
    func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
}
