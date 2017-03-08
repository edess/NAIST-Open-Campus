//
//  ViewControllerCamera.swift
//  NAIST Open Campus
//
//  Created by Edess Akpa on 10/19/16.
//  Copyright © 2016 Edess Akpa. All rights reserved.
//

import UIKit
import Moscapsule

class ViewControllerCamera: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var pickedImage: UIImageView!
    @IBOutlet weak var sendButton: UIButton!
    
    var imageToSent: UIImage!
    let imagePicker = UIImagePickerController()
    
    var userUniqueID = 0
    var beaconUUID: String = "no UUID"
    var Beac_minor_value = 0
    var Beac_major_value = 0
    var Beac_rssi_value = 0
    
    let debugingText = "[ViewControllerCamera]"
    
    //set MQTT client configuration
    let mqttConfig = MQTTConfig(clientId: "iOS_test_mqtt_camera", host: "sv01.ubi-lab.com", port: 1883, keepAlive: 60)
    
    // create new MQTT Connection
    var mqttClient: MQTTClient? = nil
    
    var appDelegate:AppDelegate!
    
    //NSLocalized string for Localization (English - Japanese)
    let imageSentTitle = NSLocalizedString("cameraViewPage.ImageSentTitle", comment: "")
    let imageSentMsg = NSLocalizedString("cameraViewPage.ImageSentMsg", comment: "")
    
    let imageNotSentTitle = NSLocalizedString("cameraViewPage.ImageNotSentTitle", comment: "")
    let imageNotSentMsg = NSLocalizedString("cameraViewPage.ImageNotSentMessage", comment: "")
    
    let imageAlreadyTookTitle = NSLocalizedString("cameraViewPage.ImageAlreadyTookTitle", comment: "")
    let imageAlreadyTookMsg = NSLocalizedString("cameraViewPage.ImageAlreadyTookMessage", comment: "")


    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        sendButton.isEnabled = false
        DispatchQueue.main.async {
            self.launchCamera()
        }
        
        userUniqueID = UserDefaults.standard.value(forKey: "userUnique_ID") as Any as! Int
        beaconUUID = UserDefaults.standard.value(forKey: "Beac_UUID") as! String!
        Beac_major_value = UserDefaults.standard.value(forKey: "Beac_Maj") as! Int
        Beac_minor_value = UserDefaults.standard.value(forKey: "Beac_Min") as! Int
        Beac_rssi_value = UserDefaults.standard.value(forKey: "Beac_Rssi") as! Int
        
        print("================= Start \(debugingText)  ======================= ")
        print("\(debugingText) userUniqueID = \(userUniqueID) ")
        print("\(debugingText) beaconUUID = \(beaconUUID) ")
        print("\(debugingText) Beac_major_value = \(Beac_major_value) ")
        print("\(debugingText) Beac_minor_value = \(Beac_minor_value) ")
        print("\(debugingText) Beac_rssi_value = \(Beac_rssi_value) ")
        print("================= End \(debugingText)  ======================= ")
        
       
        /*
         * start the MQTT here
         */
        
        // mqtt publish and message callback methods
        
        mqttConfig.onPublishCallback = { messageId in
            print("\(self.debugingText) published (msg id=\(messageId)))")
        }
        
        mqttConfig.onMessageCallback = { mqttMessage in
            print("\(self.debugingText) MQTT Message received: payload=\(mqttMessage.payloadString)")
            let receivedMessage = mqttMessage.payloadString!
            print("\(self.debugingText) from server msg = \(receivedMessage)")
            
            let data = receivedMessage.data(using: .utf8, allowLossyConversion: false)!
            do{
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String : AnyObject]
                
                if let imageSent = json["jsonanswer"]?.value(forKey: "success"){
                    print("\(self.debugingText) image sent? = \(imageSent)")
                    
                    // display an alert of the user to know the image has been sent
                    self.displayMyAlertMessages(self.imageSentTitle, alertMessage: self.imageSentMsg)
                    
                }
                else{
                    print("Image not sent! Try again")
                    self.displayMyAlertMessages(self.imageNotSentTitle, alertMessage: self.imageNotSentMsg)
                }
                
                // get the value of check_in and put it in userDefault --> to be display in the main view (view controller) in Checkpoint label
                if let checkedIn_value = json["jsonanswer"]?.value(forKey: "checked_in"){
                    
                    UserDefaults.standard.set(checkedIn_value, forKey: "checkIn")
                    UserDefaults.standard.synchronize()
                }
                
                //if user already took a picture at this position (beacon range)
                if let step_already_passed = json["jsonanswer"]?.value(forKey: "message"){
                    print("\(self.debugingText) step_already_passed? = \(step_already_passed)")
                    self.displayMyAlertMessages(self.imageAlreadyTookTitle, alertMessage: self.imageAlreadyTookMsg)
                }
                
                // get the array of spot of photo already took
                if let arrayOfPhotoTook = json["jsonanswer"]?.value(forKey: "photo_already_taken"){
                    print("\(self.debugingText) arrayOfPhotoTook = \(arrayOfPhotoTook) ")
                    
                    // convert the response to NSArray and save it to NSUserdefault value
                    let arrayOfPhotoTookEdess: NSArray = arrayOfPhotoTook as! NSArray
                    print("\(self.debugingText) arrayOfPhotoTooki = \(arrayOfPhotoTookEdess)")
                    print("\(self.debugingText) arrayOfPhotoTooki[1] = \(arrayOfPhotoTookEdess[1])")
                    
                    UserDefaults.standard.set(arrayOfPhotoTookEdess, forKey: "arrayPhotoTaken")
                    UserDefaults.standard.synchronize()
                }
                
                // get the user new points values (updates points --> remaining points) and update NSUserdefault
                if let remainingPoints = json["jsonanswer"]?.value(forKey: "remainingpoint"){
                    
                    let userRemainingPts : Int = (remainingPoints as! NSString).integerValue
                    UserDefaults.standard.set(userRemainingPts, forKey: "user_points")
                    UserDefaults.standard.synchronize()
                }
                
            }
            catch let error as NSError {
                print("\(self.debugingText) Error \(error.localizedDescription)")
            }
        }
        
        mqttClient = MQTT.newConnection(mqttConfig)
        
        // subscribe to the s/18/cp/master/user_id --> to receive msg of image upload with success or fail
        mqttClient?.subscribe("s/19/cp/\(userUniqueID)", qos: 0)
        
        //subscribe to openCampus?checkin ---> for Gachaserver
        mqttClient?.subscribe("beaconcheck/user/\(userUniqueID)", qos: 0)
        
    }
    
    func launchCamera() {
        // open the camera automatically when the view appear
        if UIImagePickerController.isCameraDeviceAvailable( UIImagePickerControllerCameraDevice.rear){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     //camera button
    @IBAction func cameraButtonPushed(_ sender: UIButton) {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImageA = info[UIImagePickerControllerOriginalImage] as? UIImage{
            pickedImage.contentMode = .scaleAspectFit
            pickedImage.image = pickedImageA
            imageToSent = pickedImageA
        }
        self.dismiss(animated: true, completion: nil)
        sendButton.isEnabled = true
    }
    
    // cancel button
    @IBAction func cancelButtonPushed(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let aViewCont = storyboard.instantiateViewController(withIdentifier: "mainPage_ID") // the login beacon view controller ID
        self.present(aViewCont, animated: true, completion: nil) 
    }
    
    
    @IBAction func SendButtonPushed(_ sender: AnyObject) {
        print("send button pushed")
        
        let jpegCompressionQuality: CGFloat = 0.5 // Set this to whatever suits your purpose
        if let base64StringImage = UIImageJPEGRepresentation(imageToSent, jpegCompressionQuality)?.base64EncodedString() {
            // Upload base64String to your database
            
            let dataToSend: String = "{\"i\": \(userUniqueID), \"m\": 1234567,\"p\":\"\(base64StringImage)\",\"c\": \"image from an iOS phone\",\"b\": {\"u\": \"\(beaconUUID)\",\"a\": \(Beac_major_value),\"i\" : \(Beac_minor_value),\"r\" : \(Beac_rssi_value)}, \"s\": {\"a\": {\"x\": 0.0, \"y\": 0.0 , \"z\": 0.0},\"g\" : {\"x\": 0.0, \"y\": 0.0 , \"z\": 0.0},\"m\" : {\"x\": 0.0, \"y\": 0.0 , \"z\": 0.0},\"o\" : {\"a\": 0.0, \"p\": 0.0 , \"r\": 0.0},\"l\" : 0.0},\"l\" : {\"a\" : 0.0,\"t\" : 0.0,\"g\" : 0.0}}"
            
            
             let dataToSendToOpenCampus: String = "{\"i\": \(userUniqueID), \"m\": 1234567,\"p\":\"Elder\",\"c\": \"image from an iOS phone\",\"b\": {\"u\": \"\(beaconUUID)\",\"a\": \(Beac_major_value),\"i\" : \(Beac_minor_value),\"r\" : \(Beac_rssi_value)}, \"s\": {\"a\": {\"x\": 0.0, \"y\": 0.0 , \"z\": 0.0},\"g\" : {\"x\": 0.0, \"y\": 0.0 , \"z\": 0.0},\"m\" : {\"x\": 0.0, \"y\": 0.0 , \"z\": 0.0},\"o\" : {\"a\": 0.0, \"p\": 0.0 , \"r\": 0.0},\"l\" : 0.0},\"l\" : {\"a\" : 0.0,\"t\" : 0.0,\"g\" : 0.0}}"
            
            
            mqttClient?.publish(string: dataToSend, topic: "p/19/cp", qos: 0, retain: false)
            mqttClient?.publish(string: dataToSendToOpenCampus, topic: "opencampus/checkin", qos: 0, retain: false)
            
        }
        
    }
    
    
    // function for displaying the alert messages
    func displayMyAlertMessages(_ alertTitle:String, alertMessage:String){
        
        let myAlertView = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
       
        if (alertTitle == imageSentTitle){
            
            myAlertView.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction!) in
                print("Image sent / user ack")
                
                self.mqttClient?.disconnect()
                
                self.performSegue(withIdentifier: "ID_segueCameraToMain", sender: self)
                
                //return
            }))
            
        }
        
        
        
        if (alertTitle == imageNotSentTitle){
            
            myAlertView.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction!) in
                print("Image not sent / user ack")
                return
            }))
            
        }
        
        if (alertTitle == imageAlreadyTookTitle){
            
            myAlertView.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction!) in
                print("User has already taken this image")
                return
            }))
            
        }
        
        
        
        present(myAlertView, animated: true, completion: nil)
        
    }
    
}
