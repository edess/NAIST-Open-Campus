//
//  ViewController.swift
//  NAIST Open Campus
//
//  Created by Edess Akpa on 10/19/16.
//  Copyright © 2016 Edess Akpa. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
//import SwiftMQTT
//import CocoaMQTT
import Moscapsule
import GoogleMaps


class ViewController: UIViewController, CLLocationManagerDelegate,MKMapViewDelegate{ //, CocoaMQTTDelegate ,MQTTSessionDelegate {
    
    //UI widgets
    @IBOutlet weak var lblUUID: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    //@IBOutlet weak var lblMqttMessage: UILabel!
    @IBOutlet weak var lblCheckPoint: UILabel!
    @IBOutlet weak var lblExtraMissionInfo: UILabel!
    @IBOutlet weak var lblUserPoints: UILabel!
    
    @IBOutlet weak var myDetailsInfoView: UIView!
    @IBOutlet weak var CameraButtonSubView: UIView!
    //@IBOutlet weak var TutorailInfoSubView: UIView!
    
    @IBOutlet weak var qRcodeButton: UIButton!
    
    //@IBOutlet weak var lblUbiChanMessage: UILabel!
    
    //@IBOutlet weak var myMapView: MKMapView!
    
    
    
    @IBOutlet weak var lblUserName: UILabel!
    
    @IBOutlet weak var myGoogleMapView: GMSMapView!
    
    //variables
    let locationManager = CLLocationManager()
    
//    let UUIDList = [
//        "e20a39f4-73f5-4bc4-a12f-17d1ad07a961",
//        "bdbd64d3-d44f-4f03-b66a-55faa3b17f84",
//        "d0d3fa86-ca76-45ec-9bd9-6af45fe2f63d"
//    ]
    
    let UUIDList = [
        "d0d3fa86-ca76-45ec-9bd9-6af44b489a9d",
        "d0d3fa86-ca76-45ec-9bd9-6af4fc7f8095",
        "d0d3fa86-ca76-45ec-9bd9-6af45e2104b5",
        "d0d3fa86-ca76-45ec-9bd9-6af4ebeb756a",
        "d0d3fa86-ca76-45ec-9bd9-6af47bceb04f",
        "d0d3fa86-ca76-45ec-9bd9-6af45fe2f63d",
        "d0d3fa86-ca76-45ec-9bd9-6af469ad0b1e"
    ]
    
    
    //NSLocalized string for Localization (English - Japanese)
    let warningTitle = NSLocalizedString("mainViewPage.logoutWarningTitle", comment: "")
    let warningMess = NSLocalizedString("mainViewPage.logoutWarningMessage", comment: "")
    let warningActionYes = NSLocalizedString("mainViewPage.logoutWarningActionYes", comment: "")
    let warningActionNo = NSLocalizedString("mainViewPage.logoutWarningActionNO", comment: "")
    
    let cameraToBeaconPosTitle = NSLocalizedString("mainViewPage.cameraUserPositionTitle", comment: "")
    let cameraToBeaconPosMessg = NSLocalizedString("mainViewPage.cameraUserPositionMessage", comment: "")
    
    
    
    
    
    
    
    let debugingText = "[ViewControllerMain]"
    
    var myBeaconRegion:CLBeaconRegion!
    var beaconRegionArray = [CLBeaconRegion]()
    
    var myUserUniqueID = 0
    var abcd = 0
    var theReceiveMsg: String?
    var myUserCurrentPoints: Int? = 0
    
    var reponseSuccesFromQrRequest = 0
    var proximity = ""
    var beaconHasBeenDetected = false
    
    // variables to save the beacons parameters
    var beaconUUID: UUID!
    var minorID = 0
    var majorID = 0
    var rssi = 0
    
    var positionMarkerSeven: CLLocationCoordinate2D!
    
    
    
    
    //set MQTT client configuration
    let mqttConfig = MQTTConfig(clientId: "iOS_test_mqtt", host: "sv01.ubi-lab.com", port: 1883, keepAlive: 60)
    
    // create new MQTT Connection
    var mqttClient: MQTTClient? = nil
    
    var appDelegate:AppDelegate!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // give an initial value to UseruniqueID (require for first run of the app)
        let isUserLoggedIn = UserDefaults.standard.bool(forKey: "isUserLoggedIn")
        
