import UIKit
import CryptoKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase



var ref: DatabaseReference!

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate, UISearchDisplayDelegate {
    
    // Data model: These strings will be the data for the table view cells
    var ref = Database.database().reference()

    class Item {
        init(name: String, price: Int) {
            self.name = name
            self.price = price
        }
        var name: String
        var price: Int
    }
    
    
    
    var itemsMaster = [Item]()
    
    var items = [Item]()
    
    var lastLocalItem = Item(name: "DONOTBUY - $0", price: 0)
    
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
        
        ref.child("items").observe(.childChanged, with: { (snapshot) in
            if(!(self.lastLocalItem.name == "\(snapshot.key) - $\(snapshot.value ?? 0)")){
                print(snapshot.key)
                print(self.lastLocalItem.name)
                for item in self.itemsMaster {
                    if item.name.starts(with: "\(snapshot.key) - $") {
                        print(item.name)
                        item.name = "\(snapshot.key) - $\(snapshot.value ?? 0)"
                        item.price = snapshot.value as! Int
                        
                        self.tableView.reloadData()
                        break;
                    }
                }
                
                for item in self.items {
                    if item.name.starts(with: "\(snapshot.key) - $") {
                        item.name = "\(snapshot.key) - $\(snapshot.value ?? 0)"
                        item.price = snapshot.value as! Int
                        
                        self.tableView.reloadData()
                        break;
                    }
                }
                
            }
        })
        
        ref.child("items").observe(.childAdded, with: { (snapshot) in
                   // snapshot is a dictionary with a key and a dictionary as a value
                    // this gets the dictionary from each snapshot
                   
                    // building a Student object from the dictionary
                    // adding the student object to the Student array
            let item = Item(name: "\(snapshot.key) - $\(snapshot.value as! Int)", price: snapshot.value as! Int)
            
            print(item.name)
            print(self.lastLocalItem.name)
            let myString = self.lastLocalItem.name
            let regex = try! NSRegularExpression(pattern: "\\d*$", options: NSRegularExpression.Options.caseInsensitive)
            let range = NSMakeRange(0, myString.count)
            let modString = regex.stringByReplacingMatches(in: myString, options: [], range: range, withTemplate: "")
            if(!item.name.starts(with: "\(modString)")){
                self.items.append(item)
                self.itemsMaster.append(item)
                self.tableView.reloadData()
                self.lastLocalItem = item
            }

        // should only add the student if the student isn’t already in the array
        // good place to update the tableview also
                    
                })
    }
    
    var handle: AuthStateDidChangeListenerHandle!
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener { auth, user in
          // ...
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle)
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

            // delete the table view row
            
            let myString = items[indexPath.row].name
            let regex = try! NSRegularExpression(pattern: " - \\$\\d*$", options: NSRegularExpression.Options.caseInsensitive)
            let range = NSMakeRange(0, myString.count)
            let modString = regex.stringByReplacingMatches(in: myString, options: [], range: range, withTemplate: "")
            ref.child("items").child(modString).removeValue()
           
            items.remove(at: indexPath.row)

            tableView.deleteRows(at: [indexPath], with: .fade)


        } else if editingStyle == .insert {
            
        }
    }
    
    func addRow(name: String, price: Int){
        let newItem = Item(name: name,price: price)
        let myString = newItem.name
        let regex = try! NSRegularExpression(pattern: "\\d*$", options: NSRegularExpression.Options.caseInsensitive)
        let range = NSMakeRange(0, myString.count)
        let modString = regex.stringByReplacingMatches(in: myString, options: [], range: range, withTemplate: "")
        
        print(modString)
        if(!itemsMaster.contains{ $0.name.starts(with:modString) }){
            print(newItem.name)
            items.append(newItem)
            itemsMaster.append(newItem)
            tableView.beginUpdates()
            tableView.insertRows(at: [IndexPath(row: items.count-1, section: 0)], with: .automatic)
            tableView.endUpdates()
        } else{
            for item in self.itemsMaster {
                if item.name.starts(with:modString) {
                    item.name = newItem.name
                    item.price = newItem.price
                    
                    self.tableView.reloadData()
                    break;
                }
            }
            
            for item in self.items {
                if item.name.starts(with:modString) {
                    item.name = newItem.name
                    item.price = newItem.price
                    self.tableView.reloadData()
                    break;
                }
            }
        }
        
    }
    
    @IBAction func loginButton(_ sender: Any) {
        Auth.auth().signIn(withEmail: "admin@cafe.test", password: passwordField.text!) { [weak self] authResult, error in
          guard let strongSelf = self else { return }
            self!.isAdmin = true
            self!.adminItem.isHidden = false
            self!.adminItemName.isHidden = false
            self!.adminItemPrice.isHidden = false
            self!.adminAddItemButton.isHidden = false
         print(strongSelf)
        }

        
    }
    
    @IBAction func adminAddItem(_ sender: Any) {
        if let itemPrice = Int(adminItemPrice.text!) {
            addRow(name: "\(adminItemName.text!) - $\(itemPrice)", price: itemPrice)
            lastLocalItem = Item(name: "\(adminItemName.text!) - $\(itemPrice)", price: itemPrice)
            self.ref.child("items").child(adminItemName.text!).setValue(itemPrice)
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
