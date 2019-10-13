//
//  Category.swift
//  Todo It
//
//  Created by Alex Reckard on 9/29/19.
//  Copyright © 2019 Alex Reckard. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object {
    @objc dynamic var name : String = "";
    @objc dynamic var color : String = "";
    // relationship
    let items = List<Item>()
};




