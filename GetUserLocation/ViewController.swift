//
//  ViewController.swift
//  ReachIn
//
//  Created by Faiz Rashid on 11/5/19.
//  Copyright © 2019 Faiz Rashid. All rights reserved.
//
import UIKit
import GooglePlaces
import GoogleMaps


class ViewController: UIViewController, UISearchBarDelegate,LocateOnTheMap, GMSAutocompleteFetcherDelegate {
    
    
    
    
    public func didFailAutocompleteWithError(_ error: Error) {
        //        resultText?.text = error.localizedDescription
    }
    
    /**
     * Called when autocomplete predictions are available.
     * @param predictions an array of GMSAutocompletePrediction objects.
     */
    public func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        //self.resultsArray.count + 1
        
        for prediction in predictions {
            
            if let prediction = prediction as GMSAutocompletePrediction?{
                self.resultsArray.append(prediction.attributedFullText.string)
            }
        }
        self.searchResultController.reloadDataWithArray(self.resultsArray)
//        self.searchResultsTable.reloadDataWithArray(self.resultsArray)
        print(resultsArray)
    }

    
    @IBOutlet weak var mapView: UIView!
    
    var googleMapsView :GMSMapView!
    var searchResultController: SearchResultsController!
    var resultsArray = [String]()
    var gmsFetcher: GMSAutocompleteFetcher!
  
    
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        self.googleMapsView = GMSMapView(frame: self.mapView.frame)
        self.view.addSubview(self.googleMapsView)
        
        searchResultController = SearchResultsController()
        searchResultController.delegate = self
        gmsFetcher = GMSAutocompleteFetcher()
        gmsFetcher.delegate = self
    }
    
    //action for search location by address
    
    @IBAction func searchWithAddress(_ sender: Any) {
      let searchController = UISearchController(searchResultsController: searchResultController)
    
        searchController.searchBar.delegate = self
        
        self.present(searchController, animated: true, completion: nil)
    }
    
        func locateWithLongitude(_ lon:Double, andLatitude lat:Double, andTitle title: String) {
        DispatchQueue.main.async {
            
            let latDouble = Double(lat)
            let lonDouble = Double(lon)
            self.googleMapsView.clear()
            let position = CLLocationCoordinate2D(latitude: latDouble , longitude: lonDouble )
            let marker = GMSMarker(position: position)
            let camera = GMSCameraPosition.camera(withLatitude: latDouble , longitude: lonDouble , zoom: 18)
            self.googleMapsView.camera = camera
           // ("\(status)")
            //marker.title = title
            marker.title = "Destination : \(title))"
            marker.map = self.googleMapsView
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        //        let placeClient = GMSPlacesClient()
        //
        //
        //        placeClient.autocompleteQuery(searchText, bounds: nil, filter: nil)  {(results, error: Error?) -> Void in
        //           // NSError myerr = Error;
        //            print("Error @%",Error.self)
        //
        //            self.resultsArray.removeAll()
        //            if results == nil {
        //                return
        //            }
        //
        //            for result in results! {
        //                if let result = result as? GMSAutocompletePrediction {
        //                    self.resultsArray.append(result.attributedFullText.string)
        //                }
        //            }
        //
        //            self.searchResultController.reloadDataWithArray(self.resultsArray)
        //
        //        }
        
        
        self.resultsArray.removeAll()
        gmsFetcher?.sourceTextHasChanged(searchText)
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: - CLLocationManagerDelegate
//1
extension ViewController: CLLocationManagerDelegate {
    // 2
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // 3
        guard status == .authorizedAlways else {
            return
        }
        // 4
        locationManager.startUpdatingLocation()
        
        //5
        googleMapsView.isMyLocationEnabled = true
        googleMapsView.settings.myLocationButton = true
    }
    
    // 6
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        // 7
        googleMapsView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        
        // 8
        locationManager.distanceFilter = 5
}
}
