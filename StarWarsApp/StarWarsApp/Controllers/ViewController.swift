//
//  ViewController.swift
//  StarWarsApp
//
//  Created by YouTube on 9/16/22.
//

import UIKit

class ViewController: UIViewController {

    let tableView = UITableView()
    var people: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTable()
        
        fetchDataStandard()
        fetchDataResultType()

        Task{
            await fetchDataAsync()
        }
    }

    private func configureTable() {
        view.addSubview(tableView)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
    }
    
    private func fetchDataStandard() {
        NetworkManager.shared.standardNetworkCall { persons in
            let ppl = persons?.map({$0.name})
            guard let ppl = ppl else { return }
            self.people.append(contentsOf: ppl)
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    
    private func fetchDataResultType() {
        NetworkManager.shared.networkCallWithResultType { result in
            switch result {
            case .success(let persons):
                let ppl = persons.map({$0.name})
                self.people.append(contentsOf: ppl)
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func fetchDataAsync() async {
        do {
            let ppl = try await NetworkManager.shared.networkWithAsync()
            let ppls = ppl.map({$0.name})
            self.people.append(contentsOf: ppls)
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = people[indexPath.row]
        return cell
    }
    
    
    
}
