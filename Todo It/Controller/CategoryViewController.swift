//
//  CategoryViewController.swift
//  Todo It
//
//  Created by Alex Reckard on 9/25/19.
//  Copyright © 2019 Alex Reckard. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    var categories = [Category]();

    // in order to use persistentContainer in this file
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
           
    override func viewDidLoad() {
        super.viewDidLoad();
        
        loadCategories();
    };
    
    // MARK: - TableView DataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories.count;
    };
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath);
    
        let category = categories[indexPath.row];

        cell.textLabel?.text = category.name;
   
        return cell;
    };
    
    
    // MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self);
        
       // print(categories[indexPath.row])
    
       // cruD Delete data from core data has to be in this order
       // context.delete(categories[indexPath.row]);
       // categories.remove(at: indexPath.row);
       
       // crUd update data with core data
       saveCategories();
       
       tableView.deselectRow(at: indexPath, animated: true);
        
    };
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController;
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories[indexPath.row]
        };
    };
    
    // MARK: - Add New Categories

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField();
           
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert);
           
        let action = UIAlertAction(title: "Add Category", style: .default) {
               (action) in
               
            let newCategory = Category(context: self.context);
            newCategory.name = textField.text!;
            self.categories.append(newCategory);
            print("Added New Category");
               
            self.saveCategories();
        };
           
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Category";
            textField = alertTextField;
            alertTextField.autocapitalizationType = .sentences;
            alertTextField.autocorrectionType = .yes;
        };
           
        alert.addAction(action);
        present(alert, animated: true, completion: nil);
    };

    // MARK: - Data Manipulation
    
    // Crud Create/save data with core data
    func saveCategories() {
       
        do {
            try context.save();
        } catch {
            print("Error saving category, \(error)");
        };
        
        // must reload data to display the appended arr item on the tableView
        self.tableView.reloadData();
    };
    
    // cRud Read from core data
    // internal with param and has a default value = Category.fetchRequest() so we can bypass the param
    func loadCategories(with request : NSFetchRequest<Category> = Category.fetchRequest()) {
                
        do {
            categories = try context.fetch(request);
        } catch {
            print("Error fetching category, \(error)");
        };
        
        tableView.reloadData();
    };
};
