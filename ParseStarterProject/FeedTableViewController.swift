//FitnessSocial
//  Created by Sid Sachdev

import UIKit
import Parse

class FeedTableViewController: UITableViewController {

    var images   = [NSDictionary]()
    var userlist = Dictionary<String, String>()
    let Image_file = "image"
    var refresher: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "User Feed"
        
        
        refresher = UIRefreshControl()
        
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh user list")
        refresher.addTarget(self, action: #selector(loadFollowedUsers), forControlEvents: .ValueChanged)
        
        self.tableView.addSubview(refresher)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadUserNames()
        loadFollowedUsers()
        tableView.reloadData()
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
              //  cell.backImage.image = image
              //  cell.insertSubview(cell.backImage, atIndex: 0)
                //cell.backImage.alpha = 0.35

            }
        }

        cell.postedImage.image = UIImage(named: "image")  // here add
        
        cell.caption.text = cur["username"] as? String
        cell.username.text = cur["caption"] as? String 

        return cell
    }

    
    func loadFollowedUsers() {
        images.removeAll()
        let followQuery = PFQuery(className: "follower")
        
        followQuery.whereKey("follower", equalTo: (PFUser.currentUser()?.objectId!)!)
        
        followQuery.findObjectsInBackgroundWithBlock {
            (objects, error) -> Void in
            
            if let objects = objects {
                for object in objects {
                    let followedUser = object["following"] as! String
                    let imageQuery   = PFQuery(className: "Image")
                    
                    imageQuery.whereKey("userId", equalTo: followedUser)
                    
                    imageQuery.findObjectsInBackgroundWithBlock({
                        (objects, error) -> Void in
                        
                        if let objects = objects {
                            for object in objects {
                                let userid   = object["userId"] as! String
                                let username = self.userlist[userid]
                                let objectId = object.objectId
                                
                                let image = [
                                    "caption": object["caption"] as! String,
                                    "username": username!,
                                    "file": object["file"] as! PFFile,
                                    "objectID" : objectId!
                                ]
                                
                                self.images.append(image)
                                self.tableView.reloadData()
                            }
                        }
                    })
                }
            }
        }
        self.refresher.endRefreshing()
    }
    

    
    func loadUserNames() {
        userlist.removeAll()
     let query = PFUser.query()
        

        query?.findObjectsInBackgroundWithBlock({
            (objects, error) -> Void in
            if let users = objects {
                for object in users {
                    if let user = object as? PFUser {
                            self.userlist[user.objectId!] = user.username!
                    }
                }
            }
        })
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
