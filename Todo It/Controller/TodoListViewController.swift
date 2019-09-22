//
//  ViewController.swift
//  Todo It
//
//  Created by Alex Reckard on 9/16/19.
//  Copyright © 2019 Alex Reckard. All rights reserved.
//

import UIKit

class TodoListViewController : UITableViewController {
    
    var itemArr = [Item]();
    
    // save and retrieve data
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist");
        
    override func viewDidLoad() {
        super.viewDidLoad();
        
        print(dataFilePath!);
        
        // calls decoder
        loadItems();
    };
    
    //MARK - Tableview Datasource Methods
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
    
    //MARK - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // print(itemArr[indexPath.row])
     
        // not operator
        itemArr[indexPath.row].done = !itemArr[indexPath.row].done;
        
        // calls encoder
        saveItems();
        
        tableView.deselectRow(at: indexPath, animated: true);
        
    };
    //MARK - Add New Item
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField();
        
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert);
        
        let action = UIAlertAction(title: "Add Item", style: .default) {
            (action) in
            
            let newItem = Item();
            newItem.title = textField.text!;
            self.itemArr.append(newItem);
            print("Added New Item");
            
            // calls encoder
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
    
    // MARK - Model Manipulation Methods
    func saveItems() {
        let encoder = PropertyListEncoder();
        
        do {
            let data = try encoder.encode(itemArr);
            try data.write(to: dataFilePath!);
        } catch {
            print("Error encoding item array, \(error)");
        };
        
        // must reload data to display the appended arr item on the tableView
        self.tableView.reloadData();
    };
    
    func loadItems() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder();
            
            do {
                itemArr = try decoder.decode([Item].self, from: data);
            } catch {
                print("Error decoding item array, \(error)");
            };
        };
    };
};

