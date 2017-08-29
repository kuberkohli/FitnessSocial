//FitnessSocial
//  Created by Sid Sachdev
import UIKit
import Parse

class ImageUploadControllerViewControllerV: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var indicator = UIActivityIndicatorView()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var caption: UITextField!
    @IBOutlet weak var uploadButton: UIButton!
    var userlist = Dictionary<String, String>()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Post Image"
        //style begin
        //setting image as backgorund and removing cell borders
        let backgroundImage = UIImageView(frame: UIScreen.mainScreen().bounds)
        backgroundImage.image = UIImage(named: "img")
        backgroundImage.alpha = 0.5
        backgroundImage.contentMode =  UIViewContentMode.Bottom
        self.view.insertSubview(backgroundImage, atIndex: 0)
        // end of style

        loadUserNames()
        uploadButton.enabled = false
    }


    @IBAction func selectPressed(sender: AnyObject) {
        let picker = UIImagePickerController()

        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        picker.allowsEditing = true

        self.presentViewController(picker, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)

        imageView.image = image

        uploadButton.enabled = true
    }

    @IBAction func uploadPressed(sender: AnyObject) {
        var errMsg = "Try again later"

        indicator = UIActivityIndicatorView(frame: self.view.frame)
        indicator.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        indicator.center = imageView.center
        indicator.hidesWhenStopped = true
        indicator.activityIndicatorViewStyle = .Gray

        view.addSubview(indicator)

        indicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()

        let imageData = UIImagePNGRepresentation(self.imageView.image!)
        
        let imageFile = PFFile(name: "uploaded.png", data: imageData!)
        
        let image     = PFObject(className: "Image")

        image["userId"]  = PFUser.currentUser()?.objectId!
        image["userName"] = userlist[(PFUser.currentUser()?.objectId!)!]
        image["file"]    = imageFile
        image["caption"] = caption.text
        
        image.saveInBackgroundWithBlock {
                (success, error) -> Void in
                
                self.indicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
                if error == nil {
                    self.uploadButton.enabled = false
                    self.imageView.image = UIImage(named: "placeholder.png")
                    self.caption.text = ""
                    self.displayAlert("The image was uploaded successfully", title: "Upload successful")
                    
                }
                else {
                    if let errorStr = error?.userInfo["error"] as? String {
                        errMsg = errorStr
                    }
                    
                    self.displayAlert(errMsg, title: "Problem with posting")
                }
            }
    }

    func displayAlert(message: String, title: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)

        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: {
            (action) -> Void in
//            self.dismissViewControllerAnimated(true, completion: nil)
        }))

        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
