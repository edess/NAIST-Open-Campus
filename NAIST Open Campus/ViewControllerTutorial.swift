//
//  ViewControllerTutorial.swift
//  NAIST Open Campus
//
//  Created by Edess Akpa on 11/9/16.
//  Copyright © 2016 Edess Akpa. All rights reserved.
//

import UIKit

class ViewControllerTutorial: UIViewController {

    @IBOutlet weak var mainScrollView: UIScrollView!
    
    var imageArray = [UIImage]()
    var isExtraMissionActivated: Bool = false
    
    let debugingText = "[ViewControllerTutorial]"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        mainScrollView.frame = view.frame
        
        // get the value of ExtraMissionActivation
        isExtraMissionActivated = UserDefaults.standard.bool(forKey: "extraMissionActivation")
        print("\(debugingText) the boolean of isExtraMissionActivated = \(isExtraMissionActivated) ")
        
        if isExtraMissionActivated == true{
            // image array will include the two images of extra mission tutorial
            
            imageArray = [#imageLiteral(resourceName: "opencampus_extra_1"), #imageLiteral(resourceName: "opencampus_extra_2")]
        
        }
        else{
            imageArray = [#imageLiteral(resourceName: "opencampus_tutorial_1"), #imageLiteral(resourceName: "opencampus_tutorial_2"), #imageLiteral(resourceName: "opencampus_tutorial_3"), #imageLiteral(resourceName: "opencampus_tutorial_4"), #imageLiteral(resourceName: "opencampus_tutorial_5")]
        }
        
        for i in 0..<imageArray.count{
            
            let imageView = UIImageView()
            imageView.image = imageArray[i]
            imageView.contentMode = .scaleAspectFit
            
            let xPosition = self.view.frame.width * CGFloat(i)
            imageView.frame = CGRect(x: xPosition, y: 0, width: self.mainScrollView.frame.width, height: self.mainScrollView.frame.height)
            
            mainScrollView.contentSize.width = mainScrollView.frame.width * CGFloat(i + 1)
            mainScrollView.addSubview(imageView)
            
            
        }
    }
    
    
    @IBAction func btnExitPushed(_ sender: UIButton) {
        
        // send user back to the main viewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let aViewCont = storyboard.instantiateViewController(withIdentifier: "mainPage_ID") // the login beacon view controller ID
        self.present(aViewCont, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    


}
