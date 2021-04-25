//
//  MenuViewController.swift
//  DinInLiao
//
//  Created by LIU SHANG WEI on 2021/4/18.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDataSource {
    @IBAction func unwindToMenu(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
    @IBOutlet weak var menuTableView: UITableView!
    var records = [Record]()
    func fetchItems() {
        let url = URL(string: "https://api.airtable.com/v0/appzbjom7lfkVVipd/Goods?sort[][field]=id&sort[][direction]=asc")!
        var request = URLRequest(url: url)
        request.setValue("Bearer keyl6pn82pKoEYem1", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let menuResponse = try decoder.decode(Menu.self, from: data)
                    self.records = menuResponse.records
                    DispatchQueue.main.async {
                        self.menuTableView.reloadData()
                    }
                } catch {
                    
                }
                
            }
        }.resume()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchItems()
        // Do any additional setup after loading the view.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(MenuTableViewCell.self)", for: indexPath) as! MenuTableViewCell
        let item = records[indexPath.row]
        cell.goodsLabel.text = item.fields.goodsName
        cell.sizeLabel.text = item.fields.description
        return cell
    }
    
    @IBSegueAction func orderDetail(_ coder: NSCoder) -> OrderTableViewController? {
        guard let row = menuTableView.indexPathForSelectedRow?.row else {
            return nil
        }
        let item = records[row]
        return OrderTableViewController(coder: coder, item: item)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
