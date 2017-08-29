//FitnessSocial
//  Created by Sid Sachdev
//


import UIKit
import Parse

class SocialFeedController: UITableViewController {
    
    var images   = [NSDictionary]()
    var userlist = Dictionary<String, String>()
    let Image_file = "image"
    var refresher: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Social Feed"
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh user list")
        refresher.addTarget(self, action: #selector(loadFollowedUsers), forControlEvents: .ValueChanged)
        
        self.tableView.addSubview(refresher)
//        self.tableView.separatorStyle = UITableViewCellSeparatorStyle
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadUserNames()
        loadFollowedUsers()
        tableView.reloadData()
    }
//    
//    @IBAction func Logout(sender: UIBarButtonItem) {
//        PFUser.logOut()
//        PFUser.currentUser()?.objectId = nil
//        self.performSegueWithIdentifier("Logout", sender: self)
//    }
    
    @IBAction func DashBoard(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("DashBoard", sender: self)
    }    
    
    @IBAction func LogOut(sender: AnyObject) {
        PFUser.logOut()
        PFUser.currentUser()?.objectId = nil
            let alert = UIAlertController(title: "Logout", message: "You have been logged out successfully. The application will now exit.", preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
                exit(0)
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("feedCell", forIndexPath: indexPath) as! TableImageCell
        let cur = images[indexPath.row]
        let file = cur["file"] as! PFFile
        
        file.getDataInBackgroundWithBlock {
            (data, error) -> Void in
            
            if let image = UIImage(data: data!) {
                cell.postedImage.image = image
             //   cell.backImage.image = image
            //    cell.backImage.center = cell.postedImage.center
            //    cell.backImage.contentMode = UIViewContentMode.ScaleToFill
            //    cell.insertSubview(cell.backImage, atIndex: 0)
            //    cell.backImage.alpha = 0.35
            }
        }
        
        cell.postedImage.image = UIImage(named: "image")  // here add
        
        cell.caption.text = cur["caption"] as? String
    
        cell.username.text = cur["username"] as? String
        
    // cell.layer.borderWidth = 5.0
//        cell.layer.borderColor = UIColor.darkGrayColor().CGColor
        return cell
    }
    
    func loadUserNames() {
        //        let query = PFUser.query()
        let query = PFQuery(className: "User")
        query.findObjectsInBackgroundWithBlock({
            (objects, error) -> Void in
            if let users = objects {
                for object in users {
                    if let user = object as? PFUser {
                        print(user.username!)
                        self.userlist[user.objectId!] = user.username!
                    }
                }
            }
        })
    }

    
    func loadFollowedUsers() {
        let imageQuery   = PFQuery(className: "Image")
        
        self.images.removeAll(keepCapacity: true)
        imageQuery.findObjectsInBackgroundWithBlock({
            (objects, error) -> Void in
            
            if let objects = objects {
                for object in objects {
                    let objectId = object.objectId
                    
                    let image : [String: AnyObject] = [
                        "caption": object["caption"] as! String,
                        "username": object["userName"] as! String,
                        "file": object["file"] as! PFFile,
                        "objectID" : objectId!
                    ]
                    self.images.append(image)
                    self.tableView.reloadData()
                }
            }
        })
        self.refresher.endRefreshing()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowItem" {
            if let row = tableView.indexPathForSelectedRow?.row {
                
                
                let destinationController = segue.destinationViewController as! DetailImageView
                destinationController.image = images[row]
            }
        }
    }
    
}
