//
//  ViewController.swift
//  iOS_Stocks
//
//  Created by Nikhil Trivedi on 1/11/19.
//  Copyright © 2019 Nikhil Trivedi. All rights reserved.
//

import UIKit
import ChameleonFramework

class ViewController: UITableViewController {
    
    var stockArray = [Stock]()
    var currValue: Any = ""
    let semaphore = DispatchSemaphore(value: 0)
    
    @IBOutlet var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.delegate = self
        myTableView.separatorStyle = .singleLine
    }
    
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        
        // this function presents the alert and makes the object
        // it does not do anything with the text field
        
        var textField1 = UITextField()
        var textField2 = UITextField()
        var textField3 = UITextField()
        
        let alert = UIAlertController(title: "Add Stock", message: "", preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (cancel) in
            alert.dismiss(animated: true, completion: nil)
        }
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            // error checking
            if(textField1.text == "" || textField2.text == "" || textField3.text == "") {
                print("error - empty field ")
            }
            else if(Int(textField2.text!) == nil) {
                print("error - stock quantity must be an int")
            }
            else if(Double(textField3.text!) == nil) {
                print("error - num shares must be a double")
            }
                // determine the current price of the stock
            else {
                var nowPrice: String = ""
                self.currValue = ""
                self.findCurrPrice(symbol: textField1.text!)
                self.semaphore.wait()
                nowPrice = self.currValue as! String
                if(nowPrice == "") {
                    print("error - could not find a stock with the given name")
                }
                else {
                    let stock = Stock(symbol: (textField1.text!), numShares: Int(textField2.text!)!, userPrice: Double(textField3.text!)!, currPrice: nowPrice)
                    self.stockArray.append(stock)
                    self.tableView.reloadData()
                }
            }
        }
        
        alert.addAction(action)
        alert.addAction(cancel)
        
        alert.addTextField { (field) in
            textField1 = field
            textField1.placeholder = "Enter Stock Symbol (ex: MSFT, AAPL)"
        }
        alert.addTextField { (field) in
            textField2 = field
            textField2.placeholder = "Number of Shares Owned (ex: 10, 50)"
        }
        alert.addTextField { (field) in
            textField3 = field
            textField3.placeholder = "Price Paid (ex: 75.23, 23.10)"
        }
        
        present(alert, animated: true, completion: nil)
        tableView.reloadData()
    }
    
    func isStringAnInt(string: String) -> Bool {
        return Int(string) != nil
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stockArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Stock", for: indexPath)
        
        var netGain: Double
        netGain = (Double(stockArray[indexPath.row].currPrice)! - Double(stockArray[indexPath.row].userPrice)) * Double(stockArray[indexPath.row].numShares)
        netGain = netGain.rounded()
        let netGainString: String = String(netGain)
        
        cell.textLabel?.text = "[" + stockArray[indexPath.row].symbol + "] [" + String(stockArray[indexPath.row].numShares) + "] [" + String(stockArray[indexPath.row].userPrice.rounded()) + "] [" + netGainString + "]"
        
        if(netGain < 0) {
            cell.backgroundColor = FlatWatermelon()
        } else if(netGain == 0){
            cell.backgroundColor = FlatWhite()
        } else {
            cell.backgroundColor = FlatGreen()
        }
        
        return cell
    }
    
    func findCurrPrice(symbol: String) {
        
        let apiKey = "JWPUFO3613UG07D8"
        let url = URL(string: "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=\(symbol)&apikey=\(apiKey)")
        
        if(url == nil) {
            print("error finding stock information")
            self.semaphore.signal()
        } else {
            URLSession.shared.dataTask(with: (url)!) { (data, response, error) in
                if error != nil {
                    print ("error")
                } else {
                    if let content = data {
                        do {
                            let myJson = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                            if let time = myJson["Global Quote"] as? NSDictionary  {
                                for (key, value) in time {
                                    let modifiedKey: Any = (key as Any)
                                    if ((modifiedKey as AnyObject) as! String) == "02. open" {
                                        self.currValue = value
                                        self.semaphore.signal()
                                    }
                                }
                            }
                        }  catch  {}
                    } else {
                        print("error finding stock information")
                    }
                }
            }.resume()
        }
    }
    
}

