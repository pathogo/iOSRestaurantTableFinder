	//
//  Desk.swift
//  iOSTableFinder
//
//  Created by Alexander Koglin on 08.04.19.
//  Copyright © 2019 Alexander Koglin. All rights reserved.
//

import UIKit

class DeskAlternative: Codable {
    
    var number: Int
    var name: String?
    var createdAt: Date = Date()
    
    init() {
        self.number = 1
        self.name = "Tisch \(number)"
    }
    
    init(number: Int) {
        self.number = number
        self.name = "Tisch \(number)"
    }
    
}
    
/// This is an alternative implementation, using a computed property for the name.
class Desk: Codable {
    
    var number: Int
    var name: String {
        get {
            return "Tisch \(number)"
        }
    }
    
    var createdAt: Date = Date()
    
    init() {
        self.number = 1
    }
    
    init(number: Int) {
        self.number = number
    }
    
}
