
//  DetailImageView.swift
//  FitnessSocial
//
//  Created by Sid Sachdev



import UIKit
import Parse

class DetailImageView : UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var Comment: UITextField!
    @IBOutlet var imageView: UIImageView!
    var userlist = Dictionary<String, String>()
    
    var commentDict   = [NSDictionary]()

    var indicator = UIActivityIndicatorView()


    @IBOutlet var dateLabel: UILabel!
    
    var image   = NSDictionary()
    var objectid : String = ""
    let comment = PFQuery(className: "Comment")
 
    override func viewDidLoad() {
       
        super.viewDidLoad()
        navigationItem.hidesBackButton = false
        let cur = image
        let file = cur["file"] as! PFFile
        objectid = cur["objectID"] as! String
        
        file.getDataInBackgroundWithBlock {
            (data, error) -> Void in
            
            if let image = UIImage(data: data!) {
                self.imageView.image = image
                self.imageView.frame =  CGRectMake(0, 0, 100, 70)
               // self.imageView.contentMode = .ScaleAspectFit
            }
        }
    
        loadUserNames()
        loadComments()
        
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
    
    func loadComments(){
        self.commentDict.removeAll(keepCapacity: true)
        comment.whereKey("imageId", equalTo: (objectid))
        
        comment.findObjectsInBackgroundWithBlock({
            (objects, error) -> Void in
            
            if let objects = objects {
                for object in objects {
                    let username = object["userName"] as! String
                    //                    let objectId = object.objectId
                    
                    let image : [String: AnyObject] = [
                        "comment": object["comment"] as! String,
                        "userName": username
                    ]
                    self.commentDict.append(image)
                    self.tableView.reloadData()
                }
            }
        })

    }
    
    @IBAction func PostComment(sender: AnyObject) {
        
        indicator = UIActivityIndicatorView(frame: self.view.frame)
        indicator.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        indicator.center = imageView.center
        indicator.hidesWhenStopped = true
        indicator.activityIndicatorViewStyle = .Gray
        
        view.addSubview(indicator)
        
        if(Comment.text != "")
        {
        indicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            let imageData = UIImagePNGRepresentation(self.imageView.image!)
            let imageFile = PFFile(name: "uploaded.png", data: imageData!)
            let image     = PFObject(className: "Comment")
        
            image["imageId"] = self.objectid
            image["userId"] = PFUser.currentUser()?.objectId!
            image["userName"]  = userlist[(PFUser.currentUser()?.objectId!)!]
            image["file"]    = imageFile
            image["comment"] = Comment.text
                
            image.saveInBackgroundWithBlock {
            (success, error) -> Void in

        
            if error == nil {
            self.loadComments()
            self.indicator.stopAnimating()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()

            self.Comment.text = ""
        
            }
            else {
            
            }
            
        }
        }
        else{
            let alert = UIAlertController(title: "Error", message: "Please enter a comment", preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            
                self.presentViewController(alert, animated: true, completion: nil)
        }
        
        
    }
    

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentDict.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DetailCell", forIndexPath: indexPath)
        let cur = commentDict[indexPath.row]
        
        cell.textLabel?.text = cur["userName"] as? String
        cell.detailTextLabel?.text = cur["comment"] as? String
        
        
        //Cell style begin
        //Chaging the Username text label color for alternate comments
        if indexPath.row % 2 == 0 {
            cell.textLabel?.textColor = UIColor.blueColor()
            cell.detailTextLabel?.textColor = UIColor.darkGrayColor()
        }
        else {
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.detailTextLabel?.textColor = UIColor.darkGrayColor()
        }
        //End of Cell style
        
        return cell

    }

    func loadUserNames() {
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
    
}