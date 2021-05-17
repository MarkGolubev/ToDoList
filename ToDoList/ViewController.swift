//
//  ViewController.swift
//  ToDoList
//
//  Created by Марк Голубев on 13.05.2021.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private var models = [ToDoListItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        getAllItems()
        title = "To Do List"
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(didTapAdd))
    }
    
    @objc private func didTapAdd() {
        let alert = UIAlertController(title: "Новая цель",
                                      message: "Добавьте новую цель",
                                      preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        
        alert.addAction(UIAlertAction(title: "Добавить", style: .default, handler: { [weak self] _ in
            guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else { return }
            self?.createItem(name: text)
        }))
        
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.name
        cell.accessoryType = model.checkMark ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = models[indexPath.row]
        
        let sheet = UIAlertController(title: "Редактировать",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        
        sheet.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        
        sheet.addAction(UIAlertAction(title: item.checkMark ? "Снять отметку" : "Выполнить", style: .default, handler: { [weak self] _ in
            self?.updateCheckMark(item: item)
        }))
        
        sheet.addAction(UIAlertAction(title: "Изменить", style: .default, handler: { [weak self] _ in
            
            let alert = UIAlertController(title: "Изменить цель",
                                          message: "Измените вашу цель",
                                          preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            alert.textFields?.first?.text = item.name
            alert.addAction(UIAlertAction(title: "Изменить", style: .cancel, handler: { [weak self] _ in
                guard let field = alert.textFields?.first, let newName = field.text, !newName.isEmpty else { return }
                self?.updateItem(item: item, newName: newName)
            }))

            self?.present(alert, animated: true)
        }))
        sheet.addAction(UIAlertAction(title: "Удалить", style: .destructive, handler: { [weak self] _ in
            self?.deleteItem(item: item)
        }))


        present(sheet, animated: true)
    }
    
    // MARK: Core Data
    func getAllItems() {
        
        do {
            models = try context.fetch(ToDoListItem.fetchRequest()).sorted{ $0.createdAt! > $1.createdAt! }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        catch {
            //error
        }
    }
    
    func createItem(name: String) {
        
        let newItem = ToDoListItem(context: context)
        newItem.name = name
        newItem.createdAt = Date()
        newItem.checkMark = false
        
        do {
            try context.save()
            getAllItems()
        } catch {
            // error
        }
        
    }
    
    func deleteItem(item: ToDoListItem) {
        
        context.delete(item)
        
        do {
            try context.save()
            getAllItems()
        } catch {
            // error
        }
    }
    
    func updateItem(item: ToDoListItem, newName: String) {
        
        item.name = newName
        
        do {
            try context.save()
            getAllItems()
        } catch {
            // error
        }
        
    }
    
    func updateCheckMark(item: ToDoListItem) {
        
        item.checkMark = !item.checkMark
        
        do {
            try context.save()
            getAllItems()
        } catch {
            // error
        }
        
    }
    
}

