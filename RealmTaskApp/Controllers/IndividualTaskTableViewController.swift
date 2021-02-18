//
//  IndividualTaskTableViewController.swift
//  RealmTaskApp
//
//  Created by Elīna Zekunde on 17/02/2021.
//

import UIKit
import RealmSwift

class IndividualTaskTableViewController: UITableViewController {

    var currentTasksList: TasksList!
    var currentTasks: Results<Task>!
    var completedTasks: Results<Task>!
    private var isEditingMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = currentTasksList.name
        filteringTasks()
    }

    @IBAction func editItemTapped(_ sender: Any) {
        isEditingMode.toggle()
        tableView.setEditing(isEditingMode, animated: true)
    }
    
    @IBAction func addItemTapped(_ sender: Any) {
        alertForAddAndUpdateList()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Current Tasks" : "Completed Tasks"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? currentTasks.count : completedTasks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tasksCell", for: indexPath)

        var task: Task!
        task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        
        cell.textLabel?.text = task.name
        cell.detailTextLabel?.text = task.note
        cell.selectionStyle = .none
        
        return cell
    }
    
    //MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var task: Task!
        task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        
        let contextItemDelete = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _) in
            StorageManager.deleteTask(task)
            self.filteringTasks()
        }
        
        let contextItemEdit = UIContextualAction(style: .normal, title: "Edit") { (_, _, _) in
            self.alertForAddAndUpdateList(task)
            self.filteringTasks()
        }
        
        let contextItemDone = UIContextualAction(style: .normal, title: "Done") { (_, _, _) in
            StorageManager.markDone(task)
            self.filteringTasks()
        }
        
        contextItemEdit.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        contextItemDone.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        
        let swipeActions = UISwipeActionsConfiguration(actions: [contextItemDelete, contextItemEdit, contextItemDone])
        
        return swipeActions
    }
    
    private func filteringTasks() {
        currentTasks = currentTasksList.tasks.filter("isComplete = false")
        completedTasks = currentTasksList.tasks.filter("isComplete = true")
        tableView.reloadData()
    }
}

extension IndividualTaskTableViewController {
    private func alertForAddAndUpdateList(_ taskName: Task? = nil) {
        var title = "New Task"
        var doneButton = "Save"
        
        if taskName != nil {
            title = "Edit Task"
            doneButton = "Update"
        }
        
        let alert = UIAlertController(title: title, message: "Please insert new task", preferredStyle: .alert)
        
        var taskTextField: UITextField!
        var noteTextField: UITextField!
        
        let saveAction = UIAlertAction(title: doneButton, style: .default) { _ in
            guard let newTask = taskTextField.text, !newTask.isEmpty else { return }
            
            if let taskName = taskName {
                if let newNote = noteTextField.text, !newNote.isEmpty {
                    StorageManager.editTask(taskName, newTask: newTask, newNote: newNote)
                } else {
                    StorageManager.editTask(taskName, newTask: newTask, newNote: "")
                }
                self.filteringTasks()
            } else {
                let task = Task()
                task.name = newTask
                
                if let note = noteTextField.text, !note.isEmpty {
                    task.note = note
                }
                
                StorageManager.saveTask(self.currentTasksList, task: task)
                self.filteringTasks()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        alert.addTextField { textField in
            taskTextField = textField
            taskTextField.placeholder = "New Task"
            
            if let taskName = taskName {
                taskTextField.text = taskName.name
            }
        }
        
        alert.addTextField { textField in
            noteTextField = textField
            noteTextField.placeholder = "Note"
            
            if let taskName = taskName {
                noteTextField.text = taskName.note
            }
        }
        
        present(alert, animated: true)
    }
}
