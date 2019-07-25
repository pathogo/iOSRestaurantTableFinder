//
//  RestaurantStore.swift
//  iOSRestaurantTableFinder
//
//  Created by Lukas Schmidt on 25.07.19.
//  Copyright © 2019 Alexander Koglin. All rights reserved.
//

import Foundation


class RestaurantStore {
    static let shared = RestaurantStore()
    
    private init() {
        
    }
    
    func load() {
        if let data = UserDefaults.standard.value(forKey:"store.desks") as? Data {
            let value = try? PropertyListDecoder().decode(Array<Desk>.self, from: data)
            desks = value ?? []
        }
    }
    
    func store() {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(self.desks), forKey: "store.desks")
    }
    
    var desks: [Desk] = []
}
