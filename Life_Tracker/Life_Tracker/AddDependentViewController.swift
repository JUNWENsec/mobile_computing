//
//  AddDependentViewController.swift
//  Life_Tracker
//
//  Created by junwenz on 2017/9/28.
//  Copyright © 2017年 Microsoft. All rights reserved.
//

import UIKit

class AddDependentViewController: UIViewController {

    @IBOutlet weak var DependentPhoneNumberTextField: UITextField!
    @IBOutlet weak var DependentSecretPasswordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func UserPressedOnAdd(_ sender: UIButton) {
        let dependentPhoneNumber = DependentPhoneNumberTextField.text
        let secretPassword = DependentSecretPasswordTextField.text
        var username:String?
        username = UserDefaults.standard.object(forKey: "DependentUsername") as? String
        let client = MSClient(applicationURLString: "https://life-tracker.azurewebsites.net")
        let table = client.table(withName: "UserData")
        let tableRelationship = client.table(withName: "UserRelationship")
        let userType = "Dependent"
        
        if ((dependentPhoneNumber?.isEmpty)! || (secretPassword?.isEmpty)!){
            self.displayAlertMessage(useMessage: "Your must enter a dependent phone number and his secret password.")
        }
        
        table.read { (result, error) in
            if let err = error {
                print("ERROR ", err)
            } else if let items = result?.items {
                for item in items {
                    if(item["type"] as? String == userType){
                        if (item["phoneNumber"] as? String == dependentPhoneNumber && item["complete"] as! Bool == false){
                            if (item["secretPassword"] as? String == secretPassword){
                                UserDefaults.standard.set(dependentPhoneNumber,forKey:"DependentGuardian")
                                UserDefaults.standard.synchronize()
                                let itemToInsert = ["guardian":username!,"dependent":dependentPhoneNumber!,"complete": false, "__createdAt": Date()] as [String : Any]
                                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                                tableRelationship.insert(itemToInsert) {
                                    (item, error) in
                                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                    if error != nil {
                                        self.displayAlertMessage(useMessage: "Please check you network and try again.")
                                        print("Error: " + (error! as NSError).description)
                                    }
                                }
                                print("complete checking the user identify and password")
                                let alert = UIAlertController(title:"COMFIRMATION",message:"You have sucessfully add your guardian.",preferredStyle:UIAlertControllerStyle.alert)
                                let okAction = UIAlertAction(title:"OK",style:UIAlertActionStyle.default){
                                    action in
                                    self.dismiss(animated: true, completion: nil)
                                }
                                alert.addAction(okAction)
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                }
                self.displayAlertMessage(useMessage: "You fail to add your dependent. Please check secret password and network and then try again.");
                return;
                
            }
        }

        

        
    }
    
    //display alert message
    func displayAlertMessage(useMessage:String){
        let alert = UIAlertController(title:"ALERT",message:useMessage,preferredStyle:UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title:"OK",style:UIAlertActionStyle.default,handler:nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    //display notification message
    func displayNotificationMessage(useMessage:String){
        let alert = UIAlertController(title:"Notification",message:useMessage,preferredStyle:UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title:"OK",style:UIAlertActionStyle.default,handler:nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