        if(!isUserLoggedIn){
            
            UserDefaults.standard.set("", forKey: "userUnique_ID")
            UserDefaults.standard.set(0, forKey: "checkIn")// set checkin value to 0 when user is not when register
            UserDefaults.standard.set([0,0,0,0,0,0,0], forKey: "arrayPhotoTaken")
            UserDefaults.standard.synchronize()
        }else
        {
            //myUserUniqueID = UserDefaults.standard.value(forKey: "userUnique_ID")
             myUserUniqueID = UserDefaults.standard.value(forKey: "userUnique_ID") as Any as! Int
            print("[Debbbuuuuuug] userId from default memory = \(myUserUniqueID)")
            
            // get username
            let hisName = UserDefaults.standard.value(forKey: "user_name") as! String?
            lblUserName.text = "Hi, \(hisName!)"
            
            //get user points (Int)
            myUserCurrentPoints = UserDefaults.standard.value(forKey: "user_points") as! Int!
            //myUserCurrentPoints = 201
            
            print("=== userCurrentPointsString \(myUserCurrentPoints!)")
            
            // assign the points value to the UILabel 
            lblUserPoints.text = "\(myUserCurrentPoints!)"
            
            if myUserCurrentPoints! < 200 {
                
                qRcodeButton.isHidden = true
            }
            
            
            

        }
        
        // check the number of checkpoints, if >= 4 display extra mission message with 
        // animation
        
        //let numbCheckPoints = Int(lblCheckPoint.text!)
        let numbCheckPoints = UserDefaults.standard.value(forKey: "checkIn")
        print("numbCheckPoints = \(numbCheckPoints!)")
        lblCheckPoint.text = "\(numbCheckPoints!)"
        
        
        let totalCheck_points = Int(lblCheckPoint.text!)
         //let totalCheck_points = 6 // for testing
        if totalCheck_points  == 6 {
            //lblUbiChanMessage.text = "Extra mission:\n Go close to the Basket ball court"
            lblExtraMissionInfo.isHidden = false
            lblExtraMissionInfo.blink()
            
            
            positionMarkerSeven = CLLocationCoordinate2DMake(34.732461, 135.732741) // Extra  (position )
            let markerSeven = GMSMarker(position: positionMarkerSeven)
            markerSeven.title = "Extra"
            markerSeven.icon = UIImage(named: "marker_master")
            markerSeven.map = myGoogleMapView
            
            UserDefaults.standard.set(true, forKey: "extraMissionActivation") // extra missionActivate to false
            UserDefaults.standard.synchronize()
            
            
        }
        else if totalCheck_points == 7{
            
            // show the QR code and change the icon of the marker
            qRcodeButton.isHidden = false
            
            positionMarkerSeven = CLLocationCoordinate2DMake(34.732461, 135.732741) // Extra  (position )
            let markerSeven = GMSMarker(position: positionMarkerSeven)
            markerSeven.title = "Extra"
            markerSeven.icon = UIImage(named: "marker_ok")
            markerSeven.map = myGoogleMapView
            
            //no more extra mission
            lblExtraMissionInfo.isHidden = true
            
        }
            
        else{
            lblExtraMissionInfo.isHidden = true
        }
        
        

        
        
        //bring the details info view on the top of the map
        // and change the background color opacity of the subview
        self.view.insertSubview(myDetailsInfoView, aboveSubview: myGoogleMapView)
        self.view.insertSubview(CameraButtonSubView, aboveSubview: myGoogleMapView)
        
        CameraButtonSubView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        myDetailsInfoView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        // map authorization
        locationManager.delegate = self
        
        if(CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse){
            
            locationManager.requestWhenInUseAuthorization()
        }
        
        // add markers to the map
        let positionMarkerOne = CLLocationCoordinate2DMake(34.731688, 135.734589) // IS
        let positionMarkerTwo = CLLocationCoordinate2DMake(34.731319, 135.732590) //BS
        let positionMarkerThree = CLLocationCoordinate2DMake(34.730691, 135.733690) //MS-1
        let positionMarkerFour = CLLocationCoordinate2DMake(34.730790, 135.734213) // MS-2
        let positionMarkerFive = CLLocationCoordinate2DMake(34.732277, 135.733418) // Millenium
        let positionMarkerSix = CLLocationCoordinate2DMake(34.731500, 135.733261) // Reception
        
        
        
