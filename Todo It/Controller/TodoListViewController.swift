//
//  ViewController.swift
//  Todo It
//
//  Created by Alex Reckard on 9/16/19.
//  Copyright © 2019 Alex Reckard. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController : SwipeTableViewController {
    
    var todoItems : Results<Item>?;
    let realm = try! Realm();
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory : Category? {
        didSet {
            loadItems();
        }
    };
        
    override func viewDidLoad() {
        super.viewDidLoad();
        
//        navigationController?.navigationBar.prefersLargeTitles = true;
    
        // path to where data is being stored
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask));
        
        tableView.rowHeight = 60;
        tableView.separatorStyle = .none;

    };
    
    override func viewDidAppear(_ animated: Bool) {
        
        title = selectedCategory?.name;
        
        guard let colorHex = selectedCategory?.color else {fatalError()};
            
        updateNavBar(withHexCode: colorHex);
        
    };
    
    override func viewWillDisappear(_ animated: Bool) {
        
        updateNavBar(withHexCode: "FFFFFF");
    
    };
    
    // MARK: - Nav Bar Setup
    func updateNavBar(withHexCode colorHex: String) {
        
        guard let navBar = navigationController?.navigationBar else
            {fatalError("Navigation controller does not exist.")};
        
        guard let navBarColor = UIColor(hexString: colorHex) else {fatalError()};
        
        navBar.barTintColor = navBarColor;
            
        navBar.tintColor = ContrastColorOf(navBarColor , returnFlat: true);
        
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)];
        
        searchBar.barTintColor = navBarColor;
        
    };

    // MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return todoItems?.count ?? 1;
    };
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath);
        
        if let item  = todoItems?[indexPath.row] {

            cell.textLabel?.text = item.title;
            
            if let color = UIColor(hexString:  selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = color;
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true);
            };
            
            cell.accessoryType = item.done ? .checkmark : .none;
        } else {
            cell.textLabel?.text = "No Items Added Yet";
        };
       
        return cell;
    };
    
    // MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // if not nil then try to save done status with realm in a do/catch block
        // crUd update using realm
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    // realm.delete(item) // cruD delete using realm
                    item.done = !item.done;
                };
            } catch {
                print("Error saving done status, \(error)")
            };
        };
        
        tableView.reloadData();
    };
    
    // MARK: - Add New Item
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField();
        
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert);
        
        let action = UIAlertAction(title: "Add Item", style: .default) {
            (action) in
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item();
                        newItem.title = textField.text!;
                        newItem.date = Date();
                        currentCategory.items.append(newItem)
                        print("Added New Item");
                    };
                } catch {
                    print("Error saving new item, \(error)")
                };
            };
            
            self.tableView.reloadData();
        };
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item";
            textField = alertTextField;
            alertTextField.autocapitalizationType = .sentences;
            alertTextField.autocorrectionType = .yes;
            alertTextField.spellCheckingType = .yes;
        };
        
        alert.addAction(action);
        present(alert, animated: true, completion: nil);
    };
    
    // MARK: - Data Manipulation Methods
    
    // Crud Create/save data using Realm
    func save(item : Item) {
       
        do {
            try realm.write {
                realm.add(item)
            }
        } catch {
            print("Error saving item, \(error)");
        };
        
        // must reload data to display the appended arr item on the tableView
        self.tableView.reloadData();
    };
    
    // cRud Read from realm
    func loadItems() {
            
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true);
        
        tableView.reloadData();
    };
    
    // cruD Delete from swipe using realm
    override func updateModel(at indexPath: IndexPath) {
        if let itemDeletion = self.todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    // cruD delete using realm
                    self.realm.delete(itemDeletion);
                    print("Item deleted");
                };
            } catch {
                print("Error deleting item, \(error)");
            };
        };
    };
};

    // MARK: - Search Bar

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // filter the title of items based on the predicate that contains specific letters and sort it by date
        todoItems = todoItems?.filter("title CONTAINS[cd] %@" , searchBar.text!).sorted(byKeyPath: "date", ascending: false);
        
        tableView.reloadData();
        
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
