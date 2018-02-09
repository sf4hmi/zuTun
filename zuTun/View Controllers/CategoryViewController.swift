//
//  CategoryViewController.swift
//  zuTun
//
//  Created by Fahmi Sulaiman on 30.01.18.
//  Copyright © 2018 Fahmi Sulaiman. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit
import os.log

class CategoryViewController: UITableViewController, SwipeTableViewCellDelegate {

    var categories: Results<Category>?
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 60.0
        loadCategory()
    }
    
    // MARK:- TABLE VIEW DATASOURCE METHODS
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        
        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = category.name
        } else {
            print("No category set yet")
        }
        
        return cell
    }
    
    // MARK:- TABLE VIEW CELL DELEGATE METHODS
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        var swipeAction = [SwipeAction]()
        if orientation == .right {
            let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
                self.deleteEntry(at: indexPath)
            }
            swipeAction.append(deleteAction)
        }
        
        if orientation == .left {
            let editAction = SwipeAction(style: .default, title: "Edit") { action, indexPath in
                self.editEntry(at: indexPath)
            }
            swipeAction.append(editAction)
        }
        
        return swipeAction
    }
    
    // If you override this method, do not reload the tableView anymore
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        if orientation == .right {
            options.expansionStyle = .destructive
            options.transitionStyle = .border
        }
        if orientation == .left {
            options.expansionStyle = .fill
            options.transitionStyle = .border
        }
        return options
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
    func deleteEntry(at indexPath: IndexPath) {
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
    
    func editEntry(at indexPath: IndexPath) {
        performSegue(withIdentifier: "goToEditCategory", sender: indexPath)
        loadCategory()
    }
    
    // MARK:- ADDITIONAL CONTROL METHODS
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goToNewCategory", sender: self)
    }
    
    // MARK:- NAVIGATION
    @IBAction func unwindToCategoryList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? EditNewCategoryViewController, let newCategory = sourceViewController.category {
            let selectedIndex = sourceViewController.editIndex
            if selectedIndex >= 0  {
                if let editedCategory = categories?[selectedIndex] {
                    do {
                        try realm.write {
                            editedCategory.name = newCategory.name
                        }
                    } catch {
                        print("Saving data failed! => \(error)")
                    }
                    loadCategory()
                }
            } else {
                saveCategory(category: newCategory)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch (segue.identifier ?? "") {
            case "goToNewCategory":
                os_log("Adding a new category.", log: OSLog.default, type: .debug)
            case "goToEditCategory":
                guard let editCategoryViewController = segue.destination as? EditNewCategoryViewController else {
                    fatalError("Unexpected destination: \(segue.destination)")
                }
                guard let indexPath = sender as? IndexPath else {
                    fatalError("The selected cell is not being displayed by the table")
                }
                if let editedCategory = categories?[indexPath.row] {
                    editCategoryViewController.category = editedCategory
                    editCategoryViewController.editIndex = indexPath.row
                }
                editCategoryViewController.navigationItem.title = "Edit Category"
            default:
                fatalError("Unexpected Segue Identifier; \(segue.identifier!)")
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
