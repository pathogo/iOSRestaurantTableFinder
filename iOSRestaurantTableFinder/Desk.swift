	//
//  Desk.swift
//  iOSTableFinder
//
//  Created by Alexander Koglin on 08.04.19.
//  Copyright © 2019 Alexander Koglin. All rights reserved.
//

import UIKit

class Desk: NSObject {
    
    var number: Int
    var name: String?
    var createdAt: Date = Date()
    
    override init() {
        self.number = 1
        self.name = "Tisch \(number)"
    }
    
    init(number: Int) {
        self.number = number
        self.name = "Tisch \(number)"
    }
    
}
