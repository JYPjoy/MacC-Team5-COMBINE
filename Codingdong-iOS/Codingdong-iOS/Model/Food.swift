//
//  Food.swift
//  Codingdong-iOS
//
//  Created by Joy on 11/26/23.
//

import Foundation
import SwiftData

@Model
final class FoodList {
    var haveFood: Bool
    @Relationship(deleteRule: .cascade, inverse: \Food.foodList)
    var food: [Food]?
    
    init(haveFood: Bool) {
        self.haveFood = haveFood
    }
}

@Model
final class Food {
    var foodList: FoodList?
    var image: String
    var concept: String
    
    init(foodList: FoodList? = nil, image: String, concept: String) {
        self.image = image
        self.concept = concept
        self.foodList = foodList
    }
}

