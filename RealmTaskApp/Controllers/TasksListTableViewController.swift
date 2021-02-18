//
//  TasksListTableViewController.swift
//  RealmTaskApp
//
//  Created by Elīna Zekunde on 17/02/2021.
//

import UIKit
import RealmSwift

class TasksListTableViewController: UITableViewController {

    var tasksLists: Results<TasksList>!
    private var isEditingMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tasksLists = realm.objects(TasksList.self)
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @IBAction func editItemTapped(_ sender: Any) {
        isEditingMode.toggle()
        tableView.setEditing(isEditingMode, animated: true)
        tableView.reloadData()
    }
    
    @IBAction func addNewItemTapped(_ sender: Any) {
        alertForAddUpdateList()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let tasksList = tasksLists[indexPath.row]
            let tasksVC = segue.destination as! IndividualTaskTableViewController
            tasksVC.currentTasksList = tasksList
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksLists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tasksListCell", for: indexPath)
        let taskList = tasksLists[indexPath.row]
        
        cell.configure(with: taskList)
        cell.selectionStyle = .none

        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let currentList = tasksLists[indexPath.row]
        
        let contextItemDelete = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _) in
            StorageManager.deleteList(currentList)
            tableView.deleteRows(at: [indexPath], with: .left)
        }
        
        let contextItemEdit = UIContextualAction(style: .destructive, title: "Edit") { (_, _, _) in
            self.alertForAddUpdateList(currentList, completion: {
                tableView.reloadRows(at: [indexPath], with: .right)
            })
        }
        
        let contextItemDone = UIContextualAction(style: .destructive, title: "Done") { (_, _, _) in
            StorageManager.markAllDone(currentList)
            tableView.reloadRows(at: [indexPath], with: .middle)
        }
        
        contextItemEdit.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        contextItemDone.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        
        let swipeActions = UISwipeActionsConfiguration(actions: [contextItemDelete, contextItemEdit, contextItemDone])
        
        return swipeActions
    }
}

extension UITableViewCell {
    func configure(with tasksList: TasksList) {
        let currentTasks = tasksList.tasks.filter("isComplete = false")
        let completedTasks = tasksList.tasks.filter("isComplete = true")
        
        textLabel?.text = tasksList.name
        
        if !currentTasks.isEmpty {
            detailTextLabel?.text = "\(currentTasks.count)"
            detailTextLabel?.font = UIFont.systemFont(ofSize: 20)
            detailTextLabel?.textColor = #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
        } else if !completedTasks.isEmpty {
            detailTextLabel?.text = "✓"
            detailTextLabel?.font = UIFont.systemFont(ofSize: 30)
            detailTextLabel?.textColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        } else {
            detailTextLabel?.text = "0"
        }
    }
}

extension TasksListTableViewController {
    private func alertForAddUpdateList(_ listName: TasksList? = nil, completion: (() -> Void)? = nil) {
        var title = "New List"
        var doneButton = "Save"
        
        if listName != nil {
            title = "Edit List"
            doneButton = "Update"
        }
        
        let alert = UIAlertController(title: title, message: "Please insert new value", preferredStyle: .alert)
        var alertTextField: UITextField!
        
        let saveAction = UIAlertAction(title: doneButton, style: .default) { _ in
            guard let newList = alertTextField.text, !newList.isEmpty else { return }
            
            if let listName = listName {
                StorageManager.editList(listName, newListName: newList)
                if completion != nil { completion!() }
            } else {
                let taskList = TasksList()
                taskList.name = newList
                
                StorageManager.saveTasksList(taskList)
                self.tableView.insertRows(at: [IndexPath(row: self.tasksLists.count - 1, section: 0)], with: .automatic)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        alert.addTextField { textField in
            alertTextField = textField
            alertTextField.placeholder = "List Name"
        }
        
        if let listName = listName {
            alertTextField.text = listName.name
        }
        
        present(alert, animated: true)
    }
}
