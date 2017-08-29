//FitnessSocial
// Created by Sid Sachdev


import Foundation
import UIKit
import Parse

class UserDetail : UITableViewController {
    
    var objectId: String = ""
    var flag = false
    
    @IBOutlet weak var FollowBtn: UIButton!
//    @IBOutlet weak var FollowBtn: UIButton!
    @IBOutlet weak var UserNameLabel: UILabel!
    
    var user = [String: String]()
    var username : String = ""
    
    var images   = [NSDictionary]()
    
    var userlist = Dictionary<String, String>()
    let Image_file = "image"
   
    var refresher: UIRefreshControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if flag == true{
        self.objectId = user["id"]!
        self.username = user["name"]!
        }
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh user list")
        refresher.addTarget(self, action: #selector(loadFollowedUsers), forControlEvents: .ValueChanged)
        self.tableView.addSubview(refresher)
        
        print(objectId+".")
        print(username+".")
        let query1 = PFQuery(className: "follower")
        query1.whereKey("follower", equalTo: (PFUser.currentUser()?.objectId)!)
        query1.whereKey("following", equalTo: self.objectId)
        query1.findObjectsInBackgroundWithBlock({
            (objects, error) -> Void in
            
            if let objects = objects {
                if objects.count > 0 {
                    self.FollowBtn.setTitle("UnFollow - "+self.username, forState: .Normal)
                }
                else{
                    self.FollowBtn.setTitle("Follow - "+self.username, forState: .Normal)
                }
            }
        })
        
        loadFollowedUsers()
        
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

    @IBAction func DashBoard(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("DashBoard", sender: self)
        
    }
    
    @IBAction func Logout(sender: UIBarButtonItem) {
        PFUser.logOut()
        PFUser.currentUser()?.objectId = nil
        let alert = UIAlertController(title: "Logout", message: "You have been logged out successfully. The application will now exit.", preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
            exit(0)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        


    }
    
    @IBAction func Follow(sender: UIButton) {
        let tempLabl = "UnFollow - "+self.username
        let btnLabltemp = FollowBtn.titleLabel?.text
        if btnLabltemp == tempLabl {
            
                        let query = PFQuery(className: "follower")
            
                        query.whereKey("follower", equalTo: (PFUser.currentUser()?.objectId)!)
                        query.whereKey("following", equalTo: self.objectId)
            
                        query.findObjectsInBackgroundWithBlock({
                            (objects, error) -> Void in
            
                            if let objects = objects {
                                for obj in objects {
                                    obj.deleteInBackground()
                                }
                            }
                        })
            
                        FollowBtn.setTitle("Follow - "+self.username, forState: .Normal)
                    }
                    else
                    {
                        let relation = PFObject(className: "follower")
            
                        relation["following"] = self.objectId
                        relation["follower"]  = PFUser.currentUser()?.objectId
            
                        relation.saveInBackground()
            
                        FollowBtn.setTitle("UnFollow - "+self.username, forState: .Normal)

            
                }
        tableView.reloadData()

    }
    
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
//                cell.backImage.image = image
//                cell.insertSubview(cell.backImage, atIndex: 0)
//                cell.backImage.alpha = 0.35
            }
        }
        
        cell.postedImage.image = UIImage(named: "image")  // here add
        cell.caption.text = cur["caption"] as? String
        cell.username.text = ""
        
        return cell
    }
    
    
    func loadFollowedUsers() {
        
        let imageQuery = PFQuery(className: "Image")
                    
                    imageQuery.whereKey("userId", equalTo: self.objectId)
                   
//                    imageQuery.orderByDescending("updatedAt")
        
                    imageQuery.findObjectsInBackgroundWithBlock({
                        (objects, error) -> Void in
                        
                        if let objects = objects {
                            for object in objects {
//                                let userid   = object["userId"] as! String
//                                let username = self.userlist[userid]
                                let objectId1 = self.objectId
                                
                                let image : [String: AnyObject] = [
                                    "caption": object["caption"] as! String,
//                                    "username": username!,
                                    "file": object["file"] as! PFFile,
                                    "objectID" : objectId1
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
    
}