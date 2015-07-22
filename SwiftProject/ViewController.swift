//
//  ViewController.swift
//  SwiftProject
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var picker: UIPickerView!
    var username: String = ""
    var usernames: [Dictionary<String,AnyObject>] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add these statements to dismiss the keyboard
        self.textField.delegate = self
        self.textField.resignFirstResponder()
        
        // Query Cloud accounts to update Picker values
        APSUsers.query(nil, {(e: APSResponse!) -> Void in
            if (e.success) {
                self.usernames = e.valueForKey("response")?.valueForKey("users") as [Dictionary<String,AnyObject>]
                self.picker.reloadAllComponents()
            } else {
                var alert: UIAlertView = UIAlertView(title: "Error", message: "Unable to retrieve user accounts!", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onClick(sender: UIButton) {
        // Send analytics feature event
        APSAnalytics.sharedInstance().sendAppFeatureEvent("sample.feature.login", payload: nil)
        
        // Login to a Cloud account
        var params = [
            "login" : self.username,
            "password" : self.textField.text
        ]
        APSUsers.login(params, { (e: APSResponse!) -> Void in
            if (e.success) {
                NSLog("Successfully logged in as %@", self.username)
                APSPerformance.sharedInstance().username = self.username
            } else {
                NSLog("ERROR: Failed to log in!")
            }
        })
    }
    
    // MARK: Picker DataSource/Delegate
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.usernames.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return self.usernames[row]["username"] as String
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.username = self.usernames[row]["username"] as String
    }
    
    // MARK: TextField Delegate
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
}