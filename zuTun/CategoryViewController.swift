//
//  CategoryViewController.swift
//  zuTun
//
//  Created by Fahmi Sulaiman on 30.01.18.
//  Copyright © 2018 Fahmi Sulaiman. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    var categoryArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let sortDescriptor = [NSSortDescriptor(key: "name", ascending: true)]
    
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.rowHeight = 60.0
        navigationItem.leftBarButtonItem = editButtonItem
        deleteButton.isEnabled = false
        //addInitialCategories()
        loadCategory(sorter: sortDescriptor)
    }
    
    // MARK:- Table View Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        tableView.insertRows(at: [indexPath], with: .fade)
        cell.textLabel?.text = categoryArray[indexPath.row].name
        
        return cell
    }
    
    // MARK:- Table View Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            deleteButton.isEnabled = true
            categoryArray[indexPath.row].toDelete = true
        } else {
            deleteButton.isEnabled = false
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // TODO:- Still needs to figure out how best to rearrange
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let category = categoryArray[sourceIndexPath.row]
        categoryArray.remove(at: sourceIndexPath.row)
        categoryArray.insert(category, at: destinationIndexPath.row)
    }
    
    // MARK:- Test Methods
    func addInitialCategories() {
        let category1 = Category(context: self.context)
        category1.name = "Personal"
        categoryArray.append(category1)
        
        let category2 = Category(context: self.context)
        category2.name = "Shopping List"
        categoryArray.append(category2)
        
        saveCategory()
    }
    
    // MARK:- Data Manipulation Methods
    func saveCategory() {
        do {
            try context.save()
        } catch {
            print("Saving categories failed!: \(error)")
        }
        loadCategory(sorter: sortDescriptor)
    }
    
    func loadCategory(with request: NSFetchRequest<Category> = Category.fetchRequest(), predicate: NSPredicate? = nil, sorter: [NSSortDescriptor]? = nil) {
        if let additionalPredicate = predicate {
            request.predicate = additionalPredicate
        }
        
        if let additionalSorter = sorter {
            request.sortDescriptors = additionalSorter
        }
        
        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("Loading categories failed!: \(error)")
        }
        tableView.reloadData()
    }
    
    func deleteCategory() {
        for (index, category) in categoryArray.enumerated() {
            if category.toDelete {
                context.delete(category)
                categoryArray.remove(at: index)
                saveCategory()
            }
        }
        deleteButton.isEnabled = false
        tableView.isEditing = false
    }
    
    
    // MARK:- Additional Control Methods
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "New category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let newCategory = Category(context: self.context)
            if let enteredCategoryName = textField.text {
                if !enteredCategoryName.isEmpty {
                    newCategory.name = enteredCategoryName
                    newCategory.toDelete = false
                    
                    self.categoryArray.append(newCategory)
                    self.saveCategory()
                }
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Category title"
            alertTextField.autocapitalizationType = .words
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIBarButtonItem) {
        deleteCategory()
    }
}

// MARK:- Search Bar
extension CategoryViewController: UISearchBarDelegate {
    // MARK:- Search Bar Delegate Methods
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchedCategory = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
        
        loadCategory(predicate: searchedCategory, sorter: sortDescriptor)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        loadCategory(sorter: sortDescriptor)
        searchBar.endEditing(true)
        searchBar.text = nil
        searchBar.setShowsCancelButton(false, animated: true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchedCategory = NSPredicate(format: "name CONTAINS[cd] %@", searchText)
        
        loadCategory(predicate: searchedCategory, sorter: sortDescriptor)
        
        if searchBar.text?.count == 0 {
            loadCategory(sorter: sortDescriptor)
        }
    }
}

