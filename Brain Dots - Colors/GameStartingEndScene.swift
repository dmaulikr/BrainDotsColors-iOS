//
//  GameStartingEndScene.swift
//  Brain Dots - Colors
//
//  Created by Sanjith Kanagavel on 18/06/16.
//  Copyright © 2016 Sanjith Kanagavel. All rights reserved.
//

import Foundation
import SpriteKit

class GameStartingEndScene : SKScene{
    
    let left_quad1 = SKSpriteNode(imageNamed: "main_circle") //red
    let right_quad1 = SKSpriteNode(imageNamed: "main_circle") //red
    let play_button = SKSpriteNode (imageNamed:"play_button")
    var bestScore = SKLabelNode(fontNamed: "Chalkduster")
    var score = SKLabelNode (fontNamed: "Chalkduster")
    let share = SKSpriteNode(imageNamed: "share")
    let love = SKSpriteNode(imageNamed: "like")
    var framesCount = 0;
    let leaderBoard = SKSpriteNode(imageNamed: "leaderboard")
    var jumpIntoGame = false;
    var viewController: GameViewController!
    
    var updatedscore:Int?
    var setUpdatedscore:Int? {
        get { return updatedscore }
        set { updatedscore = newValue }
    }
    
    override func didMoveToView(view: SKView) {
        
        backgroundColor = SKColor.whiteColor();
        removeAllChildren();
        jumpIntoGame = false;
        
        left_quad1.zPosition = 2
        left_quad1.position = CGPoint(x: 0, y: size.height/2)
        left_quad1.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        left_quad1.size = CGSize(width:size.width/4,height:size.width/4)
        
        right_quad1.zPosition = 2
        right_quad1.position = CGPoint(x: size.width, y: size.height/2)
        right_quad1.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        right_quad1.size = CGSize(width:size.width/4,height:size.width/4)
        
        play_button.zPosition = 2
        play_button.position = CGPoint(x: size.width/2, y: size.height/2)
        play_button.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        play_button.size = CGSize(width:size.width/6,height:size.width/6)
        play_button.name = "playbtn"
        play_button.userInteractionEnabled = false
        
        leaderBoard.zPosition = 2
        leaderBoard.position = CGPoint(x: size.width/2, y: size.height/4)
        leaderBoard.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        leaderBoard.size = CGSize(width:size.width/10,height:size.width/10)
        leaderBoard.name = "leaderBoard"
        leaderBoard.userInteractionEnabled = false
        
        share.zPosition = 2
        share.position = CGPoint(x: size.width/2 - 2*leaderBoard.size.width, y: size.height/4)
        share.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        share.size = CGSize(width:size.width/12,height:size.width/12)
        share.name = "share"
        share.userInteractionEnabled = false
        
        love.zPosition = 2
        love.position = CGPoint(x: size.width/2 + 2*leaderBoard.size.width, y: size.height/4)
        love.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        love.size = CGSize(width:size.width/12,height:size.width/12)
        love.name = "share"
        love.userInteractionEnabled = false
        love.userInteractionEnabled = false
        
        bestScore = SKLabelNode(fontNamed: "Chalkduster")
        bestScore.zPosition=2
        bestScore.fontSize = 4 * bestScore.fontSize;
        bestScore.horizontalAlignmentMode = .Center
        bestScore.position = CGPoint(x: size.width/2, y: 3 * size.height/4)
        bestScore.fontColor = UIColor(netHex:0x44c374)
        
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let updatedtime = defaults.stringForKey("updatedtime")
        {
            print(updatedtime)
            defaults.removeObjectForKey("updatedtime");
            score = SKLabelNode(fontNamed: "Chalkduster")
            score.zPosition=2
            score.fontSize = 2 * score.fontSize;
            score.horizontalAlignmentMode = .Center
            score.position = CGPoint(x: size.width/2, y: 3 * size.height/4 - bestScore.fontSize - 10)
            score.fontColor = UIColor.redColor();
            score.text = "Score : 0"
            if let scoreStr = defaults.stringForKey("points")
            {
                score.text = "Score : " + String(scoreStr);
                addChild(score)
                if let highscoreStr = defaults.stringForKey("highscore")
                {
                    if (Int(highscoreStr) < Int(scoreStr))
                    {
                        defaults.setObject(scoreStr, forKey: "highscore")
                        self.viewController.submitScore(Int(scoreStr)!);
                    }
                    else{
                        //Not a high score
                    }
                }else{
                    //first game and no high score has not been added and it has been added
                    defaults.setObject(scoreStr, forKey: "highscore")
                }
                defaults.removeObjectForKey("points")
            }
            defaults.removeObjectForKey("updatedtime")
        }
        defaults.synchronize();
        
        if let highscoreStr = defaults.stringForKey("highscore")
        {
            bestScore.text = "Best Score : " + highscoreStr
        }
        else
        {
            defaults.setObject("0", forKey: "highscore")
            bestScore.text = "Best Score : 0"
        }
        defaults.synchronize();
        
        addChild(play_button)
        addChild(bestScore)
        addChild(left_quad1)
        addChild(right_quad1)
        addChild(leaderBoard)
        addChild(love)
        addChild(share)
    }
    
    
     override func update(currentTime: CFTimeInterval) {
        if(jumpIntoGame) {
            return;
        }
        left_quad1.runAction(SKAction.rotateByAngle(CGFloat(M_PI_4/20), duration: 0.0))
        right_quad1.runAction(SKAction.rotateByAngle(CGFloat(-M_PI_4/20), duration: 0.0))
        /*
        framesCount += 1;
        if(framesCount > 10 )
        {
        if ( play_button.size.height == size.width/8 )
        {
            play_button.size = CGSize(width:size.width/6,height:size.width/6)
        }
        else
        {
            play_button.size = CGSize(width:size.width/8,height:size.width/8)
        }
            framesCount = 0;
        }*/
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        if play_button.containsPoint(touch.locationInNode(self)) {
            jumpIntoGame = true;
            let transition = SKTransition.revealWithDirection(.Down, duration: 1.0)
            let scene = GameScene(size:CGSize(width: 2048, height: 1536))
            //view?.showsFPS = true
            scene.scaleMode = .AspectFill
            scene.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
            scene.oldScene = self
            scene.viewController = self.viewController
            view?.presentScene(scene,transition: transition)
        }
        else if leaderBoard.containsPoint(touch.locationInNode(self))
        {
            self.viewController.showLeaderboard();
        }
        else if share.containsPoint(touch.locationInNode(self))
        {
            self.viewController.socialShare( "Try this app \"Brain Dots - Colors\" ! \n@BrainDotsColors \n#BrainDotsColors", sharingImage: snapshotImage(), sharingURL: NSURL(string: "https://itunes.apple.com/us/app/brain-dots-colors/id1125722878"));

        }
        else if love.containsPoint(touch.locationInNode(self))
        {
            self.viewController.rateApp()
        }
    }
    
    func snapshotImage() ->UIImage {
        UIGraphicsBeginImageContextWithOptions(UIScreen.mainScreen().bounds.size, false, 0)
        self.view!.drawViewHierarchyInRect(self.view!.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image;
    }

    
}


extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}