//
//  EditCategoryViewController.swift
//  zuTun
//
//  Created by Fahmi Sulaiman on 05.02.18.
//  Copyright © 2018 Fahmi Sulaiman. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import RealmSwift
import os.log

class EditNewCategoryViewController: UIViewController {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var titleTextField: UITextField!
    
    var category: Category?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateSaveButton()
    }
    
    // MARK:- NAVIGATION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }

        let newCategory = Category()
        newCategory.name = titleTextField.text!
        
        category = newCategory
    }
    
    // MARK:- ADDITIONAL CONTROLS METHODS
    func updateSaveButton() {
        let text = titleTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK:- TEXT FIELD
extension EditNewCategoryViewController: UITextFieldDelegate {
    // MARK:- TEXT FIELD DELEGATE METHODS
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButton()
    }
}
