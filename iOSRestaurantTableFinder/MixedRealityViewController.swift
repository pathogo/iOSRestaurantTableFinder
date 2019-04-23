//
//  MixedRealityViewController.swift
//  iOSRestaurantTableFinder
//
//  Created by Alexander Koglin on 15.04.19.
//  Copyright © 2019 Alexander Koglin. All rights reserved.
//

import UIKit
import SceneKit
import Foundation

class MixedRealityViewController: UIViewController {

    @IBAction func dismissSceneKitView(_ sender: Any) {
        self.dismiss(animated: true)
    }

}

extension float2 {
    
    init(repeating v: CGPoint) {
        self.init(Float(v.x), Float(v.y))
    }
}