        let markerOne = GMSMarker(position: positionMarkerOne)
        let markerTwo = GMSMarker(position: positionMarkerTwo)
        let markerThree = GMSMarker(position: positionMarkerThree)
        let markerFour = GMSMarker(position: positionMarkerFour)
        let markerFive = GMSMarker(position: positionMarkerFive)
        let markerSix = GMSMarker(position: positionMarkerSix)
        
        
        markerOne.title = "Info Science"
        markerTwo.title = "Bio Science"
        markerThree.title = "Mat. Science 1"
        markerFour.title = "Mat. Science 2"
        markerFive.title = "Millenium Hall"
        markerSix.title = "Reception"
        
        
        // check image value of the array and change the marker icon accordingly
        let alreadyTakenPhotoArray = UserDefaults.standard.array(forKey: "arrayPhotoTaken") as? [Int] ?? [Int]()
        print("\(debugingText) alreadyTakenPhotoArray = \(alreadyTakenPhotoArray) ")
        
        if alreadyTakenPhotoArray[0] == 0 {
            markerOne.icon = UIImage(named: "marker_master")
        }else{
            markerOne.icon = UIImage(named: "marker_ok")
            
        }
        if alreadyTakenPhotoArray[1] == 0 {
            print("\(debugingText) alreadyTakenPhotoArray[1] = \(alreadyTakenPhotoArray[1]) ")
           markerTwo.icon = UIImage(named: "marker_master")
        }else{
            
             markerTwo.icon = UIImage(named: "marker_ok")
            
        }
        if alreadyTakenPhotoArray[2] == 0 {
            markerThree.icon = UIImage(named: "marker_master")
        }else{
            markerThree.icon = UIImage(named: "marker_ok")
            
        }
        if alreadyTakenPhotoArray[3] == 0 {
            markerFour.icon = UIImage(named: "marker_master")
        }else{
            markerFour.icon = UIImage(named: "marker_ok")
            
        }
        if alreadyTakenPhotoArray[4] == 0 {
            markerFive.icon = UIImage(named: "marker_master")
        }else{
            markerFive.icon = UIImage(named: "marker_ok")
            
        }
        if alreadyTakenPhotoArray[5] == 0 {
            markerSix.icon = UIImage(named: "marker_master")
        }else{
            markerSix.icon = UIImage(named: "marker_ok")
            
        }
//        if alreadyTakenPhotoArray[6] == 0 {
//            markerSeven.icon = UIImage(named: "marker_master")
//        }else{
//            markerSeven.icon = UIImage(named: "marker_ok")
//            
//        }
        
        
      
        
        markerOne.map = myGoogleMapView
        markerTwo.map = myGoogleMapView
        markerThree.map = myGoogleMapView
        markerFour.map = myGoogleMapView
        markerFive.map = myGoogleMapView
        markerSix.map = myGoogleMapView
        
        
        //self.view.addSubview(btnFindStickers)
        
        
       
        
        
        
        
        //etablishement of connections to the UUID
        for i in 0 ..< UUIDList.count {
            
            let uuid:UUID! = UUID(uuidString:UUIDList[i])
            let identifierStr:String = "Floor #" + i.description
            
            //creation of regions
            myBeaconRegion = CLBeaconRegion(proximityUUID: uuid as UUID, identifier : identifierStr)
            
            beaconRegionArray.append(myBeaconRegion)
            locationManager.startRangingBeacons(in: myBeaconRegion)
        }
        
        // an identifier number to identy the subview and use it later
        //TutorailInfoSubView.tag = 100
        
        
        
        
        /*
         * start the MQTT Subscription and publish here
         */
       
