//
//  HomeViewController.swift
//  Demo
//
//  Created by MAC PRO on 27/08/20.
//  Copyright © 2020 MAC PRO. All rights reserved.
//

import UIKit
import WSProgressHUD
import  TangerineKey
import CoreBluetooth


protocol HomeViewControllerProtocol: class {
    func sessionDidExpire()
}

class HomeViewController: UIViewController {
    
    @IBOutlet weak var lockButton : UIButton!
    @IBOutlet weak var endBookingButton : UIButton!
    
    var currentState : CarState?
    weak var delegate : HomeViewControllerProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        self.title = "Home"
        
        if let state = currentState, state == .locked {
             lockButton.setTitle("Tap to Unlock", for: .normal)
        } else {
             lockButton.setTitle("Tap to Lock", for: .normal)
        }
        TangerineKeyManager.sharedInstance.delegate = self
        
        if !TangerineKeyManager.sharedInstance.isConnected() {
            WSProgressHUD.show()
             TangerineKeyManager.sharedInstance.connectToDevice(phoneNumber: nil, refNumber: nil)
            
        }

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func lockButtonAction(_ sender : UIButton) {
     //   if TangerineELDManager.sharedInstance.isConnected() {
            WSProgressHUD.show()
            if let state = currentState {
                TangerineKeyManager.sharedInstance.lockUnlockCommand(state: state)
            } else {
                if TangerineKeyManager.sharedInstance.isDeviceConfigured() {
                        TangerineKeyManager.sharedInstance.connectToDevice(phoneNumber: nil, refNumber: nil)
                    }
            }
            
       // }
    }
    
    @IBAction func endBooking(_ sender : UIButton) {
        TangerineKeyManager.sharedInstance.disconnectFromPeripheral()
    }
    
    @IBAction func getBookingInfo(_ sender : UIButton) {
       getInfo()
    }
    
    
    func getInfo(){
        if TangerineKeyManager.sharedInstance.isDeviceConfigured() {
            TangerineKeyManager.sharedInstance.getBookingInfo() { (response, error) in
                if error == nil {
                    if let startTime = response?.startTime, let endtime = response?.endTime,  let car = response?.vehicleNumber ,let phone = response?.phoneNumber, let ref = response?.refNumber{
                        if let startDate = Date.date(from: startTime, with: "yyyy-MM-dd HH:mm:ss"),let endDate = Date.date(from: endtime, with: "yyyy-MM-dd HH:mm:ss") {
                          self.showAlert("start time: " + startDate.timeIntervalSince1970.cleanStringValue + "   end time:" + endDate.timeIntervalSince1970.cleanStringValue + "   connected vehicle: " + car  + "  phone number: " + phone + "  booking ref: " + ref   )
                        }
                        
                    }
                    
                } else {
                    self.showAlert("Some error occured")
                    }
            }
        } else {
            showAlert("No Info found")
        }
    }

}


extension HomeViewController : TangerineKeyManagerDelegate {
    
    
    func receivedResponse(state: CarState) {
        WSProgressHUD.dismiss()
               currentState = state
               if state == CarState.locked {
                   lockButton.setTitle("Tap to Unlock", for: .normal)
               } else {
                   lockButton.setTitle("Tap to Lock", for: .normal)
               }
    }
    
    
    
     
    func errorOccured(_errorState: ViewState) {
        WSProgressHUD.dismiss()
        var message = ""
        switch _errorState {
        case .bluetoothPoweredOff:
            message = "Please enable bluetooth to proceed"
        case .slotExpired:
            message = "Booking slot expired"
        case .failedToConnect:
            message = "failed to connect"
        case .getStarted:
            break
        case .unauthorised:
            message = "Allow bloetooth permission to use"
        case .connected:
            break
        case .validationFailed:
            // ideally here either slot is deleted / expired.
            return
        case .unKnown:
            slotExpired()
            break
            break
        case .connecting:
            return
        case .disconnected:
            return
        }
        showAlert(message)
    }
    
    
    func didDisconnect(_ error: Error?) {
        WSProgressHUD.dismiss()
        TangerineKeyManager.sharedInstance.delegate = nil
        delegate?.sessionDidExpire()
        self.navigationController?.popViewController(animated: true)
    }
    
    func slotExpired() {
        TangerineKeyManager.sharedInstance.delegate = nil
        delegate?.sessionDidExpire()
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
   
}


extension HomeViewController {

    func showAlert(_ message : String) {

        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}



extension Date {
    
    static func date(from dateString: String, with format: String) -> Date? {
        let dateFormatter        = DateFormatter()
        dateFormatter.dateFormat = format // Your date format
        dateFormatter.locale     = Locale(identifier: "en_US")
        dateFormatter.timeZone   = TimeZone(abbreviation: "GMT+0:00") // Current time zone
        let date                 = dateFormatter.date(from: dateString) // According to date format your date string
        
        return date
    }
}



