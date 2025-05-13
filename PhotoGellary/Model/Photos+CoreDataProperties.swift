//
//  Photos+CoreDataProperties.swift
//  PhotoGellary
//
//  Created by TONMOY BISHWAS on 13/8/24.
//
//

import Foundation
import CoreData


extension Photos {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photos> {
        return NSFetchRequest<Photos>(entityName: "Photos")
    }

    @NSManaged public var image: String?

}

extension Photos : Identifiable {

}