        mqttConfig.onPublishCallback = { messageId in
            print("published (msg id=\(messageId)))")
        }
        
        
        mqttConfig.onMessageCallback = { mqttMessage in
            print("MQTT Message received: payload=\(mqttMessage.payloadString)")
            let receivedMessage = mqttMessage.payloadString!
            print("from server msg = \(receivedMessage)")
            
            //self.theReceiveMsg = receivedMessage
            
            let data = receivedMessage.data(using: .utf8, allowLossyConversion: false)!
            print("xxxxxxx = \(data)")
            do{
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String : AnyObject]
                
                /*
                 * catch and analyse the contents of the received messages from the differents request
                 */
                
                
                // message received from the qrCode creation request
                if let randomKey = json["jsonanswer"]?.value(forKey: "randomkey"){
                print("the random key is = \(randomKey)")
                
                let Rd_key = randomKey // to force unwrap
                print("Keyyy \(Rd_key)")
                
                let successAnswerValue = json["jsonanswer"]?.value(forKey: "success")
                print("successAnswerValue = \(successAnswerValue)")
                
                
                
                // save value of random key in app 
                //internal memory (userDefaults)
                UserDefaults.standard.set(Rd_key, forKey: "Random_Key")
                UserDefaults.standard.synchronize()
                    
                    
                
                // check that random_key is not = "0000", if not go to qrCodeGenerator view
                let key = UserDefaults.standard.value(forKey: "Random_Key") as! String
                
                if key != "0000" {
                    
                    //mqttt disconnect here
                    self.mqttClient?.disconnect()
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let aViewCont = storyboard.instantiateViewController(withIdentifier: "qrGeneratoView_ID") as UIViewController // the ID of the qr generator key
                    self.present(aViewCont, animated: true, completion: nil)
                    

                }
                else {
                    print("QR code Server not ready / available")
                }
            }
                
                // message received from the beaconlog and point earning request (when the user pass in a beacon region)
                if let userID = json["jsonanswer"]?.value(forKey: "userid"){
                    print("userID = \(userID) *****************************")
                }
                
            }
            catch let error as NSError{
                print("Failed to load: \(error.localizedDescription)")
            }
            
            
//            DispatchQueue.main.async {
//                self.lblMqttMessage.text = receivedMessage
//            }
        }
        
        //mqttClient = MQTT.newConnection(mqttConfig)
        mqttClient = MQTT.newConnection(mqttConfig, connectImmediately: true)
        //mqttClient2 = MQTT.newConnection(mqttConfig, connectImmediately: true)
        
        
        
        
        /*
           subscribe to the different topics
         we need to retrieve the user unique ID first
         */
       
        if (myUserUniqueID != 0){
            //subscribe to the topic opencampus/getQRcode ---> to get response to qr creation request
            print("the user unique ID is not nil")
            mqttClient?.subscribe("opencampus/getqr/\(myUserUniqueID)", qos: 0)
            
            //subscribe to the topic opencampus/getqr/confirm/$useruniqueid$ ---> to get response to qr usage request
            // this subscription should be done also in the ViewControllerQRcode
            mqttClient?.subscribe("opencampus/getqr/confirm/\(myUserUniqueID)", qos: 0)
            
            
            //subscribe to the topic beaconcheck/user/$useruniqueid$ ---> to get notification whenever he receive point or pass a step
            //mqttClient?.subscribe("beaconcheck/user/\(myUserUniqueID)", qos: 0)
            
            //subscribe to the topic globalranking/list ---> // to get the raking every 30seconds
            //mqttClient?.subscribe("globalranking/list", qos: 0)

            
            //Initialization to parmo server
            print("Initialization to parmo server =============================")
            //mqttClient?.subscribe("p/19/sys", qos: 0)
            mqttClient?.publish(string: "{\"r\": 0, \"i\": \(myUserUniqueID), \"s\": \"paul\"}", topic: "p/19/sys", qos: 0, retain: false)
            print("Initialization to parmo server finished =============================")

            
            
            //mqttClient?.publish(string: "{\"uniqueid\": \"\(myUserUniqueID)\"}", topic: "opencampus/generateqr", qos: 0, retain: false)
        }
        
    }
    
  
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        let isUserLoggedIn = UserDefaults.standard.bool(forKey: "isUserLoggedIn")
        
        if(!isUserLoggedIn){
            
            //self.performSegue(withIdentifier: "ID_segueToRegistration", sender: self)
            qRcodeButton.isHidden = true
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // pressed on the button unregister
    @IBAction func UnregisterButtonPressed(_ sender: UIButton) {
       
        displayMyAlertMessages(warningTitle, alertMessage: warningMess)

    }
    
    
    @IBAction func btnGenerateQRCodePressed(_ sender: UIButton) {
        // publish the user unique ID when user click the button
        
        
        print("###### unique id = \(myUserUniqueID)")
        mqttClient?.publish(string: "{\"uniqueid\": \"\(myUserUniqueID)\"}", topic: "opencampus/generateqr", qos: 0, retain: false)
        
        
    }
    
    
    // function for displaying the alert messages
    func displayMyAlertMessages(_ alertTitle:String, alertMessage:String){
        
        let myAlertView = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        if (alertTitle == warningTitle){
            
            myAlertView.addAction(UIAlertAction(title: warningActionYes, style: .default, handler: { (action: UIAlertAction!) in
                print("alert message:Yes, delete my account")
                UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
                UserDefaults.standard.synchronize()
                
                self.performSegue(withIdentifier: "ID_segueToRegistration", sender: self)
                
            }))
            
            myAlertView.addAction(UIAlertAction(title: warningActionNo, style: .default, handler: { (action: UIAlertAction!) in
                print("alert message: NO, do not delete my account")
                
            }))
        }
        
        if (alertTitle == cameraToBeaconPosTitle){
            
            myAlertView.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction!) in
                print("user is going close to Ubi-chan")
                return
            }))
            
        }
        
        if (alertTitle == "Registration required"){
            
            myAlertView.addAction(UIAlertAction(title: "Go to Registration", style: .default, handler: { (action: UIAlertAction) in
                self.performSegue(withIdentifier: "ID_segueToRegistration", sender: self)
            }))
            
            myAlertView.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
                print("")
                return
                
            }))
        
        }
        
        
        
        present(myAlertView, animated: true, completion: nil)
        
    }
    
    
    // fonction to handle beacon information when the phone enter in its range (region) 
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        //print(beacons)
        
        if(beacons.count > 0){
            
            beaconHasBeenDetected = true
            
            for i in 0 ..< beacons.count{
                let myBeacon = beacons[i]
                
                 beaconUUID = myBeacon.proximityUUID
                 minorID = Int(myBeacon.minor)
                 majorID = Int(myBeacon.major)
                 rssi = myBeacon.rssi
                //let accuracy = String(format: "%.02f", myBeacon.accuracy) // string format used to rounded the too much long value of the myBeacon.accuracy
                
                // once user get in the beacon region, use mqtt and publish the beacon ID and userUnique ID
                //mqttClient?.publish(string: "{\"beaconid\": \"\(beaconUUID)\", \"useruniqid\": \"\(myUserUniqueID)\"}", topic: "beaconcheck/server", qos: 0, retain: false)
                
                
                //get how far/close is the beacon
                
                switch (myBeacon.proximity) {
                case CLProximity.far:
                    proximity = "Far"
                    break
                    
                case CLProximity.near:
                    proximity = "Near"
                    break
                    
                case CLProximity.immediate:
                    proximity = "Immediate"
                    break
                default:
                    proximity = "Unknown"
                }
                
                //get the location (1st, 2nd, 3rd floor) of the beacon. each floor has a unique ID beacon
                
                var floorNum=""
                switch beaconUUID.uuidString.lowercased() {
                case "d0d3fa86-ca76-45ec-9bd9-6af44b489a9d":
                    floorNum = "IS Bulding"
                    break
                    
                case "d0d3fa86-ca76-45ec-9bd9-6af4fc7f8095":
                    floorNum = "BS Building"
                    break
                    
                case "d0d3fa86-ca76-45ec-9bd9-6af45e2104b5":
                    floorNum = "MS-1 Building"
                    break
                    
                case "d0d3fa86-ca76-45ec-9bd9-6af4ebeb756a":
                    floorNum = "MS-2 Building"
                    break
                    
                case "d0d3fa86-ca76-45ec-9bd9-6af47bceb04f":
                    floorNum = "Millenium Hall"
                    break
                    
                case "d0d3fa86-ca76-45ec-9bd9-6af45fe2f63d":
                    floorNum = "Reception Desk"
                    break
                    
                case "d0d3fa86-ca76-45ec-9bd9-6af469ad0b1e":
                    floorNum = "Extra"
                    break
                default:
                    floorNum = "area undefined"
                }
                
                
                
              //  print("UUID: \(beaconUUID.uuidString)");
//                print("location: \(floorNum)")
                   // print("minorID: \(minorID)");
                  //  print("majorID: \(majorID)");
                   // print("RSSI: \(rssi) dBm");
                    //print("Proximity: \(proximity)")
//                print("Accuracy: \(accuracy)")
                //print("***************")
//                
                // display the data on user screen using text label
                
                //lblRssi.text = "\(rssi) dBm"
                
                lblLocation.text = floorNum
                lblUUID.text = "\(beaconUUID.uuidString)"
                //lblBeaconProximity.text = proximity
                
               // lblDistance.text = proximity
               // lblUuid.adjustsFontSizeToFitWidth = true
               //lblMajor.text = "\(majorID)"
               // lblMinor.text = "\(minorID)"
               // lblAccuracy.text = "\(accuracy)"
            }
            
        }
    }
    
    //locationManager(_:didChangeAuthorizationStatus:) is called when the user grants or revokes location permissions.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse{
            locationManager.startUpdatingLocation()
            
            // myLocationEnabled draws a light blue dot where the user is located, while myLocationButton, 
            //when set to true, adds a button to the map that, when tapped, centers the map on the user’s location.
            myGoogleMapView.isMyLocationEnabled = true
            //myGoogleMapView.settings.myLocationButton = true
        }
    }
    
    // locationManager(_:didUpdateLocations:) executes when the location manager receives new location data.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
           // This updates the map’s camera to center around the user’s current location.
            myGoogleMapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 17, bearing: 0, viewingAngle: 45)
            locationManager.stopUpdatingLocation()
        }
    }
    
    
    
    // manage the camera button
    
    @IBAction func btnCameraPushed(_ sender: UIButton) {
        
        // when user clicl on button camera, check first his position relative to the beacons
        // if he is far from the beacon, don't allow the camera page ; if he is close (near or immediate) open camera
        // before opening the camera save in userDefault the Beacon UUID, major, minor, and rssi. 
        // these beacon data are required when sending the photo to the server
        
        let isUserLoggedIn = UserDefaults.standard.bool(forKey: "isUserLoggedIn")
        
        if(!isUserLoggedIn){
            
            //self.performSegue(withIdentifier: "ID_segueToRegistration", sender: self)
            
            
            displayMyAlertMessages("Registration required", alertMessage: "You need to register to use this function")
        }
        else{
        
        
        if (beaconHasBeenDetected == true){
            
            UserDefaults.standard.set(majorID, forKey: "Beac_Maj")
            UserDefaults.standard.set(minorID, forKey: "Beac_Min")
            UserDefaults.standard.set(rssi, forKey: "Beac_Rssi")
            UserDefaults.standard.setValue(beaconUUID.uuidString, forKey: "Beac_UUID")
            UserDefaults.standard.synchronize()
            
            //mqttt disconnect here
            self.mqttClient?.disconnect()
           
            changeToNewView(viewIdentifier: "TakePhoto_ID")
        
        }
        else{
            print("you are to far to take a picture")
            displayMyAlertMessages(cameraToBeaconPosTitle, alertMessage: cameraToBeaconPosMessg)
        }
    }
    
   
        
    }
    
    func changeToNewView(viewIdentifier: String){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let aViewCont = storyboard.instantiateViewController(withIdentifier: viewIdentifier) as UIViewController // the ID of the qr generator key
        self.present(aViewCont, animated: true, completion: nil)
    }
    
    
    @IBAction func tutorialBtnPushed(_ sender: UIButton) {
        lblExtraMissionInfo.unblink()
    }
    
    
    @IBAction func findTheStickers(_ sender: UIButton) {
        print("btn findTheStickers pushed ")
    }
    
    
    // when the tutorial button pushed
