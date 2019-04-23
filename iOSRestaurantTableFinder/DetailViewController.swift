//
//  DetailViewController.swift
//  iOSRestaurantTableFinder
//
//  Created by Alexander Koglin on 09.04.19.
//  Copyright © 2019 Alexander Koglin. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var virtualRealityLabel: UIBarButtonItem!

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = detail.name
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
    }

    var detailItem: Desk? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}

