//
//  SwipeTableViewController.swift
//  zuTun
//
//  Created by Fahmi Sulaiman on 04.02.18.
//  Copyright © 2018 Fahmi Sulaiman. All rights reserved.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK:- TABLEVIEW DATASOURCE METHODS
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        var swipeAction = [SwipeAction]()
        if orientation == .right {
            let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
                self.updateModel(at: indexPath)
            }
            swipeAction.append(deleteAction)
        }

        if orientation == .left {
            let editAction = SwipeAction(style: .default, title: "Edit") { action, indexPath in
                self.editModel()
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
    
    func updateModel(at indexPath: IndexPath) {
        // Override this method in child class
    }
    
    func editModel() {
        // Override this method in child class
    }
}

