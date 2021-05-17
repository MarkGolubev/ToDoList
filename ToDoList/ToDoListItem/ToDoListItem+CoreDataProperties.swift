//
//  ToDoListItem+CoreDataProperties.swift
//  ToDoList
//
//  Created by Марк Голубев on 13.05.2021.
//
//

import Foundation
import CoreData


extension ToDoListItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDoListItem> {
        return NSFetchRequest<ToDoListItem>(entityName: "ToDoListItem")
    }

    @NSManaged public var name: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var checkMark: Bool

}

extension ToDoListItem : Identifiable {

}
