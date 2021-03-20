//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Fnu Tsering on 3/11/21.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
    
    // Initialize a UIRefreshControl
    let myRefreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    let commentBar = MessageInputBar()
    var showsCommentsBar = false
    var selectedPost: PFObject!
    
    var posts = [PFObject]() //posts is equal to an array of PFObjects.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
            
        tableView.delegate = self
        tableView.dataSource = self
        
        //#selector() asks for the action you want to happen when user pulls refresh
        myRefreshControl.addTarget(self, action: #selector(loadPosts), for: .valueChanged)
        tableView.refreshControl = myRefreshControl //this tells the table view to use the Refresh Control named  myRefreshControl
        
        tableView.keyboardDismissMode = .interactive
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
       
    }
    
    @objc func keyboardWillBeHidden(note: Notification) {
        commentBar.inputTextView.text = nil
        showsCommentsBar = false
        becomeFirstResponder()
        
    }
    
    
    //These two functions are from the MessageInputBar pod. It doesn't make much sense to us but it does work and this is what it's like working with intermediate ios development is like.
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return showsCommentsBar //dont show the Comments Bar by default
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadPosts()
    }
    
    @objc func loadPosts() {
        let query = PFQuery(className: "Posts")
        query.includeKeys(["author", "comments", "comments.user"]) //if you don't include the includeKey for the column author and comments, then it will just retrieve the pointer to the user and the comments without actual User object or comment object. So we are saying go fetch the actual object with includeKey()s. including the key comments.author will do the same thing where it will retrieve not only the comment object, but also the actual user object for the corresponding comment
        query.limit = 20 //asking only for the last 20
        
        query.findObjectsInBackground {(posts, error) in //posts refers to an array of PFObjects
            if posts != nil {
                //if the array of objects that is fetched is not empty, then put those objects into the variable posts we declared before.
                self.posts = posts! //self.posts is the variable posts we created
                self.posts.reverse() //reverse the order of the posts so that the most recent post aka the last one on the list is in the 0th index and so on.
                self.tableView.reloadData() //tells the table View to reload itself so it will call the dataSource functions again.
                // Tell the refreshControl to stop spinning
                self.myRefreshControl.endRefreshing()
            } else {
                // Log details of the failure
                print(error!.localizedDescription)
            }
        }
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        //Create the comment
        
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedPost //column post will store the post that the comment belongs to
        comment["user"] = PFUser.current() //column for the user who wrote the comment
        
        //adds the comment PFObject to the Posts class as a column named "comments" and adds the comment to the post that is selected
        selectedPost.addUniqueObject(comment, forKey: "comments")
        
        //Saves aka updates the post with the new comment object as well
        selectedPost.saveInBackground { (success, error) in
            if success {
                print("Comment saved")
            } else {
                print("Error saving comment")
            }
        }
        tableView.reloadData()
        //Clear and dismiss the input bar
            commentBar.inputTextView.text = nil
            showsCommentsBar = false
            becomeFirstResponder()
            commentBar.inputTextView.resignFirstResponder()
    }
    
    //These are the two required functions for the dataSource:
        //number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //for the number of rows, we want to return the number of comments + 1. Rows for the each of the comments and one row for the photo.
        let post = posts[section]
        
        //Since variable comments is an optional, it can be nil. But how do you get the count of comments if it is nil?
        // - Use the ?? operator. If comments happens to be nil, then it will take on the default value [] empty array
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        return comments.count + 2 // the 2 is one for post cell and one for comment cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count //returns the number of posts for the number of sections bc you want a section for each post
        
    }
    
        //cell for row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == 0 { //row 0 of a section is the prototype cell with the photo and the caption
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            
            
            let user = post["author"] as! PFUser
            
            cell.usernameLabel.text = user.username
            
            cell.captionLabel.text = (post["caption"] as! String)
            
            let imageFile = post["image"] as! PFFileObject //the PFFileObject has a url to the image in png
            
            let urlString = imageFile.url! // use .url on the image file to access the image url inside the file which is given as a string
        
            let url = URL(string: urlString)! //create an actual URL from that string url.
            
            //now we can use that image url with AmofireImage library to load the image and set the image view to that image to display it
            cell.photoView.af.setImage(withURL: url)
            return cell
            
        } else if indexPath.row <= comments.count { //the rest of the rows in the section are for each comments
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as? String
            let user = comment["user"] as! PFUser
            cell.nameLabel.text = user.username
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            
            return cell
        }
    }
    
    
    @IBAction func onLogoutButton(_ sender: Any) {
        PFUser.logOut() //clears the current user or the parse cached currentUser object
        //PFUser.current will now be nil
        
        let main = UIStoryboard(name: "Main", bundle: nil) //this is just parsing the XML
        let loginViewController = main.instantiateViewController(identifier: "LoginViewController")
        //now we need to access the window, but how do we do that in here?
        let delegate = self.view.window?.windowScene?.delegate as! SceneDelegate
        //Now we have access to that delegate(SceneDelegate)
        delegate.window?.rootViewController = loginViewController
    }
    
    //table view supports selection by default, so if you type DidSelect, then it will autocomplete to give this function which executes every time a user clicks on a post in the Feed screen
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section] //the post at the selected row
        
        //create the comment object. You do this the same way you create any other PFObject.
        let comments = (post["comments"]) as? [PFObject] ?? []
        
        if indexPath.row == comments.count + 1 {
            showsCommentsBar  = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
            
            selectedPost = post
            
        }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

