//
//  ViewController.swift
//  Todo It
//
//  Created by Alex Reckard on 9/16/19.
//  Copyright © 2019 Alex Reckard. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController : UITableViewController {
    
    var itemArr = [Item]();
    
    var selectedCategory : Category? {
        didSet {
            loadItems();
        }
    };
    
    // in order to use persistentContainer in this file
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // path to where data is being stored
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask));

    };
    
    // MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return itemArr.count;
    };
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath);
        
        let item  = itemArr[indexPath.row];

        cell.textLabel?.text = item.title;
        
        cell.accessoryType = item.done ? .checkmark : .none;
        
        return cell;
    };
    
    // MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // print(itemArr[indexPath.row])
     
        // cruD Delete data from core data has to be in this order
        // context.delete(itemArr[indexPath.row]);
        // itemArr.remove(at: indexPath.row);
        
        // not operator
        itemArr[indexPath.row].done = !itemArr[indexPath.row].done;
        
        // crUd update data with core data 
        saveItems();
        
        tableView.deselectRow(at: indexPath, animated: true);
        
    };
    
    // MARK: - Add New Item
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField();
        
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert);
        
        let action = UIAlertAction(title: "Add Item", style: .default) {
            (action) in
            
            let newItem = Item(context: self.context);
            newItem.title = textField.text!;
            newItem.done = false;
            // relationship in data model
            newItem.parentCategory = self.selectedCategory;
            self.itemArr.append(newItem);
            print("Added New Item");
            
            self.saveItems();
        };
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item";
            textField = alertTextField;
            alertTextField.autocapitalizationType = .sentences;
            alertTextField.autocorrectionType = .yes;
        };
        
        alert.addAction(action);
        present(alert, animated: true, completion: nil);
    };
    
    // MARK: - Data Manipulation Methods
    
    // Crud Create/save data with core data
    func saveItems() {
       
        do {
            try context.save();
        } catch {
            print("Error saving context, \(error)");
        };
        
        // must reload data to display the appended arr item on the tableView
        self.tableView.reloadData();
    };
    
    // cRud Read from core data
    // internal with param and has default values
    func loadItems(with request : NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil ) {
        
        // to load items for right category and using compound predicate with an optional default value to fix bug
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!);
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate]);
        } else {
            request.predicate = categoryPredicate;
        };
        
        do {
            itemArr = try context.fetch(request);
        } catch {
            print("Error fetching request, \(error)");
        };
        
        tableView.reloadData();
    };
};

    // MARK: - Search Bar

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request : NSFetchRequest<Item> = Item.fetchRequest();
        
        // %@ object’s attribute name is equal to value passed in
        // cd means case and diacritic, so string comparisons will become insensitive
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!);

        // sortDes expect an arr
        // title will be organized alphabetical order
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)];
        
        // external with param
        loadItems(with: request, predicate: predicate);
    };
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems();
            
            // get main thread/queue to update UI
            DispatchQueue.main.async {
                // goes to original state before activated
                // removes the flashing cursor and keyboard
                searchBar.resignFirstResponder();
            };
        };
    };
};
