//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Fnu Tsering on 3/11/21.
//

import UIKit
import Parse
import AlamofireImage

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [PFObject]() //posts is equal to an array of PFObjects.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let query = PFQuery(className: "Posts")
        query.includeKey("author") //if you don't include the includeKey for the column author, then it will just contain the pointer to the user without actual User object. So we are saying go fetch the actual object.
        query.limit = 20 //asking only for the last 20
        
        query.findObjectsInBackground { (posts, error) in //posts refers to an array of PFObjects
            if posts != nil {
                //if the array of objects that is fetched is not empty, then put those objects into the variable posts we declared before.
                self.posts = posts! //self.posts is the variable posts we created
                self.tableView.reloadData() //tells the table View to reload itself so it will call the dataSource functions again.
            }
        }
        
    }
    
    //These are the two required functions for the dataSource:
        //number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
        //cell for row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        
        let post = posts[indexPath.row]
        
        let user = post["author"] as! PFUser
        
        cell.usernameLabel.text = user.username
        
        cell.captionLabel.text = post["caption"] as! String
        
        let imageFile = post["image"] as! PFFileObject //the PFFileObject has a url to the image in png
        
        let urlString = imageFile.url! // use .url on the image file to access the image url inside the file which is given as a string
    
        let url = URL(string: urlString)! //create an actual URL from that string url.
        
        //now we can use that image url with AmofireImage library to load the image and set the image view to that image to display it
        cell.photoView.af_setImage(withURL: url)
        return cell
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
