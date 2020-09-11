//
//  DetailViewController.swift
//  Project7
//
//  Created by Samat on 25.07.2020.
//  Copyright © 2020 somfish. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {

    
    var countryImage: UIImage!
    var country: Country!
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var leftStackLabel: UILabel!
    @IBOutlet var rightStackLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        
        imageView.image = countryImage
        nameLabel.text = country.name
        
        leftStackLabel.text = "Capital: \(country.capital)\nPopulation: \(String(format: "%d", locale: Locale.current, country.population))"
        rightStackLabel.text = "Region: \(country.region)\nSubregion: \(country.subregion)"
    }
    
    
    @objc func shareTapped() {
        let shareText = """
        \(country.name.uppercased())
        Capital: \(country.capital)
        Population: \(String(format: "%d", locale: Locale.current, country.population))
        Region: \(country.region)
        Subregion: \(country.subregion)
        """
        
        let vc = UIActivityViewController(activityItems: [shareText], applicationActivities: [])
        
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }

}
