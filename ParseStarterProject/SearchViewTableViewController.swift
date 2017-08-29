//FitnessSocial
//  Created by Sid Sachdev


import UIKit
import Parse

class SearchViewTableViewController: UITableViewController, UISearchBarDelegate {

    
    var UserNameTable = [String]()
    let searchBar = UISearchBar()
    var userlist = [Dictionary<String, String>]()
    
    var filteredResult = [String]()
    var followingResult = [String]()
    var searchFlag = false
    
   
    override func viewDidLoad() {
        navigationItem.hidesBackButton = false
        super.viewDidLoad()
        
        loadUsers()
        createSearchBar()
        self.searchBar.becomeFirstResponder()
        
        //style begin
        //setting image as backgorund and removing cell borders
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        let backgroundImage = UIImageView(frame: UIScreen.mainScreen().bounds)
        backgroundImage.image = UIImage(named: "fitness")
        backgroundImage.alpha = 0.5
        backgroundImage.contentMode =  UIViewContentMode.Center
        tableView.insertSubview(backgroundImage, atIndex: 0)
        // end of style
    }
    
    @IBAction func TapBackground() {
        self.searchBar.endEditing(true)
        self.searchBar.resignFirstResponder()
    }
    
    
    @IBAction func BackButton(sender: UIButton) {
    self.searchBar.endEditing(true)
    self.performSegueWithIdentifier("Back", sender: self)
    }
    
    func createSearchBar (){
        searchBar.showsCancelButton = false
        searchBar.placeholder = "Enter a UserName here to search"
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchFlag = true
        self.searchBar.endEditing(true)
        self.tableView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filteredResult = UserNameTable.filter({ (name : String) -> Bool in
            
            return name.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
        })
        
        if searchText != ""{
                    searchFlag = true
                    self.tableView.reloadData()
        }else{
            searchFlag = false
            self.tableView.reloadData()
        }
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.searchBar.endEditing(true)
    }
    
    func loadUsers() {
        userlist.removeAll()
        let query = PFUser.query()
        
        query?.findObjectsInBackgroundWithBlock({
            (objects, error) -> Void in
            
            if let users = objects {
                self.UserNameTable.removeAll(keepCapacity: true)
                
                for object in users {
                    if let user = object as? PFUser {
                        if user.objectId != PFUser.currentUser()?.objectId {
                            let query = PFQuery(className: "follower")
                            query.whereKey("follower", equalTo: (PFUser.currentUser()?.objectId)!)
                            query.whereKey("following", equalTo: user.objectId!)
                            query.findObjectsInBackgroundWithBlock({
                                (objects, error) -> Void in
                                
                                var following = "0"
                                
                                if let objects = objects {
                                    if objects.count > 0 {
                                        following = "1"
                                    }
                                }
                                self.userlist.append(["name": user.username!, "id": user.objectId!, "following": following])
                                self.UserNameTable.append(user.username!)
                                self.tableView.reloadData()
                            })
                        }
                    }
                }
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchFlag{
            return filteredResult.count
        }
        else{
            return userlist.count
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchCell", forIndexPath: indexPath)
        
        if searchFlag{
            cell.textLabel!.text = filteredResult[indexPath.row]
            cell.textLabel!.textColor = UIColor.blueColor()
            cell.accessoryType = .None
            for i in 1..<userlist.count  {
                    if userlist[i]["name"]! == filteredResult[indexPath.row]{
                        if userlist[i]["following"] == "1" {
                            cell.accessoryType = .Checkmark
                        }
                    }
                }
            }
        else{
            cell.textLabel!.text = userlist[indexPath.row]["name"]
            cell.textLabel!.textColor = UIColor.blueColor()
            if userlist[indexPath.row]["following"] == "1" {
                cell.accessoryType = .Checkmark
            }else{
                cell.accessoryType = .None
            }
        }
        
        return cell


    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.searchBar.endEditing(true)
        let row = tableView.indexPathForSelectedRow?.row
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)
      
        if (searchFlag){
            for i in 1..<userlist.count  {
                    if userlist[i]["name"]! == filteredResult[row!]{
                        let following = userlist[i]["following"] == "1"
                        if following {
                            userlist[i]["following"] = "0"
                            
                            let query = PFQuery(className: "follower")
                            
                            query.whereKey("follower", equalTo: (PFUser.currentUser()?.objectId)!)
                            query.whereKey("following", equalTo: userlist[i]["id"]!)
                            
                            query.findObjectsInBackgroundWithBlock({
                                (objects, error) -> Void in
                                
                                if let objects = objects {
                                    for obj in objects {
                                        obj.deleteInBackground()
                                    }
                                }
                            })
//                            print(userlist[i]["name"]!)
//                            print("removed")
                            
                            cell?.accessoryType = .None
                        }
                        else {
                            userlist[row!]["following"] = "1"
                            
                            let relation = PFObject(className: "follower")
                            
                            relation["following"] = userlist[i]["id"]
                            relation["follower"]  = PFUser.currentUser()?.objectId
                            relation.saveInBackground()
//                            print(userlist[i]["name"]!)
//                            print("added")
                            
                            cell?.accessoryType = .Checkmark
                            
                        }
                }
                    }
                }
            else
            {
            let following = userlist[row!]["following"] == "1"
            
            if following {
                userlist[row!]["following"] = "0"
                
                let query = PFQuery(className: "follower")
                
                query.whereKey("follower", equalTo: (PFUser.currentUser()?.objectId)!)
                query.whereKey("following", equalTo: userlist[indexPath.row]["id"]!)
                
                query.findObjectsInBackgroundWithBlock({
                    (objects, error) -> Void in
                    
                    if let objects = objects {
                        for obj in objects {
                            obj.deleteInBackground()
                        }
                    }
                })
                print("removed")
                
                cell?.accessoryType = .None
            }
            else {
                userlist[row!]["following"] = "1"
                
                let relation = PFObject(className: "follower")
                
                relation["following"] = userlist[row!]["id"]
                relation["follower"]  = PFUser.currentUser()?.objectId
                relation.saveInBackground()
                print("added")
                
                cell?.accessoryType = .Checkmark
            }
        }
        loadUsers()
        }
}

