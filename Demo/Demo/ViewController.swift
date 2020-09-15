//
//  ViewController.swift
//  Demo
//
//  Created by MAC PRO on 23/08/20.
//  Copyright © 2020 MAC PRO. All rights reserved.
//

import UIKit
import TangerineKey
import CoreBluetooth
import WSProgressHUD


class ViewController: UIViewController {
    
    @IBOutlet weak var bookingTextField : UITextField!
    @IBOutlet weak var phoneNumberTextField : UITextField!
    @IBOutlet weak var validateButton : UIButton!
    
    
    var currentState : CarState?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        TangerineKeyManager.sharedInstance.delegate = self
        redirectUser()
    }
    
    
    func redirectUser(){
           if TangerineKeyManager.sharedInstance.isDeviceConfigured() {
               redirectToDailyInspection()
           } else {
           }
       }
    
    
    @IBAction func validateButtonAction(_ sender: Any) {
        WSProgressHUD.show()
        if let referenceNumber = bookingTextField.text, let number = phoneNumberTextField.text {
             TangerineKeyManager.sharedInstance.connectToDevice(phoneNumber: number, refNumber: referenceNumber)
        }
    }
    
    
    
    func redirectToDailyInspection(){
        let connectedVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        connectedVC.currentState = currentState
        connectedVC.delegate = self
        self.navigationController?.pushViewController(connectedVC, animated: true)
        
    }


}



extension ViewController : HomeViewControllerProtocol {
    
    
    func sessionDidExpire() {
        //showAlert("Booking slot expired")
    }
}

extension ViewController : TangerineKeyManagerDelegate {
    
    
    func slotExpired() {
    }
    
    
    
    func receivedResponse(state: CarState) {
        WSProgressHUD.dismiss()
        currentState = state
        TangerineKeyManager.sharedInstance.delegate = nil
        redirectToDailyInspection()
    }
    
    func errorOccured(_errorState: ViewState) {
        WSProgressHUD.dismiss()
        var message = ""
        switch _errorState {
        case .bluetoothPoweredOff:
            message = "Please enable bluetooth to proceed"
        case .slotExpired:
            message = "Invalid Booking Information"
        case .failedToConnect:
            message = "Failed to connect"
        case .getStarted:
            break
        case .unauthorised:
            message = "Allow bloetooth permission to use"
        case .connected:
            break
        case .validationFailed:
            message = "Invalid Booking Information"
        case .unKnown:
            message = "Invalid Booking Information"
        case .connecting:
            return
        case .disconnected:
            return
        }
        showAlert(message)
    }
    
    func didDisconnect(_ error: Error?) {
    }
}


extension ViewController: UITextFieldDelegate {
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == bookingTextField {
            phoneNumberTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}



extension ViewController {

    func showAlert(_ message : String) {

        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

