//
//  LocationManager.swift
//  Location
//
//  Copyright 2016 Tien-Che Tsai
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import CoreLocation

class LocationManager: NSObject {

    static let sharedInstance = LocationManager()

    private let locationManager: CLLocationManager
    private var userAuthorizationHandler: ((Bool) -> Void)?

    private override init() {
        // Setup all `let` properties first
        self.locationManager = CLLocationManager()
        // Call the super.init()
        super.init()
        // Then you can start use `self`. Like assigning to other properties here.
        self.locationManager.delegate = self
    }

    deinit {
        // Check the declaration of the CLLocationManager first,
        // 1. If its `delegate` is declared as `unowned(unsafe)`, then you must add this line to clear the delegate
        //    when the delegate (which is the `LocationManager` here) is being deinit.
        // 2. If its `delegate` is delcared as `weak`, it's okay to not add this line.
        self.locationManager.delegate = nil
    }

    // MARK: - Method

    func requestUserAuthorization(handler: (Bool) -> Void) {
        // We save the handler as a property first. Note that here would be a reference cycle.
        self.userAuthorizationHandler = handler
        // Check
        if !CLLocationManager.locationServicesEnabled() {
            self.notifyUserAuthorizationStatus(.Denied)
            return
        }
        let status = CLLocationManager.authorizationStatus()
        if status == .NotDetermined {
            // Remember to add `NSLocationWhenInUseUsageDescription` to Info.plist when your app calls this method.
            self.locationManager.requestWhenInUseAuthorization()
        } else {
            self.notifyUserAuthorizationStatus(status)
        }
    }

    private func notifyUserAuthorizationStatus(status: CLAuthorizationStatus) {
        if status == .NotDetermined {
            return
        }
        let granted = status == .AuthorizedWhenInUse || status == .AuthorizedAlways
        if let userAuthorizationHandler = self.userAuthorizationHandler {
            userAuthorizationHandler(granted)
        }
        // We release the handler here to solve the reference cycle.
        self.userAuthorizationHandler = nil
    }
}

// Extenstion is good for grouping different section of your class.
extension LocationManager: CLLocationManagerDelegate {

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        self.notifyUserAuthorizationStatus(status)
    }

}
