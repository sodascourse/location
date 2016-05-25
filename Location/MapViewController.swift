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

    override func viewDidLoad() {
        super.viewDidLoad()

        self.mapView.showsCompass = true
        self.mapView.showsScale = true

        let currentToolbarItems: [UIBarButtonItem] = self.toolbarItems ?? []
        self.toolbarItems = [MKUserTrackingBarButtonItem(mapView: self.mapView)] + currentToolbarItems
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // Show the toolbar of the navigation controller
        self.navigationController?.setToolbarHidden(false, animated: true)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // Ask user to grant permission first.
        LocationManager.sharedInstance.requestUserAuthorization { granted in
            if granted {
                self.mapView.showsUserLocation = true
                self.mapView.setUserTrackingMode(.Follow, animated: true)
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

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        // Hide the toolbar of the navigation controller
        self.navigationController?.setToolbarHidden(true, animated: true)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            guard let detailViewController = segue.destinationViewController as? LocationDetailViewController else {
                return
            }
            guard let annotationView = sender as? MKAnnotationView else { return }

            detailViewController.annotation = annotationView.annotation
        }
    }
}

// MARK: - Map View Delegate
// Extenstion is good for grouping different section of your class.
extension MapViewController: MKMapViewDelegate {

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        // Check annotation type
        if annotation is MKUserLocation {
            // This annotation is "user's current location". Return `nil` to use default annotation view from the OS.
            return nil
        }

        // Normal annotation
        let annotationViewIdentifier = "Annotation View"
        var annotationPinView: MKPinAnnotationView!
        // Dequeue a reused view
        if let reusedView = mapView.dequeueReusableAnnotationViewWithIdentifier(annotationViewIdentifier) {
            if let reusedPinView = reusedView as? MKPinAnnotationView {
                annotationPinView = reusedPinView
            }
        }
        // Create one if cannot find a reused one
        if annotationPinView == nil {
            annotationPinView = MKPinAnnotationView(annotation: nil, reuseIdentifier: annotationViewIdentifier)
            annotationPinView.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }

        // Setup the annotation view
        annotationPinView.annotation = annotation
        annotationPinView.canShowCallout = true
        annotationPinView.animatesDrop = true
        annotationPinView.draggable = true

        return annotationPinView
    }

    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        self.performSegueWithIdentifier("ShowDetail", sender: view)
    }
}

// MARK: - IBActions
extension MapViewController {

    @IBAction func mapViewLongPressed(sender: UILongPressGestureRecognizer) {
        // We only want to process the event when the gesture is ended
        //
        // UILongPressGestureRecognizer is a "continuous" gesture recognizer. Unlike UITapGestureRecognizer, which
        // is a "discrete" gesture recognizer, a continuous gesture recognizer keeps sending events.
        //
        if sender.state != .Ended {
            return
        }

        // Convert CGPoint to CLLocationCoordninate2D
        let pointInMapView = sender.locationInView(self.mapView)
        let selectedCoordinate = self.mapView.convertPoint(pointInMapView, toCoordinateFromView: self.mapView)

        // Create an annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = selectedCoordinate
        annotation.title = "Selected location"
        self.mapView.addAnnotation(annotation)
    }

    @IBAction func trashButtonClicked(sender: AnyObject) {
        self.mapView.removeAnnotations(self.mapView.annotations)
    }

}
