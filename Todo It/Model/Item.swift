//
//  Item.swift
//  Todo It
//
//  Created by Alex Reckard on 9/29/19.
//  Copyright © 2019 Alex Reckard. All rights reserved.
//

import Foundation
import RealmSwift

class Item : Object {
    @objc dynamic var title : String = "";
    @objc dynamic var done : Bool = false;
    @objc dynamic var date : Date?
    // connect the child to the parent
    // Category is the parent and the children are the items
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
};
