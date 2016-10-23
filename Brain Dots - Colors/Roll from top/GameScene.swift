//
//  GameScene.swift
//  Roll from top
//
//  Created by Sanjith Kanagavel on 16/06/16.
//  Copyright (c) 2016 Sanjith Kanagavel. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene,SKPhysicsContactDelegate {
    
    let centerImage_1 = SKSpriteNode(imageNamed: "center_circle_1-1")
    let centerImage_2 = SKSpriteNode (imageNamed: "center_circle_2")
    let left_circle = SKSpriteNode(imageNamed: "main_circle");
    let right_circle = SKSpriteNode(imageNamed: "main_circle");
    var viewController: GameViewController!
    let scored = SKAction.playSoundFileNamed("scored.wav",waitForCompletion: false);
    let punch =  SKAction.playSoundFileNamed("punch.wav",waitForCompletion: false);
    let red = SKSpriteNode(imageNamed: "red_circle"); // 1
    let blue = SKSpriteNode(imageNamed: "blue_circle"); // 2
    let green = SKSpriteNode(imageNamed: "green_circle"); // 3
    let yellow = SKSpriteNode(imageNamed: "red_circle"); // 4
    let defaults = NSUserDefaults.standardUserDefaults()
    let left_quad1 = SKSpriteNode(imageNamed: "main_circle") //red
    let right_quad1 = SKSpriteNode(imageNamed: "main_circle") //red
    
    let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
    let hint_label = SKLabelNode (fontNamed: "Chalkduster")
    
    var tutorial_show = true;
    var left_touch = false;
    var right_touch = false;
    var left_touchPoint = CGPointZero;
    var right_touchPoint = CGPointZero;
    var obstacleArray = [obstacleStruct]()
    var gameLevel = 0.0;
    var score = 0; // 0 - 10 : Level 1, 10 - 20 : Level 2, 20 - 30 : Level 3, 30 - anything : Level 4
    var framesCount = 0;
    
    let left_bitmask = UInt32(0b1);
    let right_bitmask = UInt32(0b10);
    let obstacles_bitmask = UInt32(0b11);
    
    var toggler = false;
    var gameOver = false;
    
    var oldScene:SKScene?
    var setOldScene:SKScene? {
        get { return oldScene }
        set { oldScene = newValue }
    }
    
    let hint_left = SKSpriteNode( imageNamed : "updown_left" );
    let hint_right = SKSpriteNode( imageNamed : "updown" );
    
    struct obstacleStruct
    {
        let isLeft : Bool
        let spriteNode : SKSpriteNode
        let timeCreated : Int64
        init( left: Bool, sn: SKSpriteNode,time : Int64) {
            isLeft = left
            spriteNode = sn
            timeCreated = time
        }
    }
    
    override func didMoveToView(view: SKView) {
        score = 0;
        gameLevel = 1.5;
        backgroundColor = SKColor.whiteColor();
        physicsWorld.contactDelegate = self;
        centerImage_1.zPosition = 1;
        centerImage_1.position = CGPoint(x: size.width/2, y: size.height/2)
        centerImage_1.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        centerImage_1.size = CGSize(width:size.width/8,height:size.width/8)
        
        centerImage_2.zPosition = 0
        centerImage_2.position = CGPoint(x: size.width/2, y: size.height/2)
        centerImage_2.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        centerImage_2.size = CGSize(width:size.width/8,height:size.width/8)
    
        left_quad1.zPosition = 2
        left_quad1.position = CGPoint(x: 0, y: size.height/2)
        left_quad1.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        left_quad1.size = CGSize(width:size.width/4,height:size.width/4)
        left_quad1.name="left_quad1";
        left_quad1.physicsBody = SKPhysicsBody(circleOfRadius: left_quad1.size.width/2)
        left_quad1.physicsBody!.dynamic = true
        left_quad1.physicsBody!.categoryBitMask = left_bitmask;
        left_quad1.physicsBody!.contactTestBitMask = obstacles_bitmask;
        left_quad1.physicsBody!.collisionBitMask = 0
        left_quad1.physicsBody?.restitution = 0
        
        right_quad1.zPosition = 2
        right_quad1.position = CGPoint(x: size.width, y: size.height/2)
        right_quad1.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        right_quad1.size = CGSize(width:size.width/4,height:size.width/4)
        right_quad1.name="right_quad1";
        right_quad1.physicsBody = SKPhysicsBody(circleOfRadius: right_quad1.size.width/2)
        right_quad1.physicsBody!.dynamic = true
        right_quad1.physicsBody!.categoryBitMask = right_bitmask;
        right_quad1.physicsBody!.contactTestBitMask = obstacles_bitmask;
        right_quad1.physicsBody!.collisionBitMask = 0
        
        scoreLabel.text = "Score : 0"
        scoreLabel.zPosition=3
        scoreLabel.fontSize = 2 * scoreLabel.fontSize;
        scoreLabel.horizontalAlignmentMode = .Center
        scoreLabel.position = CGPoint(x: size.width/2, y: 3 * size.height/4)
        scoreLabel.fontColor = UIColor.blackColor()
        if let games = defaults.stringForKey("noofgames")
        {
            if ( Int(games) >= 3 )
            {
                tutorial_show = false;
            }
            else{
                self.defaults.setValue( Int(games)!+1, forKey: "noofgames")
                self.defaults.synchronize();
                tutorial_show = true;
            }
            
        }
        else
        {
            self.defaults.setValue(1, forKey: "noofgames")
            self.defaults.synchronize();
            tutorial_show = true;
        }
        
        hint_left.zPosition = 1
        hint_left.size = CGSize(width:size.width/9,height:size.height/3)
        hint_left.position = CGPoint(x: left_quad1.size.width/2 + hint_left.size.width, y: size.height/2)
        hint_left.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        hint_right.zPosition = 1
        hint_right.size = CGSize(width:size.width/9,height:size.height/3)
        hint_right.position = CGPoint(x: size.width -  right_quad1.size.width/2 - hint_right.size.width, y: size.height/2)
        hint_right.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        hint_label.text = "Move wheels and hit balls with same color"
        hint_label.zPosition=1
        hint_label.fontSize = 2 * hint_label.fontSize;
        hint_label.horizontalAlignmentMode = .Center
        hint_label.position = CGPoint(x: size.width/2, y:size.height/4)
        hint_label.fontColor = UIColor.grayColor()
        
        if(tutorial_show)
        {
            addChild(hint_left)
            addChild(hint_right)
            addChild(hint_label)
        }
        
        addChild(scoreLabel)
        addChild(centerImage_1)
        addChild(centerImage_2)
        
        addChild(left_quad1)
        addChild(right_quad1)
        left_quad1.runAction(SKAction.rotateByAngle(CGFloat(-3 * M_PI_4), duration: 0))
        right_quad1.runAction(SKAction.rotateByAngle(CGFloat(-M_PI_4), duration: 0))
        print("Initial Rotation %f",left_quad1.zRotation);
        print("Initial Rotation %f",right_quad1.zRotation);
    }
    
    override func update(currentTime: CFTimeInterval) {
        
        if(tutorial_show)
        {
            return;
        }
        
        if(gameOver) {
            return;
        }
        framesCount += 1
        runAnimations()
        spawnEnimes()
    }
    
    func runAnimations() {
        if(centerImage_1.zRotation >= 6.28319 )
        {
            centerImage_1.zRotation = 0
        }
        centerImage_1.zRotation+=0.1047198333 //cannot be fixed number always
    }
    
    func spawnEnimes()
    {
        if(Double(framesCount) * gameLevel >=  ( 240 / gameLevel ) )
        {
           framesCount = 0;
           var itemNumber = arc4random_uniform(4) + 1;
           var clone_obj = SKSpriteNode(imageNamed: "red_circle"); // 1
            switch(itemNumber)
            {
                case 1:
                    clone_obj = SKSpriteNode(imageNamed: "red_circle"); // 1
                    clone_obj.name="red"
                break;
                case 2:
                    clone_obj = SKSpriteNode(imageNamed: "blue_circle"); // 2
                    clone_obj.name="blue"
                break;
                case 3:
                    clone_obj = SKSpriteNode(imageNamed: "yellow_circle"); // 4
                    clone_obj.name="yellow"
                break;
                case 4:
                    clone_obj = SKSpriteNode(imageNamed: "green_circle"); // 3
                    clone_obj.name="green"
                break;
                default:
                    clone_obj = red;
                    clone_obj.name="1"
                    itemNumber = 1;
            }
           clone_obj.zPosition = -1
           clone_obj.position = CGPoint(x: size.width/2, y: size.height/2)
           clone_obj.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            let ball_size =  ( arc4random_uniform(3) + 1 );
            
            if(ball_size == 1)
            {
                clone_obj.size = CGSize(width:size.width/22,height:size.width/22)
            }
            else if(ball_size==2)
            {
                clone_obj.size = CGSize(width:size.width/33,height:size.width/33)
            }
            else if(ball_size == 3)
            {
                clone_obj.size = CGSize(width:size.width/40,height:size.width/40)
            }
           
           clone_obj.physicsBody = SKPhysicsBody(circleOfRadius: clone_obj.size.width/4)
           clone_obj.physicsBody!.dynamic = true
           clone_obj.physicsBody!.categoryBitMask = obstacles_bitmask;
           clone_obj.physicsBody!.contactTestBitMask = left_bitmask | right_bitmask;
           clone_obj.physicsBody!.collisionBitMask = 0
           if( score > 10 )
           {
                if( score > 10 && score <= 20 )
                {
                    gameLevel = 1.6;
                }
                else if (score > 20  && score <= 30 )
                {
                    gameLevel = 1.65;
                }
                else if( score > 30 && score <= 40 )
                {
                    gameLevel = 1.7;
                }
                else if( score > 40 && score <= 50 )
                {
                    gameLevel = 1.75;
                }
                else if( score > 50 && score <= 60 )
                {
                    gameLevel = 1.8;
                }
                else if( score > 60 && score <= 70 )
                {
                    gameLevel = 1.85;
                }
                else if( score > 70 && score <= 80 )
                {
                    gameLevel = 1.9;
                }
                else if ( score > 80 && score <= 90 )
                {
                    gameLevel = 1.95;
                }
                else if ( score > 90 && score <= 100 )
                {
                    gameLevel = 1.95;
                }
                else if ( score > 100 && score <= 110 )
                {
                    gameLevel = 2;
                }
                else if ( score > 110 && score <= 120 )
                {
                    gameLevel = 2.05;
                }
                else if ( score > 120 && score <= 130 )
                {
                    gameLevel = 2.10;
                }
                else if ( score > 130 && score <= 140 )
                {
                    gameLevel = 2.15;
                }
                else
                {
                    gameLevel = 2.20;
                }
                toggler = !toggler;
                obstacleArray.append(obstacleStruct(left:toggler,sn: clone_obj,time: Int64(NSDate().timeIntervalSince1970*1000)));
           }
           else{
                obstacleArray.append(obstacleStruct(left:( arc4random_uniform(2) + 1 ) ==  1 ? true : false,sn: clone_obj,time: Int64(NSDate().timeIntervalSince1970*1000)));
            }
           
           addChild(clone_obj);
        }
        else
        {
            var i = 0;
            for obj in  obstacleArray {
                if( (obj.spriteNode.position.x - 5 <= 0 && obj.isLeft) || ( obj.spriteNode.position.x+5 >= size.width && !obj.isLeft))
                {
                    print("Removing");
                    obj.spriteNode.removeFromParent();
                    obstacleArray.removeAtIndex(i)
                    
                } else {
                    if(obj.isLeft)
                    {
                        obj.spriteNode.position.x = obj.spriteNode.position.x - 5;
                    }
                    else
                    {
                        obj.spriteNode.position.x = obj.spriteNode.position.x + 5;
                    }
                i += 1;
                }
            }
        }
        //spwan a ball
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if (tutorial_show)
        {
            return;
        }
        
        if(gameOver)
        {
            return;
        }
        /* Start moving node to touch location */
        if let touch = touches.first {
            let touchLocation = touch.locationInNode(self)
            if(touchLocation.x < size.width/2)
            {
                //Left
                //print("Left Began");
                left_touch = true;
                left_touchPoint = touchLocation;
            }
            else if(touchLocation.x > size.width/2) {
                //Rigth
                //print("Right Began");
                right_touch = true;
                right_touchPoint = touchLocation;
            }
        }

    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if (tutorial_show)
        {
            hint_right.removeFromParent();
            hint_left.removeFromParent();
            hint_label.removeFromParent();
            tutorial_show = false;
            return;
        }
        
        if(gameOver)
        {
            return;
        }
        /* Update to new touch location */
        if let touch = touches.first {
            let touchLocation = touch.locationInNode(self)
            if(touchLocation.x < size.width/2)
            {
                //Left
                //print("Left Moved");
                if(left_touchPoint.y < touchLocation.y)
                {
                    //left up
                    //print("Left Up");
                    //left_quad1.zRotation +=  0.1047198333 * 1.4 //cannot be fixed number always
                    left_quad1.runAction(SKAction.rotateByAngle(CGFloat(M_PI_4/6), duration: 0.0))
                }
                else {
                    //left down
                    //print("Left Down");
                    //left_quad1.zRotation -= 0.1047198333 * 1.4 //cannot be fixed number always
                    left_quad1.runAction(SKAction.rotateByAngle(CGFloat(-M_PI_4/6), duration: 0.0))
                }
                //print("Angle :%f",left_quad1.zRotation);
                left_touchPoint = touchLocation;
                /*if( left_quad1.zRotation < 0 && left_quad1.zRotation >= CGFloat(-M_PI_2) )
                {
                    //blue
                    print("blue")
                }
                else if( left_quad1.zRotation < CGFloat(-M_PI_2) && left_quad1.zRotation >= CGFloat(-M_PI) )
                {
                    //red
                    print("red")
                }
                else if( left_quad1.zRotation > 0 && left_quad1.zRotation <= CGFloat(M_PI_2) )
                {
                    //yellow
                    print("yellow")
                }
                else if( left_quad1.zRotation > CGFloat(M_PI_2) && left_quad1.zRotation <= CGFloat(M_PI) )
                {
                    //green
                    print("green")
                }*/
            }
            else if(touchLocation.x > size.width/2) {
                //Rigth
                //print("Right Moved");
                if(right_touchPoint.y < touchLocation.y)
                {
                    //print("Right Up");
                    //right up
                    right_quad1.runAction(SKAction.rotateByAngle(CGFloat(-M_PI_4/6), duration: 0.0))
                    //right_quad1.zRotation -= 0.1047198333 * 1.4  //cannot be fixed number always
                    
                }
                else {
                    //print("Right Down");
                    //right down
                    right_quad1.runAction(SKAction.rotateByAngle(CGFloat(M_PI_4/6), duration: 0.0))
                    //right_quad1.zRotation += 0.1047198333 * 1.4 //cannot be fixed number always
                }
                //print("Right Rotation Angle :%f",right_quad1.zRotation);
                right_touchPoint = touchLocation;
                /*if( right_quad1.zRotation < 0 && right_quad1.zRotation >= CGFloat(-M_PI_2) )
                {
                    //blue
                    print("green")
                }
                else if( right_quad1.zRotation < CGFloat(-M_PI_2) && right_quad1.zRotation >= CGFloat(-M_PI) )
                {
                    //red
                    print("yellow")
                }
                else if( right_quad1.zRotation > 0 && right_quad1.zRotation <= CGFloat(M_PI_2) )
                {
                    //yellow
                    print("red")
                }
                else if( right_quad1.zRotation > CGFloat(M_PI_2) && right_quad1.zRotation <= CGFloat(M_PI) )
                {
                    //green
                    print("blue")
                }*/
            }
        }

    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if (tutorial_show)
        {
            return;
        }
        
        if(gameOver)
        {
            return;
        }
        // Stop node from moving to touch
        if let touch = touches.first {
            let touchLocation = touch.locationInNode(self)
            if(touchLocation.x < size.width/2)
            {
                //Left
                //print("Left Ended");
                left_touch = false;
                left_touchPoint = CGPointZero;
            }
            else if(touchLocation.x > size.width/2) {
                //Rigth
                //print("Right Ended");
                right_touch = false;
                right_touchPoint = CGPointZero;
            }
        }
    }

    func didBeginContact(contact: SKPhysicsContact){
        if(gameOver)
        {
            return;
        }
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask > contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
            
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        if ( ((firstBody.categoryBitMask & obstacles_bitmask != 0) &&
              (secondBody.categoryBitMask & left_bitmask != 0)) || (
              (firstBody.categoryBitMask & obstacles_bitmask != 0) &&
              (secondBody.categoryBitMask & right_bitmask != 0)) )
        {
            var i = 0
            for obj in  obstacleArray {
                if( obj.spriteNode == firstBody.node)
                {
                    var color = 1;
                    if( secondBody.node!.zRotation < 0 && secondBody.node!.zRotation >= CGFloat(-M_PI_2) )
                    {
                        color = ( obj.isLeft ) ? 2 : 4 ;
                    }
                    else if( secondBody.node!.zRotation < CGFloat(-M_PI_2) && secondBody.node!.zRotation >= CGFloat(-M_PI) )
                    {
                        color = ( obj.isLeft ) ? 1 : 3 ;
                    }
                    else if( secondBody.node!.zRotation > 0 && secondBody.node!.zRotation <= CGFloat(M_PI_2) )
                    {
                        color = ( obj.isLeft ) ? 3 : 1 ;
                    }
                    else if( secondBody.node!.zRotation > CGFloat(M_PI_2) && secondBody.node!.zRotation <= CGFloat(M_PI) )
                    {
                        color = ( obj.isLeft ) ? 4 : 2 ;
                    }
                    
                    let colorStr = obj.spriteNode.name;
                    if(( color == 1 && colorStr!.containsString("red")) || (color == 2 && colorStr!.containsString("blue")) || (color == 3 && colorStr!.containsString("yellow")) || (color == 4 && colorStr!.containsString("green"))) {
                        score += 1;
                        runAction(scored)
                    }
                    else
                    {
                        runAction(punch)
                        let delay = 0.5 * Double(NSEC_PER_SEC)
                        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                        gameOver = true;
                        dispatch_after(time, dispatch_get_main_queue()) {
                            self.defaults.setValue(String(NSDate().timeIntervalSince1970*1000), forKey: "updatedtime")
                            self.defaults.setValue(String(self.score), forKey: "points")
                            self.defaults.synchronize();
                            self.viewController.gamePlayed();
                            let transition = SKTransition.revealWithDirection(.Down, duration: 1.0)
                            self.view?.presentScene(self.oldScene!,transition: transition);
                        }
                        
                    }
                    scoreLabel.text = "Score : " + String(score);
                    obj.spriteNode.alpha = 0.75;
                    obj.spriteNode.alpha = 0.5;
                    obj.spriteNode.alpha = 0.25;
                    if(!gameOver) {
                        let delay = 0.5 * Double(NSEC_PER_SEC)
                        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                        dispatch_after(time, dispatch_get_main_queue()) {
                            obj.spriteNode.removeFromParent();
                        }
                    }
                    break;
                }
                else{
                    i += 1;
                }
            }
        }
    }
}
