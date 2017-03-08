//
//  ViewControllerQRcode.swift
//  NAIST Open Campus
//
//  Created by Edess Akpa on 10/28/16.
//  Copyright © 2016 Edess Akpa. All rights reserved.
//

import UIKit
import CoreImage

class ViewControllerQRcode: UIViewController {
    
    @IBOutlet weak var lblRandomKey: UILabel!
    
    @IBOutlet weak var IV_qrCodeView: UIImageView!
    
    var qrcodeImage: CIImage!
    @IBOutlet weak var btnBack: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let randomKey = UserDefaults.standard.value(forKey: "Random_Key") as! String
        print("[ViewControllerQRcode] randKey= \(randomKey)")
        
        
        assignbackground()
        
        DispatchQueue.main.async {
            
        self.lblRandomKey.text = "Random key = \(randomKey)"
            self.lblRandomKey.isHidden = true 
          self.qrcodeImage = self.createQRFromString(str: randomKey)
          self.displayQRCodeImage()
            self.btnBack.backgroundColor = UIColor.blue
            self.btnBack.setTitleColor(UIColor.white, for: .normal)
            self.btnBack.setTitle("Back", for: .normal)
        }
        
    }
    
    
    func createQRFromString(str: String) -> CIImage? {
        
        //let stringData = str.data(using: String.Encoding.utf8)
        
        let stringData = str.data(using: .isoLatin1, allowLossyConversion: false)
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        
        filter?.setValue(stringData, forKey: "inputMessage")
        
        filter?.setValue("Q", forKey: "inputCorrectionLevel")
        
        return filter?.outputImage
    }
    
    
    // function to unblur the qr generated image
    func displayQRCodeImage() {
        let scaleX = IV_qrCodeView.frame.size.width / qrcodeImage.extent.size.width
        let scaleY = IV_qrCodeView.frame.size.height / qrcodeImage.extent.size.height
        
        let transformedImage = qrcodeImage.applying(CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        IV_qrCodeView.image = UIImage(ciImage: transformedImage)
    }
    
    
    @IBAction func btnBackPressed(_ sender: UIButton) {
        
        //clear the value of random key when the user presses the back
        // button. this help avoid using the same random key twice
        UserDefaults.standard.set("0000", forKey: "Random_Key")
        UserDefaults.standard.synchronize()
        
        // send user back to the main viewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let aViewCont = storyboard.instantiateViewController(withIdentifier: "mainPage_ID") // the login beacon view controller ID
        self.present(aViewCont, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // for the background image to scale the image
    func assignbackground(){
        let background = UIImage(named: "naist_front.jpg")
        
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIViewContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubview(toBack: imageView)
    }
  
}
