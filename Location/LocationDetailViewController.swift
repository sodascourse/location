//
//  LocationDetailViewController.swift
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
import CoreLocation

class LocationDetailViewController: UIViewController {

    @IBOutlet weak var addressLabel: UILabel!
    let geocode = CLGeocoder()
    @IBOutlet weak var geocoderLoadingIndicator: UIActivityIndicatorView!

    var annotation: MKAnnotation? {
        didSet {
            // Update the content view if the view is loaded
            if self.isViewLoaded() {
                self.reloadContent()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Reset
        self.addressLabel.text = nil
        // Update the content view
        self.reloadContent()
    }

    func reloadContent() {
        if let annotation = self.annotation {
            // Create a CLLocation for reverse geocoding
            let location = CLLocation(latitude: annotation.coordinate.latitude,
                                      longitude: annotation.coordinate.longitude)
            // Show the loading indicator
            self.geocoderLoadingIndicator.startAnimating()
            //
            // "geocode" ---> address to coordinate
            // "reverse geocode" ---> coordinate to address
            //
            geocode.reverseGeocodeLocation(location) { (placemarks: [CLPlacemark]?, error: NSError?) in
                // Hide the loading indicator
                self.geocoderLoadingIndicator.stopAnimating()
                // Fetch the address string
                if let placemark = placemarks?.first {
                    if let addressLines = placemark.addressDictionary?["FormattedAddressLines"] as? [String] {
                        let address = addressLines.joinWithSeparator(" ")
                        self.addressLabel.text = address
                    }
                }
            }
        } else {
            self.addressLabel.text = nil
        }
    }
}
