//
//  MapViewController.swift
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

import UIKit
import MapKit

//
// 1. We want to use this view controller to show a map.
// 2. We want this map showing user's current location.
//    and hence we have to ask for user to grant the location permission first.
//
class MapViewController: UIViewController {

    // Check the "Connection Inspector" in the Storyboard too.
    // The `delegate` of this map view is also set to this view controller by a connection
    @IBOutlet weak var mapView: MKMapView!

    deinit {
        // Check the declaration of the MKMapView first,
        // 1. If its `delegate` is declared as `unowned(unsafe)`, then you must add this line to clear the delegate
        //    when the delegate (which is the `MapViewController` here) is being deinit.
        // 2. If its `delegate` is delcared as `weak`, it's okay to not add this line.
        self.mapView.delegate = nil
    }

    // MARK: View Lifecycle

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // Ask user to grant permission first.
        LocationManager.sharedInstance.requestUserAuthorization { granted in
            if granted {
                self.mapView.showsUserLocation = true
                self.mapView.userTrackingMode = .Follow
            } else {
                let message = "Open the Preferences to enable the location service and " +
                    "grant location permission for this app"
                let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
                let alertAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(alertAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
}

// Extenstion is good for grouping different section of your class.
extension MapViewController: MKMapViewDelegate {
}
