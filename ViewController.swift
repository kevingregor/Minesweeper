//
//  ViewController.swift
//  Minesweeper
//
//  Created by Kevin Gregor on 12/4/15.
//  Copyright © 2015 Kevin Gregor. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var grid = [[(UIButton)]]()
    var dataArray = [Tile]()
    var gridData = [[(Tile)]]()
    
    var difficulty:Int = 0
    var gridSize:Int = 8 // gridSize by gridSize board
    var numMines: Int = 10
    var nonMinesTapped: Int = 0
    var time:Int = 0
    var highscore:Int = 0
    
    @IBOutlet weak var minesLeft: UILabel!
    @IBOutlet weak var timeLeft: UILabel!
    @IBOutlet weak var restartButton: UIButton!
    
    var timer:NSTimer!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let hs = NSUserDefaults.standardUserDefaults().objectForKey("HighScore") as? Int ?? highscore
        if hs < highscore || highscore == 0 {
            highscore = hs
        }
        
        restartButton.layer.borderColor = UIColor.blackColor().CGColor
        restartButton.layer.borderWidth = 3
        
        time = 0
        nonMinesTapped = 0
        
        timeLeft.text = "Time Passed: \(time)"
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "addTime:", userInfo: nil, repeats: true)
        if difficulty == 0 {
            gridSize = 8
            numMines = 10
            minesLeft.text = "Mines: \(numMines)"
            initializeBoard()
        }
        else if difficulty == 1 {
            gridSize = 10
            numMines = 20
            minesLeft.text = "Mines: \(numMines)"
            initializeBoard()
        }
        else {
            gridSize = 12
            numMines = 30
            minesLeft.text = "Mines: \(numMines)"
            initializeBoard()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidEnterBackground:", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
    }
    
    func applicationDidEnterBackground(notif: NSNotification) {
        NSUserDefaults.standardUserDefaults().setObject(highscore, forKey: "HighScore")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addTime(sender:NSTimer) {
        time++
        timeLeft.text = "Time Passed: \(time)"
    }
    
    func initializeBoard() {
        self.dataArray.removeAll()
        for _ in 0...(gridSize-1) {
            let arry = Array(count: gridSize, repeatedValue: Tile())
            gridData.append(arry)
            let array = Array(count: gridSize, repeatedValue: UIButton())
            grid.append(array)
        }
        
        for _ in 0...(gridSize*gridSize) {
            self.dataArray.append(Tile())
        }
        addMines(numMines)
        dataArrayToGrid()
    }
    
    func addMines(num: Int) {
        if num == 0 {
            return
        }
        let rand = Int(arc4random_uniform(UInt32(dataArray.count)))
        let addMine = dataArray[rand]
        if addMine.containsMine == false {
            addMine.containsMine = true
            dataArray[rand] = addMine
            addMines(num-1)
        }
        else {
            addMines(num)
        }
    }
    
    func dataArrayToGrid() {
        for i in 0...(gridSize-1) {
            for j in 0...(gridSize-1) {
                self.gridData[i][j] = self.dataArray[i*gridSize + j]
                let width = (UIScreen.mainScreen().bounds.width - 50)/CGFloat(gridSize)
                let verticalOffset = UIScreen.mainScreen().bounds.height - UIScreen.mainScreen().bounds.width - 25
                let button = UIButton(frame: CGRect(x: 26 - CGFloat(gridSize/2) + (width+1)*CGFloat(j), y: verticalOffset + (width+1)*CGFloat(i), width: width, height: width))
                button.userInteractionEnabled = true
                button.tag = i*gridSize + j + 1
                button.addTarget(self, action: "tileTapped:", forControlEvents: .TouchUpInside)
                button.setTitle("", forState: .Normal)
                button.backgroundColor = UIColor.grayColor()
                button.layer.borderColor = UIColor.blackColor().CGColor
                button.layer.borderWidth = 3
                
                self.view.addSubview(button)
                
                self.grid[i][j] = button
            }
        }
    }

    func tileTapped(sender:UIButton) {
        let tag = sender.tag
        if dataArray[tag - 1].isPressed == false {
            if dataArray[tag - 1].containsMine {
                loseGame()
            }
            else {
                nonMinesTapped++
                if nonMinesTapped == gridSize*gridSize - numMines {
                    if time < highscore || highscore == 0{
                        highscore = time
                    }
                    timer.invalidate()
                    winGame()
                }
                sender.backgroundColor = UIColor.whiteColor()
                let tile = dataArray[tag - 1]
                tile.isPressed = true
                tile.adjacentMines = getAdjacentMines(tag - 1)
                if tile.adjacentMines != 0 {
                    sender.setTitleColor(UIColor.redColor(), forState: .Normal)
                    sender.setTitle("\(tile.adjacentMines)", forState: .Normal)
                }
            }
        }
    }
    
    func chainZeroMines(i:Int, j:Int) {
        if i > 0 && i < gridSize - 1 && j > 0 && j < gridSize - 1 {
            // Main area of board
            for u in (i-1)...(i+1) {
                for v in (j-1)...(j+1) {
                    if !(u == i && v == j) {
                        if !gridData[u][v].containsMine {
                            let tag = u*gridSize + v + 1
                            let sender = view.viewWithTag(tag)! as! UIButton
                            tileTapped(sender)
                        }
                    }
                }
            }
        }
        else if i == 0 && j > 0 && j < gridSize - 1 {
            // Top row minus corners
            for u in (i)...(i+1) {
                for v in (j-1)...(j+1) {
                    if !(u == i && v == j) {
                        if !gridData[u][v].containsMine {
                            let tag = u*gridSize + v + 1
                            let sender = view.viewWithTag(tag)! as! UIButton
                            tileTapped(sender)
                        }
                    }
                }
            }
        }
        else if i == gridSize - 1 && j > 0 && j < gridSize - 1 {
            // Bottom row minus corners
            for u in (i-1)...(i) {
                for v in (j-1)...(j+1) {
                    if !(u == i && v == j) {
                        if !gridData[u][v].containsMine {
                            let tag = u*gridSize + v + 1
                            let sender = view.viewWithTag(tag)! as! UIButton
                            tileTapped(sender)
                        }
                    }
                }
            }
        }
        else if i > 0 && i < gridSize - 1 && j == 0 {
            // Left column minus corners
            for u in (i-1)...(i+1) {
                for v in (j)...(j+1) {
                    if !(u == i && v == j) {
                        if !gridData[u][v].containsMine {
                            let tag = u*gridSize + v + 1
                            let sender = view.viewWithTag(tag)! as! UIButton
                            tileTapped(sender)
                        }
                    }
                }
            }
        }
        else if i > 0 && i < gridSize - 1 && j == gridSize - 1 {
            // Right column minus corners
            for u in (i-1)...(i+1) {
                for v in (j-1)...(j) {
                    if !(u == i && v == j) {
                        if !gridData[u][v].containsMine {
                            let tag = u*gridSize + v + 1
                            let sender = view.viewWithTag(tag)! as! UIButton
                            tileTapped(sender)
                        }
                    }
                }
            }
        }
        else if i == 0 && j == 0 {
            // Top left corner
            for u in (i)...(i+1) {
                for v in (j)...(j+1) {
                    if !(u == i && v == j) {
                        if !gridData[u][v].containsMine {
                            let tag = u*gridSize + v + 1
                            let sender = view.viewWithTag(tag)! as! UIButton
                            tileTapped(sender)
                        }
                    }
                }
            }
        }
        else if i == 0 && j == gridSize - 1 {
            // Top right corner
            for u in (i)...(i+1) {
                for v in (j-1)...(j) {
                    if !(u == i && v == j) {
                        if !gridData[u][v].containsMine {
                            let tag = u*gridSize + v + 1
                            let sender = view.viewWithTag(tag)! as! UIButton
                            tileTapped(sender)
                        }
                    }
                }
            }
        }
        else if i == gridSize - 1 && j == 0 {
            // Bottom left corner
            for u in (i-1)...(i) {
                for v in (j)...(j+1) {
                    if !(u == i && v == j) {
                        if !gridData[u][v].containsMine {
                            let tag = u*gridSize + v + 1
                            let sender = view.viewWithTag(tag)! as! UIButton
                            tileTapped(sender)
                        }
                    }
                }
            }
        }
        else if i == gridSize - 1 && j == gridSize - 1 {
            // Bottom right corner
            for u in (i-1)...(i) {
                for v in (j-1)...(j) {
                    if !(u == i && v == j) {
                        if !gridData[u][v].containsMine {
                            let tag = u*gridSize + v + 1
                            let sender = view.viewWithTag(tag)! as! UIButton
                            tileTapped(sender)
                        }
                    }
                }
            }
        }
    }
    
    func getAdjacentMines(index:Int) -> Int {
        var adjMines = 0
        
        let j:Int = index % gridSize // Col
        let i:Int = index/gridSize // Row
        if i > 0 && i < gridSize - 1 && j > 0 && j < gridSize - 1 {
            // Main area of board
            for u in (i-1)...(i+1) {
                for v in (j-1)...(j+1) {
                    if !(u == i && v == j) {
                        if gridData[u][v].containsMine {
                            adjMines++
                        }
                    }
                }
            }
        }
        else if i == 0 && j > 0 && j < gridSize - 1 {
            // Top row minus corners
            for u in (i)...(i+1) {
                for v in (j-1)...(j+1) {
                    if !(u == i && v == j) {
                        if gridData[u][v].containsMine {
                            adjMines++
                        }
                    }
                }
            }
        }
        else if i == gridSize - 1 && j > 0 && j < gridSize - 1 {
            // Bottom row minus corners
            for u in (i-1)...(i) {
                for v in (j-1)...(j+1) {
                    if !(u == i && v == j) {
                        if gridData[u][v].containsMine {
                            adjMines++
                        }
                    }
                }
            }
        }
        else if i > 0 && i < gridSize - 1 && j == 0 {
            // Left column minus corners
            for u in (i-1)...(i+1) {
                for v in (j)...(j+1) {
                    if !(u == i && v == j) {
                        if gridData[u][v].containsMine {
                            adjMines++
                        }
                    }
                }
            }
        }
        else if i > 0 && i < gridSize - 1 && j == gridSize - 1 {
            // Right column minus corners
            for u in (i-1)...(i+1) {
                for v in (j-1)...(j) {
                    if !(u == i && v == j) {
                        if gridData[u][v].containsMine {
                            adjMines++
                        }
                    }
                }
            }
        }
        else if i == 0 && j == 0 {
            // Top left corner
            for u in (i)...(i+1) {
                for v in (j)...(j+1) {
                    if !(u == i && v == j) {
                        if gridData[u][v].containsMine {
                            adjMines++
                        }
                    }
                }
            }
        }
        else if i == 0 && j == gridSize - 1 {
            // Top right corner
            for u in (i)...(i+1) {
                for v in (j-1)...(j) {
                    if !(u == i && v == j) {
                        if gridData[u][v].containsMine {
                            adjMines++
                        }
                    }
                }
            }
        }
        else if i == gridSize - 1 && j == 0 {
            // Bottom left corner
            for u in (i-1)...(i) {
                for v in (j)...(j+1) {
                    if !(u == i && v == j) {
                        if gridData[u][v].containsMine {
                            adjMines++
                        }
                    }
                }
            }
        }
        else if i == gridSize - 1 && j == gridSize - 1 {
            // Bottom right corner
            for u in (i-1)...(i) {
                for v in (j-1)...(j) {
                    if !(u == i && v == j) {
                        if gridData[u][v].containsMine {
                            adjMines++
                        }
                    }
                }
            }
        }
        if adjMines == 0 {
            chainZeroMines(i, j: j)
        }
        return adjMines
    }
    @IBAction func restartGame(sender: UIButton) {
        timer.invalidate()
        self.viewDidLoad()
    }
    
    func loseGame() {
        timer.invalidate()
        let loseGameAlert:UIAlertController = UIAlertController(title: "You Lost!", message: "Hit OK to return to the Main Menu", preferredStyle: .Alert)
        let okAction:UIAlertAction = UIAlertAction(title: "OK", style: .Default) { (UIAlertAction) -> Void in
            self.performSegueWithIdentifier("backToMenu", sender: self)
        }
        loseGameAlert.addAction(okAction)
        self.presentViewController(loseGameAlert, animated: true, completion: nil)
    }
    
    func winGame() {
        let winGameAlert:UIAlertController = UIAlertController(title: "You Won!", message: "Your score was: \(time). Your high score is \(highscore). Hit OK to return to the Main Menu", preferredStyle: .Alert)
        let okAction:UIAlertAction = UIAlertAction(title: "OK", style: .Default) { (UIAlertAction) -> Void in
            self.performSegueWithIdentifier("backToMenu", sender: self)
        }
        winGameAlert.addAction(okAction)
        self.presentViewController(winGameAlert, animated: true, completion: nil)
    }
    
    class Tile {
        var isPressed = false
        var containsMine = false
        var adjacentMines = 0
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let dest = segue.destinationViewController as! MainMenuViewController
        dest.highscore = self.highscore
    }
}

