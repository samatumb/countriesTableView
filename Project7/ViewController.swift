//
//  ViewController.swift
//  Project7
//
//  Created by Samat on 25.07.2020.
//  Copyright © 2020 somfish. All rights reserved.
//

import UIKit
import SDWebImage
import SDWebImageSVGCoder


class ViewController: UITableViewController {

    var countries = [Country]()
    var filteredCountries = [Country]()
    var imagesDict = [String: UIImage]()
    var isFiltered = false
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Countries"
        configureFilterButton()
        fetchPetitions()
        //loadImages()
    }
    
    func fetchPetitions() {
        let urlString = "https://restcountries.eu/rest/v2/all"

        DispatchQueue.global(qos: .background).async { [weak self] in
            if let url = URL(string: urlString) {
                if let data = try? Data(contentsOf: url) {
                    self?.parse(json: data)
                    self?.loadImages()
                    return
                }
            }
            DispatchQueue.main.async { [ weak self] in
            self?.showAlert(title: "Loading error", message: "There was a problem loading the feed, please check your connection and try againg")
            }
        }
    }
    
    
    func configureFilterButton() {
        let filterButton = UIBarButtonItem(title: isFiltered ? "Reset" : "Filter", style: .plain, target: self, action: isFiltered ? #selector(reset) : #selector(filter))
        if isFiltered { filterButton.tintColor = .systemRed }
        navigationItem.leftBarButtonItem = filterButton
    }
    
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonCountries = try? decoder.decode([Country].self, from: json) {
            print("here2")
            countries = jsonCountries.sorted(by: { (countryA, countryB) -> Bool in
                countryA.name < countryB.name
            })
            
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
        
        
        
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltered ? filteredCountries.count : countries.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let country = isFiltered ? filteredCountries[indexPath.row] : countries[indexPath.row]
        cell.textLabel?.text = country.name
        cell.detailTextLabel?.text = country.capital
        
        if let image = imagesDict[country.flag] { cell.imageView?.image = image }
        
        return cell
    }
    
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let vc = DetailViewController()
//        vc.detailItem = isFiltered ? filteredCountries[indexPath.row] : countries[indexPath.row]
//        navigationController?.pushViewController(vc, animated: true)
//    }
    
    
    func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
    }
    
    
    @objc func filter() {
        let ac = UIAlertController(title: "Filter", message: nil, preferredStyle: .alert)
        ac.addTextField()
        let filterAction = UIAlertAction(title: "Ok", style: .default) { [weak self, weak ac] _ in
            guard let self = self else { return }
            guard let filterText = ac?.textFields?[0].text, filterText.count > 2 else {
                self.showAlert(title: "Filter Invalid", message: "Filter Text must be at least 3 characters")
                return
            }
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                self.filteredCountries = self.countries.filter {$0.name.lowercased().contains(filterText.lowercased())}
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.isFiltered = true
                    self.tableView.reloadData()
                    self.configureFilterButton()
                }
            }

        }
        ac.addAction(filterAction)
        present(ac, animated: true)
    }
    
    
    @objc func reset() {
        filteredCountries.removeAll()
        self.isFiltered = false
        tableView.reloadData()
        self.configureFilterButton()
    }
    
    
    func loadImages() {
        let bitmapSize = CGSize(width: 500, height: 500)
        
        for country in countries {
            guard let url = URL(string: country.flag) else { continue }
        
            SDWebImageManager.shared.loadImage(with: url, options: [], context: [.imageThumbnailPixelSize : bitmapSize], progress: nil) { [weak self] image, data, error, cacheType, finished, url in
                
                guard let self = self else { return }
                guard error == nil else { return }
                guard let image = image else { return }
                
                if self.imagesDict[country.flag] == nil {
                    self.imagesDict[country.flag] = image
                    DispatchQueue.main.async { [weak self] in
                        self?.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(identifier: "Detail") as? DetailViewController {
            
            let country = isFiltered ? filteredCountries[indexPath.row] : countries[indexPath.row]
            if let image = imagesDict[country.flag] { vc.countryImage = image }
            vc.country = country
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
