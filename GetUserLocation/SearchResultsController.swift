import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import SwiftyJSON




protocol LocateOnTheMap{
    func locateWithLongitude(_ lon:Double, andLatitude lat:Double, andTitle title: String)
}

class SearchResultsController: UITableViewController{
    let googleAPIKey = "API Key"
    var searchResults: [String]!
    var delegate: LocateOnTheMap!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchResults = Array()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.searchResults.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
        
        cell.textLabel?.text = self.searchResults[indexPath.row]
        return cell
    }
    
   override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath)
    {
        self.dismiss(animated: true, completion: nil)
        
        guard let correctedAddress = self.searchResults[indexPath.row].addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            else {
            print("Error. cannot cast name into String")
            return
        }
       // let urlpath = "https://maps.googleapis.com/maps/api/geocode/json?address=\(self.searchResults[indexPath.row])&sensor=false".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
           let urlpath =  "https://maps.googleapis.com/maps/api/geocode/json?address=\(correctedAddress)&sensor=false&key=\(self.googleAPIKey)"
        
        let url = URL(string: urlpath)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) -> Void in
            do {
                if data != nil{
                    let dic = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                    let status = dic.value(forKey: "status") as! String
                   // print("Error")
                    print("\(status)")
                   if status == "OK"
                    {
                        
                        let lat =   (((((dic.value(forKey: "results") as! NSArray).object(at: 0) as! NSDictionary).value(forKey: "geometry") as! NSDictionary).value(forKey: "location") as! NSDictionary).value(forKey: "lat")) as? Double
                        let lon =   (((((dic.value(forKey: "results") as! NSArray).object(at: 0) as! NSDictionary).value(forKey: "geometry") as! NSDictionary).value(forKey: "location") as! NSDictionary).value(forKey: "lng")) as? Double
                        if let latitude = lat
                        {
                            if let longitude = lon
                            {
                                self.delegate.locateWithLongitude(longitude, andLatitude: latitude, andTitle: self.searchResults[indexPath.row])
                            }
                        }
                    }
                }
            }
            catch
            {
                print("Error")
            }
        }
        task.resume()
    }
    

    
    
    func reloadDataWithArray(_ array:[String]){
        self.searchResults = array
        self.tableView.reloadData()
}
}
