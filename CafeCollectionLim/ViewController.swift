import UIKit
import CryptoKit
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate, UISearchDisplayDelegate {
    
    // Data model: These strings will be the data for the table view cells
    
    struct Item {
        let name: String
        let price: Int
    }
    
    var itemsMaster = [
        Item(name: "Horse - $5", price: 5),
        Item(name: "Cow - $20", price: 20),
        Item(name: "Camel - $40", price: 40),
        Item(name: "Sheep - $2", price: 2),
        Item(name: "Goat - $5", price: 5),
    ]
    
    var items = [
        Item(name: "Horse - $5", price: 5),
        Item(name: "Cow - $20", price: 20),
        Item(name: "Camel - $40", price: 40),
        Item(name: "Sheep - $2", price: 2),
        Item(name: "Goat - $5", price: 5),
    ]
    
    var total = 0
    var text = ""
    var isAdmin = false
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"
    
    // don't forget to hook this up from the storyboard
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet weak var adminItemPrice: UITextField!
    @IBOutlet weak var adminItem: UILabel!
    @IBOutlet weak var adminItemName: UITextField!
    @IBOutlet weak var adminAddItemButton: UIButton!
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var priceOut: UILabel!
    @IBOutlet weak var textOut: UITextView!
    
    @IBOutlet weak var searchBarVar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBarVar.delegate = self

        // Register the table view cell class and its reuse id
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        // (optional) include this line if you want to remove the extra empty cell divider lines
        // self.tableView.tableFooterView = UIView()

        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)! as UITableViewCell
        
        // set the text from the data model
        cell.textLabel?.text = self.items[indexPath.row].name
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        text.append(items[indexPath.row].name + "\n")
        textOut.text = text
        total+=items[indexPath.row].price
        priceOut.text = "$\(total)"
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete && isAdmin{

            // remove the item from the data model
            items.remove(at: indexPath.row)

            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .fade)

        } else if editingStyle == .insert {
            
        }
    }
    
    func addRow(name: String, price: Int){
        items.append(Item(name: name,price: price))
        itemsMaster.append(Item(name: name,price: price))
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: items.count-1, section: 0)], with: .automatic)
        tableView.endUpdates()
    }
    
    @IBAction func loginButton(_ sender: Any) {
        let hashedPassword = SHA512.hash(data: Data(passwordField.text!.utf8))
        let hashString = hashedPassword.compactMap { String(format: "%02x", $0) }.joined()
        
        if hashString == "e6c83b282aeb2e022844595721cc00bbda47cb24537c1779f9bb84f04039e1676e6ba8573e588da1052510e3aa0a32a9e55879ae22b0c2d62136fc0a3e85f8bb" {
            isAdmin = true
            
            adminItem.isHidden = false
            adminItemName.isHidden = false
            adminItemPrice.isHidden = false
            adminAddItemButton.isHidden = false
        }
    }
    
    @IBAction func adminAddItem(_ sender: Any) {
        if let itemPrice = Int(adminItemPrice.text!) {
            addRow(name: "\(adminItemName.text!) - $\(itemPrice)", price: itemPrice)
        }
    }
    
    @IBOutlet weak var sortButtonsOutlet: UISegmentedControl!
    
    @IBAction func sortButtonsChanged(_ sender: Any) {
        if sortButtonsOutlet.selectedSegmentIndex == 0 {
            items.sort{ $0.name.lowercased() < $1.name.lowercased() }
            print(items)
            tableView.reloadData()
        } else{
            items.sort{ $0.price < $1.price }
            print(items)
            tableView.reloadData()
        }
    }
    

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        items = itemsMaster
        items.removeAll{ !$0.name.lowercased().starts(with: searchText.lowercased())}
        tableView.reloadData()
    }
    
}
