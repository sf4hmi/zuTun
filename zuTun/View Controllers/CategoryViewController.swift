//
//  CategoryViewController.swift
//  zuTun
//
//  Created by Fahmi Sulaiman on 30.01.18.
//  Copyright © 2018 Fahmi Sulaiman. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: SwipeTableViewController {

    var categories: Results<Category>?
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.rowHeight = 60.0
        loadCategory()
    }
    
    // MARK:- TABLE VIEW DATASOURCE METHODS
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = category.name
        } else {
            print("No category set yet")
        }
        
        return cell
    }
    
    // MARK:- DATA MANIPULATION METHODS
    func saveCategory(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Saving categories failed!: \(error)")
        }
        loadCategory()
    }
    
    func loadCategory() {
        categories = realm.objects(Category.self).sorted(byKeyPath: "name", ascending: true)
        tableView.reloadData()
    }
    
    // Delete data from Swipe
    override func updateModel(at indexPath: IndexPath) {
        if let deletedCategory = categories?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(deletedCategory)
                }
            } catch {
                print("Error deleting category: \(error)")
            }
        }
    }
    
    override func editModel() {
        <#code#>
    }
    
    // MARK:- ADDITIONAL CONTROL METHODS
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goToEditNewCategory", sender: self)
    }
    
    // MARK:- NAVIGATION
    @IBAction func unwindToCategoryList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? EditNewCategoryViewController, let category = sourceViewController.category {
            saveCategory(category: category)
        }
    }
}

// MARK:- SEARCH BAR
extension CategoryViewController: UISearchBarDelegate {
    // MARK:- SEARCH BAR DELEGATE METHODS
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        loadCategory()
        searchBar.endEditing(true)
        searchBar.text = nil
        searchBar.setShowsCancelButton(false, animated: true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        searchBar.autocapitalizationType = .none
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        categories = categories?.filter("name CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "name", ascending: true)
        tableView.reloadData()
        
        if searchBar.text?.count == 0 {
            loadCategory()
        }
    }
}

