//
//  CategoryViewController.swift
//  Todo It
//
//  Created by Alex Reckard on 9/25/19.
//  Copyright © 2019 Alex Reckard. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {

    let realm = try! Realm();
    
    // collection of results
    var categories : Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
//        navigationController?.navigationBar.prefersLargeTitles = true;
        
        loadCategories();
        
        tableView.rowHeight = 60;
        tableView.separatorStyle = .none;
    };
    
    // MARK: - TableView DataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // nil coalescing operator
        // if categories is not nil return the count else if it is nil return 1;
        return categories?.count ?? 1;
    };
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath);
        
        if let category = categories?[indexPath.row] {
            
            cell.textLabel?.text = category.name;
            
            guard let categoryColor = UIColor(hexString: category.color) else {fatalError()};
                   
            cell.backgroundColor = categoryColor;
            
            cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true);
        };
        
        return cell;
    };
    
    // MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self);
       
        tableView.deselectRow(at: indexPath, animated: true);
        
    };
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController;
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row];
        };
    };
    
    // MARK: - Add New Categories

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField();
           
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert);
           
        let action = UIAlertAction(title: "Add Category", style: .default) {
               (action) in
               
            let newCategory = Category();
            newCategory.name = textField.text!;
            newCategory.color = UIColor.randomFlat().hexValue();
        
            self.save(category: newCategory);
            print("Added New Category");
        };
           
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Category";
            textField = alertTextField;
            alertTextField.autocapitalizationType = .sentences;
            alertTextField.autocorrectionType = .yes;
            alertTextField.spellCheckingType = .yes
        };
           
        alert.addAction(action);
        present(alert, animated: true, completion: nil);
    };

    // MARK: - Data Manipulation
    
    // Crud Create/save data using Realm
    func save(category : Category) {
       
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving category, \(error)");
        };
        
        self.tableView.reloadData();
    };
    
    // cRud Read using Realm
    func loadCategories() {
        
        categories = realm.objects(Category.self);
        
        tableView.reloadData();
    };
    
    // cruD Delete from swipe using realm
    override func updateModel(at indexPath: IndexPath) {
        if let categoryDeletion = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                // cruD delete using realm
                self.realm.delete(categoryDeletion);
                print("Category deleted");
                };
            } catch {
                print("Error deleting category, \(error)");
            };
        };
    };
};
