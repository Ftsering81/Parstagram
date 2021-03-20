//
//  SceneDelegate.swift
//  Parstagram
//
//  Created by Fnu Tsering on 3/11/21.
//

import UIKit
import Parse

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        
        //Add User persistance across app restarts
        if PFUser.current() != nil {
            //this this code executes then that means that the user is already logged in and so we want to immediately switch to the feed viewcontroller and not the login view controller.
            login() //this login function we wrote does the switching to the Feed Navigation controller
        }
            
        guard let _ = (scene as? UIWindowScene) else { return }
        
    }
    
    //Login User
    func login() {
        let main = UIStoryboard(name: "Main", bundle: nil) //loads up the Main.storyboard storyboard. All we have done is parsed this XML
        
        //Now that we have loaded the Main storyboard, this instantiates a view controller from that storyboard. We instantiated the Navigation View Controller that navigates to the Feed View Controller and the Camera View Controller by providing its identifier. Now we have an instance of that navigation controller
        let feedNavigationController = main.instantiateViewController(identifier: "FeedNavigationController")
        
        //What is a window?
        // There is only one window per application and it is what contains everything else. You don't ever use it in any other circumstances except in cases like this for staying logged in. The window has the root view controller, which is the one that is being displayed. So if you change what that root view controller is, then with no animation, it will automatically just switch that default view controller to the one we changed it to.
        window?.rootViewController = feedNavigationController //view controller currently being set in Storyboard as default will be overwritten and set to feedNavigationController
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    

}

