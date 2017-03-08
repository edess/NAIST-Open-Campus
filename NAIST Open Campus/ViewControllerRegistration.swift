//
//  ViewControllerRegistration.swift
//  NAIST Open Campus
//
//  Created by Edess Akpa on 10/19/16.
//  Copyright © 2016 Edess Akpa. All rights reserved.
//

import UIKit

class ViewControllerRegistration: UIViewController {//, UIPickerViewDelegate, UIPickerViewDataSource
    
    @IBOutlet weak var TFusername: UITextField!
   
    
    @IBOutlet weak var userDetailsFieldView: UIView!
    
    @IBOutlet weak var lblOptionalWarning: UILabel!
    
    
    // username variable
    var usernameValue: String = ""
    
    
    //NSLocalized string for Localization (English - Japanese)
    let registrationSuccessTitle = NSLocalizedString("registrationViewPage.SuccessTitle", comment: "")
    let registrationSuccessMsg = NSLocalizedString("registrationViewPage.SuccessMessage", comment: "")
    
    let registrationEmptyFieldsTitle = NSLocalizedString("registrationViewPage.EmptyFieldsTitle", comment: "")
    let registrationEmptyFieldsMsg = NSLocalizedString("registrationViewPage.EmptyFieldsMessg", comment: "")

    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        //self.PickerViewAge.dataSource = self
        //self.PickerViewAge.delegate = self
        
        
        assignbackground()
         userDetailsFieldView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
       
        
        
        // optional user inputs label
        lblOptionalWarning.text = "Username is optional. \nBut keep in mind that, we will not be able to recognize you to give your gift when you finish all the missions in the campus. \nBecause your username will be set to \"Anonymous\" \n\n*This app is just for research within NAIST University Campus (Japan). \nThank you for helping us in our academic research."
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
    
    // built in method to resign the first responder when user clicks on the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

        // function to handle the gender segmented control
//    @IBAction func UIGenderChanged(_ sender: UISegmentedControl) {
//        
//        switch segmentedControlGender.selectedSegmentIndex {
//        case 0:
//            genderValue = "Male"
//            
//            break
//        case 1:
//            genderValue = "Female"
//            break
//        default:
//            genderValue = "not defined / unknow"
//            break
//        }
//        print("the gender of user is: \(genderValue)")
//    }
    /*
      manage the age picker view from here
     */
    
    /*
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ageArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ageArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        ageValue = ageArray[row]
        print("the age of user is: \(ageValue)")
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var label = view as! UILabel!
        if label == nil {
            label = UILabel()
        }
        
        let data = ageArray[row]
        let title = NSAttributedString(string: data, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 26.0, weight: UIFontWeightRegular)])
        label?.attributedText = title
        label?.textAlignment = .center
        label?.textColor = UIColor.white
        return label!
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 36.0
    }
    */
    
