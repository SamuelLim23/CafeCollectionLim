import UIKit
import CryptoKit
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Data model: These strings will be the data for the table view cells
    var items: [String] = ["Horse - $5", "Cow - $20", "Camel - $40", "Sheep - $2", "Goat - $5"]
    var prices: [Int] = [5,20,40,2,5]
    var total = 0
    var text = ""
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"
    
    // don't forget to hook this up from the storyboard
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var priceOut: UILabel!
    @IBOutlet weak var textOut: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        cell.textLabel?.text = self.items[indexPath.row]
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        text.append(items[indexPath.row] + "\n")
        textOut.text = text
        total+=prices[indexPath.row]
        priceOut.text = "$\(total)"
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete && true{

            // remove the item from the data model
            items.remove(at: indexPath.row)

            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .fade)

        } else if editingStyle == .insert {
            
        }
    }
    
    func addRow(name: String, price: Int){
        items.append(name)
        prices.append(price)
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: items.count-1, section: 0)], with: .automatic)
        tableView.endUpdates()
    }
    
    @IBAction func loginButton(_ sender: Any) {
        let hashedPassword = SHA512.hash(data: Data(passwordField.text!.utf8))
        

        print(hashedPassword)
    }
    
}
