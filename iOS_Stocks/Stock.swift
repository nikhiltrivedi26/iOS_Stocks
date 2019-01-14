//
//  Stock.swift
//  iOS_Stocks
//
//  Created by Nikhil Trivedi on 1/12/19.
//  Copyright © 2019 Nikhil Trivedi. All rights reserved.
//

import Foundation

class Stock {
    
    let symbol: String
    let numShares: Int
    let userPrice: Double
    let currPrice: String
    
    init(symbol: String, numShares: Int, userPrice: Double, currPrice: String) {
        self.symbol = symbol
        self.numShares = numShares
        self.userPrice = userPrice
        self.currPrice = currPrice
    }
}
