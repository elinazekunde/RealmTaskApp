//
//  StorageManager.swift
//  RealmTaskApp
//
//  Created by Elīna Zekunde on 17/02/2021.
//

import RealmSwift
let realm = try! Realm()

class StorageManager {
    
    //MARK: - Tasks List Methods
    
    static func saveTasksList(_ tasksList: TasksList) {
        try! realm.write {
            realm.add(tasksList)
        }
    }
    
    static func deleteList(_ tasksList: TasksList) {
        try! realm.write {
            let tasks = tasksList.tasks
            realm.delete(tasks)
            realm.delete(tasksList)
        }
    }
    
    static func editList(_ tasksList: TasksList, newListName: String) {
        try! realm.write {
            tasksList.name = newListName
        }
    }
    
    static func markAllDone(_ tasksList: TasksList) {
        try! realm.write {
            tasksList.tasks.setValue(true, forKey: "isComplete")
        }
    }
    
    //MARK: - Individual Task Method

    static func saveTask(_ tasksList: TasksList, task: Task) {
        try! realm.write {
            tasksList.tasks.append(task)
        }
    }
    
    static func editTask(_ task: Task, newTask: String, newNote: String) {
        try! realm.write {
            task.name = newTask
            task.note = newNote
        }
    }
    
    static func deleteTask(_ task: Task) {
        try! realm.write {
            realm.delete(task)
        }
    }
    
    static func markDone(_ task: Task) {
        try! realm.write {
            task.isComplete.toggle()
        }
    }
}

