//FitnessSocial
// Created by Sid Sachdev

import UIKit
import Parse

class UserListViewController: UITableViewController {

    var userlist = [Dictionary<String, String>]()
    var flag = false
    
    
    var refresher: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Following"
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None

        let backgroundImage = UIImageView(frame: UIScreen.mainScreen().bounds)
        backgroundImage.image = UIImage(named: "fitness")
        backgroundImage.alpha = 0.5
        backgroundImage.contentMode =  UIViewContentMode.Center
        tableView.insertSubview(backgroundImage, atIndex: 0)
        // end of style
        

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadUsers()
    }
    
    
    @IBAction func Search(sender: UIButton) {
        self.performSegueWithIdentifier("Search", sender: self)
    }

    // MARK: - Table view data source
    @IBAction func SocialFeedNavigate(sender: AnyObject) {
        self.performSegueWithIdentifier("socialFeed", sender: self)
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if userlist.count == 0 {
            flag = true
            return 0
        }
        return userlist.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        if userlist.count != 0{
            cell.textLabel!.text = userlist[indexPath.row]["name"]
            cell.textLabel!.textColor = UIColor.blueColor()
            
        }
       return cell
    }
    @IBAction func LogoutUser(sender: AnyObject) {
        PFUser.logOut()
        PFUser.currentUser()?.objectId = nil
        let alert = UIAlertController(title: "Logout", message: "You have been logged out successfully. The application will now exit.", preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
            exit(0)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

    func loadUsers() {
       userlist.removeAll(keepCapacity: true)
        let query = PFUser.query()
    
        query?.findObjectsInBackgroundWithBlock({
            (objects, error) -> Void in

            if let users = objects {
//                self.userlist.removeAll(keepCapacity: true)

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
                                        self.userlist.append(["name": user.username!, "id": user.objectId!, "following": following])
                                    }
                                }
                                self.tableView.reloadData()
                            })
                        }
                    }
                }
            }
        })
//        self.refresher.endRefreshing()
    }




    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "UserDetail"{
            if let row = tableView.indexPathForSelectedRow?.row {
                let destinationController = segue.destinationViewController as! UserDetail
                destinationController.user = userlist[row]
                destinationController.flag = true
            }
        }
    }

}
