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
    
    // MARK:- Table View Datasource Methods
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
    
    // MARK:- Data Manipulation Methods
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
    
    // MARK:- Additional Control Methods
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
//        var textField = UITextField()
//        let alert = UIAlertController(title: "New category", message: "", preferredStyle: .alert)
//        let action = UIAlertAction(title: "Add", style: .default) { (action) in
//            let newCategory = Category()
//            if let enteredCategoryName = textField.text {
//                if !enteredCategoryName.isEmpty {
//                    newCategory.name = enteredCategoryName
//
//                    self.saveCategory(category: newCategory)
//                }
//            }
//        }
//
//        alert.addTextField { (alertTextField) in
//            alertTextField.placeholder = "Category title"
//            alertTextField.autocapitalizationType = .words
//            textField = alertTextField
//        }
//
//        alert.addAction(action)
//
//        present(alert, animated: true, completion: nil)
        performSegue(withIdentifier: "goToEditNewCategory", sender: self)
    }
}

// MARK:- Search Bar
extension CategoryViewController: UISearchBarDelegate {
    // MARK:- Search Bar Delegate Methods
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

