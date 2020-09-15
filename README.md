# KeySDK-iOS-Sample

This guide gives information for the TangerineKey integration with the third party iOS application.

TangerineKey has been integrated into this project. 

Please refer to the ViewState and CarState class for error and state-related information.


## Requirements

* iOS 12.0+ 
* Xocde 11+
* Swift 5.0+



## Installation

#### CocoaPods

To integrate TangerineKey into your Xcode project using CocoaPods, specify it in your Podfile:

```
source 'https://github.com/Tangerine-AI/iosKeySdk-specs.git'
pod 'TangerineKey', '~> 1.0.0'
```


## Library Usage


#### Step 1

Open `AppDelegate.swift`  file inside your app  and add the following code in `didFinishLaunchingWithOptions()` method.

```
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    TangerineKeyManager.sharedInstance.configure()
    return true
}
```

#### Step 2

Set the viewcontroller as the delegate  of  'TangerineKeyManager' to receive the callbacks from SDK. Don't forget to set it to nil once the viewcontroller no longer needs it. 

```
      TangerineKeyManager.sharedInstance.delegate = self
```



#### Step 3

Connect to the keyless device using the following method:

```
       TangerineKeyManager.sharedInstance.connectToDevice(phoneNumber: number, refNumber: referenceNumber)
```

#### Step 4

If the booking info was correct, and connection happened successfully, you will receive a callback on 'func receivedResponse(state: CarState)' with the latest lock status of the car. Else 'func errorOccured(_errorState: ViewState)' will be called with the reasons for failure.

```
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
```

#### Step 5

Lock and unlock the vehicle using the following APIs. You need to be connected before using this method. Use the same state received in 'receivedResponse' API.
 This will lock / unlock the currently connected vehicle. 

```

         TangerineKeyManager.sharedInstance.lockUnlockCommand(state: state)
```


#### Step 6

Disconnect the device using the following API. On successful disconnect you will get callback on  'didDisconnect' method.

```
       TangerineKeyManager.sharedInstance.disconnectFromPeripheral()
```

#### Step 7

Once the booking slot is expired, you will get a callback for 'slotExpired' method.

```
        func slotExpired() {
               TangerineKeyManager.sharedInstance.delegate = nil
               delegate?.sessionDidExpire()
           }
```
#### Booking Information Object

```KeyBookingInfo``` object contains  following information related to booking.
1. refNumber 
2. startTime
3. endTime 
4. vehicleNumber 
5. phoneNumber 
6. obdId 


#### Get Booking information using Booking Reference

you can get the booking information for the particular Booking Reference by using below api.  
it will return ```error``` if booking information is not there with the sdk. if sdk has the booking info then it will return the valid ```KeyBookingInfo``` object.

```
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
        
```


#### Get BT connection state

you can check if device is already connected with the Jido Sense device by using below api

```
        
           TangerineKeyManager.sharedInstance.isConnected() 
        
```

#### Check if Device configured

you can use the below API to test if already the app connected to this device. The API will return true if it is not a new connection and will try to use previously saved data for connection else it will return false.

```
        
           TangerineKeyManager.sharedInstance.isDeviceConfigured()
        
```

#### State information while connecting to the device or executing the lock/unlock feature

Please find below list of state that can occur during the connection and execution of lock/unlock features.

1. ``` ViewState.connecting ```  :  App starts connecting to the device.
2. ``` ViewState.connected ```  :  App is connected to device.
3. ``` ViewState.disconnected ``` : App is disconnected to device because of range.
4. ``` ViewState.validationFailed ``` : App goes to this state when already validated booking is expired or device invalidates the booking information when try to execute the lock/unlock feature.
5. ``` ViewState.bluetoothPoweredOff ``` : App goes to this state when bluetooth is powered off.
``` ViewState.unauthorised ``` : App goes to this state when user has not given permission to use bluetooth.
6. ``` ViewState.failedToConnect ``` : When app is unable to connect to the device after ~15 seconds of time or app is not near to the device.
7. ``` ViewState.slotExpired ``` : This error occurs when booking is expired.
6. ``` CarState.locked ``` : When device is locked
9. ``` CarState.unlocked ``` : When device is unlocked 



For more detailed implementation please refer the sample app code.

