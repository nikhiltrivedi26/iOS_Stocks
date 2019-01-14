//
//  ViewController.swift
//  iOS_Stocks
//
//  Created by Nikhil Trivedi on 1/11/19.
//  Copyright © 2019 Nikhil Trivedi. All rights reserved.
//

import UIKit

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
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            // determine the current price of the stock
            self.findCurrPrice(symbol: textField1.text!)
            self.semaphore.wait()
            
            let nowPrice: String = self.currValue as! String
        
            let stock = Stock(symbol: textField1.text!, numShares: Int(textField2.text!)!, userPrice: Double(textField3.text!)!, currPrice: nowPrice)
            
            self.stockArray.append(stock)
            self.tableView.reloadData()
        }
        
        alert.addAction(action)
        
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stockArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Stock", for: indexPath)
        
        // 11 is ideal for first break
        var netGain: Double
        netGain = ((Double(stockArray[indexPath.row].currPrice)! * Double(stockArray[indexPath.row].numShares))) - Double(stockArray[indexPath.row].userPrice * Double(stockArray[indexPath.row].numShares))
        let netGainString: String = String(netGain)
        
        cell.textLabel?.text = "[" + stockArray[indexPath.row].symbol + "] [" + String(stockArray[indexPath.row].numShares) + "] [" + String(stockArray[indexPath.row].userPrice) + "] [" + netGainString + "]"
        
        if(netGain < 0) {
            cell.backgroundColor = UIColor.red
        } else if(netGain == 0){
            cell.backgroundColor = UIColor.gray
        } else {
            cell.backgroundColor = UIColor.green
        }
        
        return cell
    }
    
    func findCurrPrice(symbol: String) {
        
        let apiKey = "JWPUFO3613UG07D8"
        let url = URL(string: "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=\(symbol)&apikey=\(apiKey)")
        
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print ("error")
            } else {
                if let content = data {
                    do {
                        let myJson = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        if let time = myJson["Global Quote"] as? NSDictionary  {
                            for (key, value) in time {
                                let test2: Any = (key as Any)
                                if ((test2 as AnyObject) as! String) == "02. open" {
                                    self.currValue = value
                                    self.semaphore.signal()
                                }
                            }
                        }
                    }  catch  {
                        print(error.localizedDescription)
                    }
                }
            }
        }.resume()
    }
    
}

