//
//  MainMenuViewController.swift
//  Minesweeper
//
//  Created by Kevin Gregor on 12/4/15.
//  Copyright © 2015 Kevin Gregor. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {
    
    var difficulty:Int = 0
    var highscore:Int = 0

    @IBOutlet weak var highscoreLabel: UILabel!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let hs = NSUserDefaults.standardUserDefaults().objectForKey("HighScore") as? Int ?? highscore
        if hs < highscore || highscore == 0 {
            highscore = hs
        }
        highscoreLabel.text = "High Score: \(highscore)"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidEnterBackground:", name: UIApplicationDidEnterBackgroundNotification, object: nil)
    }
    
    func applicationDidEnterBackground(notif: NSNotification) {
        NSUserDefaults.standardUserDefaults().setObject(highscore, forKey: "HighScore")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func buttonPressed(sender: UIButton) {
        difficulty = sender.tag - 1
        performSegueWithIdentifier("toGame", sender: self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let dest = segue.destinationViewController as! ViewController
        dest.difficulty = self.difficulty
        dest.highscore = self.highscore
    }

}
