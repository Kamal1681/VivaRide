//
//  SearchResultsController.swift
//  W8D2-Ride-Share
//
//  Created by Kamal Maged on 2019-03-01.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

protocol LocateOnTheMap{
    func locateWithLongitude(lon:Double, andLatitude lat:Double, andTitle title: String)
}

class SearchResultsController: UITableViewController {
    
    var searchResults: [String]!
    var delegate: LocateOnTheMap!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchResults = Array()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.searchResults.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)

        cell.textLabel?.text = self.searchResults[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        self.dismiss(animated: true, completion: nil)
        
        let correctedAddress:String = self.searchResults[indexPath.row].addingPercentEncoding(withAllowedCharacters: .symbols) ?? ""
        let url = NSURL(string: "https://maps.googleapis.com/maps/api/geocode/json?address=\(String(describing: correctedAddress))&sensor=false&key=\(Constants.googleApiKey)")
        
        let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
           
            do {
                if data != nil{
                    let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as!  NSDictionary
                    let results = dict["results"] as! NSArray
                    let geometry = results.value(forKey: "geometry") as! NSArray
                    //let city = results[0].address_components value(forKey: "address_components")
                    let location = geometry.value(forKey: "location") as! NSArray
                    let lat = location.value(forKey: "lat") as! NSArray
                    let latitude = lat.object(at: 0) as! Double
                    
                    
                    let lon = location.value(forKey: "lng") as! NSArray
                    let longitude = lon.object(at: 0) as! Double
     
                
                    self.delegate.locateWithLongitude(lon: longitude, andLatitude: latitude, andTitle: self.searchResults[indexPath.row] )
                }
            }catch {
                print("Error Invalid Address")
            }
        }
        task.resume()
    }

    func reloadDataWithArray(array:[String]){
        self.searchResults = array
        self.tableView.reloadData()
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
