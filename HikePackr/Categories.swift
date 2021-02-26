//
//  Categories.swift
//  HikePackr
//
//  Created by Emelie on 2021-02-26.
//

import Foundation

class Categories {
    var categories: [Category]
    
    init() {
        categories = [Category(name: "Other", color: "green"), Category(name: "Clothing and footwear", color: "blue"), Category(name: "Emergency and first aid", color: "red"), Category(name: "Food and water", color: "purple"), Category(name: "Health and hygiene", color: "pink"), Category(name: "Hiking gear", color: "gray"), Category(name: "Navigation", color: "orange"), Category(name: "Personal items", color: "yellow")]
    }
}
