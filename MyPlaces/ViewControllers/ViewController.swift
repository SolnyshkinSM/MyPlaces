//
//  ViewController.swift
//  MyPlaces
//
//  Created by Administrator on 01.10.2020.
//  Copyright © 2020 Administrator. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    private var searchController = UISearchController(searchResultsController: nil)
    private var places: Results<Place>!
    private var filteredPlaces: Results<Place>!
    private var ascendingSorting = true
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var reversSorted: UIBarButtonItem!
    @IBOutlet var masterTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        places = realm.objects(Place.self)
        
        masterTableView.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    // MARK: - Methods
    
    @IBAction func unwindSegue(_ unwindSegue: UIStoryboardSegue) {
        
        guard let newPlaceVC = unwindSegue.source as? NewPlaceTableViewController else { return }
        newPlaceVC.saveNewPlace()
        masterTableView.reloadData()
    }
    
    @IBAction func reversAction(_ sender: UIBarButtonItem) {
        
        ascendingSorting.toggle()
        
        if segmentedControl.selectedSegmentIndex == 0 {
            reversSorted.image = #imageLiteral(resourceName: "AZ")
        } else {
            reversSorted.image = #imageLiteral(resourceName: "ZA")
        }
        
        sorted()
    }
    
    @IBAction func segmentedAction(_ sender: UISegmentedControl) {
        sorted()
    }
    
    private func sorted() {
        
        guard let tempplaces = isFiltering ? filteredPlaces : places else { return }
                
        if segmentedControl.selectedSegmentIndex == 0 {
            places = tempplaces.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else {
            places = tempplaces.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        
        masterTableView.reloadData()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetail" {
            
            guard let indexPath = masterTableView.indexPathForSelectedRow else { return }
        
            let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
            
            let newPlaceVC = segue.destination as! NewPlaceTableViewController
            newPlaceVC.currentPlace = place
        }
    }
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering ? filteredPlaces.count : places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CustomTableViewCell
        
        let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
        
        cell.namePlace.text = place.name
        cell.locationPlace.text = place.location
        cell.typePlace.text = place.type
        cell.imagePlace.image = UIImage(data: place.imageData!)
        cell.cosmosView.rating = place.rating
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
        
        let deleteAction = UIContextualAction.init(style: .destructive, title: "delete") { (action, view, completionHandler) in
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        return UISwipeActionsConfiguration.init(actions: [deleteAction])
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetail", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UISearchResultsUpdating

extension ViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForText(searchController.searchBar.text!)
    }
    
    private func filterContentForText(_ searchText: String) {
        
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        
        masterTableView.reloadData()
    }
}
