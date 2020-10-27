//
//  ViewController.swift
//  MyPlaces
//
//  Created by Administrator on 01.10.2020.
//  Copyright © 2020 Administrator. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let restaurantNames = [
        "Burger Heroes", "Kitchen", "Bonsai", "Дастархан",
        "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
        "Speak Easy", "Morris Pub", "Вкусные истории",
        "Классик", "Love&Life", "Шок", "Бочка"
    ]

    @IBOutlet var masterTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        masterTableView.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
    }
    
    // MARK: - Methods
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurantNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CustomTableViewCell
        cell.namePlace.text = restaurantNames[indexPath.row]
        cell.imagePlace.image = UIImage(named: restaurantNames[indexPath.row])
        cell.imagePlace.layer.cornerRadius = cell.imagePlace.frame.size.height / 2
        cell.imagePlace.clipsToBounds = true
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}