    /*
     end manage the age picker view
     */

    
    // manage the push of createAccount button
    
    
    @IBAction func createAccountPushed(_ sender: UIButton) {
        
       
        
        if (TFusername.text! == ""){
            usernameValue = "Anomynous"
        }
        else{
            usernameValue = TFusername.text!
        }
        
        // verify that all fields are not empty
       // if(usernameValue != "" && genderValue != "" && ageValue != "") {
            
            //create userunique ID
            let userUniqueIDValue = createUniqueUserID(usernameValue)
            
            // if not empty send data to db and register user, and also show an alert to notify user registraion
            var request = URLRequest(url: URL(string:"http://153.126.215.11/~gatcha-cicp/opencampus/registration.php")!)
            request.httpMethod = "POST"
            
            let postStringValue = "username=\(usernameValue)&gender=NA&age=299&uniqueid=\(userUniqueIDValue)"
            request.httpBody = postStringValue.data(using: .utf8)
            
            let task = URLSession.shared.dataTask(with: request){ data, response, error in
                guard let data = data , error == nil else{
                    print("error = \(error)")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse  , httpStatus.statusCode != 200{
                    
                    //when an error occured
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(response)")
                    self.displayMyAlertMessages("Problem occured", alertMessage: "A problem occured, please check your internet connection and try again.")
                }
                else{
                    // when registration is okay
                    let responseString = String(data: data, encoding: .utf8)
                    print("response String = \(responseString)")
                    
                    do {
                        let myJSON = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String : AnyObject]
                        
                        if let userAddedpoint = myJSON["jsonanswer"]?.value(forKey: "addedpoint"){
                            print("userAddedpoint = \(userAddedpoint)")
                            UserDefaults.standard.set(userAddedpoint, forKey: "user_points")
                            UserDefaults.standard.synchronize()
                            print("[Elder Debugg]")
                        }
                       }
                    catch let error as NSError{
                        print("Failed to load: \(error.localizedDescription)")
                        self.displayMyAlertMessages("Problem occured", alertMessage: "A problem occured, please check your internet connection and try again.")
                    }
                    
                    // put the boolean value for isUserAlreadyregister to true 
                    UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
                    UserDefaults.standard.synchronize()
                    print("[Elder Debugg 2]")
                    
                    OperationQueue.main.addOperation {
                    self.displayMyAlertMessages(self.registrationSuccessTitle, alertMessage: self.registrationSuccessMsg)
                    }
                    
                    
                }
                
            }
            task.resume()
        
       // }
//        else {
//            // if empty show an alert dialog to ask user to fill
//            displayMyAlertMessages(registrationEmptyFieldsTitle, alertMessage: registrationEmptyFieldsMsg)
//            return;
//
//        
//        }
        
        
    }
    
  
    // function for displaying the alert messages
    func displayMyAlertMessages(_ alertTitle:String, alertMessage:String){
        print("[Elder Debugg 3]")
        
        let myAlertView = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        myAlertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            print("alert message:\(alertMessage)")
            
            // if user has been registered correctly, send him to the main app screen
            if(alertTitle == self.registrationSuccessTitle){
                UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
                UserDefaults.standard.set(false, forKey: "extraMissionActivation") // extra missionActivate to false
                UserDefaults.standard.set(self.usernameValue, forKey: "user_name") // save username 
                UserDefaults.standard.synchronize()
                
                OperationQueue.main.addOperation {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let aViewCont = storyboard.instantiateViewController(withIdentifier: "mainPage_ID") // the login beacon view controller ID
                    self.present(aViewCont, animated: true, completion: nil)
                }
                
            }
           
        }))
        
        present(myAlertView, animated: true, completion: nil)
        
    }
    
    // create a user unique ID by using: "iOS"+ username+registration time (systemTime) ,
    // november 6th Update: user unique Id shouldn't not contain letter and special character, just numbers. (timestamp)
    func createUniqueUserID (_ username:String) -> Int64{
      
        // create the timestamp of system currenttime
        var timeStamp : String {
            return "\(Date().timeIntervalSince1970 * 1000)"
        }
        print("time stamp = \(timeStamp)")
        
        
        //let uniqueID = "iOS\(username)"+"\(timeStamp)"
        let uniqueID = Int64(Date().timeIntervalSince1970 * 1000)
        //let UniqueID_ToSend = Int(uniqueID)
        print("created unique Id = \(uniqueID)")
        
        //print("unique Id to send = \(UniqueID_ToSend)")
        
        //put the user unique id value in the UserDefault.standar in order to use it later for the 
        // different mqtt subscribe request
        //UserDefaults.standard.set(uniqueID, forKey: "userUnique_ID")
        UserDefaults.standard.setValue(NSNumber(value: UInt64(uniqueID)), forKey: "userUnique_ID")
        UserDefaults.standard.synchronize()
        
        
        
        
        return uniqueID
        
    }
    
    
    
    
    
}