//    @IBAction func tutorialBtnPushed(_ sender: UIButton) {
//        
//        let numbCheckPoints = Int(lblCheckPoint.text!)
//        print("numbCheckPoints = \(numbCheckPoints)")
//        
//        if numbCheckPoints! >= 4 {
//            lblUbiChanMessage.text = "Extra mission:\n Go close to the Basket ball court"
//            
//        }
//        
//        //show my custom view alert to give the tuto info
//        self.view.insertSubview(TutorailInfoSubView, aboveSubview: myGoogleMapView)
//        TutorailInfoSubView.backgroundColor = UIColor.orange.withAlphaComponent(0.9)
//        
//        
//    }
    
    
//    @IBAction func btnOKAYpushed(_ sender: UIButton) {
//        
//        self.view.insertSubview(TutorailInfoSubView, belowSubview: myGoogleMapView)
//        lblExtraMissionInfo.unblink()
//        
//    }
  
    

}

extension UILabel {
    func blink() {
        self.alpha = 0.0;
        UIView.animate(withDuration: 0.8, //Time duration you want,
            delay: 0.0,
            options: [.curveEaseInOut, .autoreverse, .repeat],
            animations: { [weak self] in self?.alpha = 1.0 },
            completion: { [weak self] _ in self?.alpha = 0.0 })
    }
    
    func unblink(){
        self.layer.removeAllAnimations()
        self.alpha = 1.0
    }
}

