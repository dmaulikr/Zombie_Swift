//
//  GameScene.swift
//  Zombie_Swift
//
//  Created by Hazel Jiang on 6/18/14.
//  Copyright (c) 2014 Hazel Jiang. All rights reserved.
//

import SpriteKit
import AVFoundation


class GameScene: SKScene {
    
    let ZOMBIE_MOVE_POINTS_PER_SEC = 150.0
    let ARC4RANDOM_MAX = 0x100000000
    let CAT_MOVE_POINTS_PER_SEC = 120.0

    
    var _zombie = SKSpriteNode()
    var _lastUpdatetime = NSTimeInterval()
    var _dt = NSTimeInterval()
    var _velocity = CGPoint()
    var _lastTouchLocation = CGPoint()
    var _zombieAnimation = SKAction()
    var _ifZombieInvincible = Bool()
    var _lives = Int()
    var _gameOver = Bool()
    var _backgroundMusicPlayer = AVAudioPlayer()

    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        
        // Set background
        self.backgroundColor = SKColor.whiteColor()
        self.playBackgroundMusic("bgMusic.mp3")
        var bg: SKSpriteNode = SKSpriteNode(imageNamed:"background")
        bg.position = CGPointMake(self.size.width/2, self.size.height/2)
        bg.setScale(2.0)
        self.addChild(bg)
        
        _lives = 5
        _gameOver = false
        
        // Setup zombie sprite
        _zombie = SKSpriteNode(imageNamed:"zombie1.png")
        _zombie.position = CGPointMake(300.0, 300.0)
        _zombie.setScale(2.0)
        _zombie.zPosition = 100
        self.addChild(_zombie)
        initZombieAnimation()
        self.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(spawnEnemy), SKAction.waitForDuration(2.0)])))
        self.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(spawnCat), SKAction.waitForDuration(1.0)])))
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            self.moveZombieToward(location)
        }
    }
    
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
        let touch = touches.anyObject() as UITouch;
        var touchLocation = touch.locationInNode(self);
        self.moveZombieToward(touchLocation);
        
    }
    
    override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
        let touch = touches.anyObject() as UITouch;
        var touchLocation = touch.locationInNode(self);
        self.moveZombieToward(touchLocation);
        
    }
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if _lastUpdatetime != 0
        {
            _dt = currentTime - _lastUpdatetime
        }
        else
        {
            _dt = 0
        }
        _lastUpdatetime = currentTime
        var distance = CGPointSubstract(_lastTouchLocation, b: _zombie.position)
        if CGPointLength(distance) < ZOMBIE_MOVE_POINTS_PER_SEC * _dt
        {
            _zombie.position = _lastTouchLocation
            _velocity = CGPointZero
            stopZombieAnimation()
        
        }
        else
        {
            self.moveSprite(_zombie, velocity:_velocity)
            self.boundsCheckPlayer()
            self.rotateZombie(_zombie, direction: _velocity)
        }
        moveTrain()
        if _lives <= 0 && !_gameOver
        {
            _gameOver = true
            println("You Lose!")
            let gameOverScene: SKScene = GameOverScene(size: self.size, won: false)
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            self.view.presentScene(gameOverScene, transition: reveal)
        
        }
    }
    override func didEvaluateActions()
    {
        checkCollisions()
    }
    
    //Zombie Actions
    func moveSprite (sprite : SKSpriteNode, velocity :CGPoint)
    {
        var amountToMove = CGPointMultiplyScalar(velocity, b: _dt)
        sprite.position = CGPointAdd(sprite.position, b: amountToMove)
    }
    func moveZombieToward (location : CGPoint)
    {
        startZombieAnimation()
        _lastTouchLocation = location
        var offset = CGPointSubstract(location, b: _zombie.position)
        var direction = CGPointNormalize(offset)
        _velocity = CGPointMultiplyScalar(direction, b: ZOMBIE_MOVE_POINTS_PER_SEC)
    }
    func rotateZombie(sprite: SKSpriteNode, direction: CGPoint)
    {
        sprite.zRotation = atan2(direction.y, direction.x)
    
    }
    // MARK: - Zombie Animations
    func initZombieAnimation()
    {
        var textures: AnyObject[] = []
        for i in 1..4
        {
            var textureName = String(format:"zombie%d", i)
            var texture = SKTexture(imageNamed: textureName)
            textures.append(texture)
        }
        for var i = 4; i > 1; i--
        {
            var textureName = String(format:"zombie%d", i)
            var texture = SKTexture(imageNamed: textureName)
            textures.append(texture)
        }
        _zombieAnimation = SKAction.animateWithTextures(textures, timePerFrame: 0.1)
        _zombie.runAction(SKAction.repeatActionForever(_zombieAnimation))
    }
    
    func startZombieAnimation()
    {
        if !_zombie.actionForKey("animation")
        {
            _zombie.runAction(SKAction.repeatActionForever(_zombieAnimation), withKey:"animation")
        }
        
    }
    func stopZombieAnimation()
    {
        _zombie.removeActionForKey("animation")
    }
    
    //Enemy
    func spawnEnemy()
    {
        var enemy = SKSpriteNode(imageNamed:"enemy")
        enemy.name = "enemy"
        enemy.position = CGPointMake(self.size.width + enemy.size.width/2, ScalarRandomRange(enemy.size.height/2, max: self.size.height - enemy.size.height/2))
        enemy.setScale(1.5)
        self.addChild(enemy)
        var actionMove: SKAction = SKAction.moveToX(-enemy.size.width/2, duration: 2.0)
        var actionRemove : SKAction = SKAction.removeFromParent()
        enemy.runAction(SKAction.sequence([actionMove, actionRemove]))
        
    }
    
    func spawnCat()
    {
        let cat = SKSpriteNode(imageNamed:"cat")
        cat.name = "cat"
        cat.position = CGPointMake(ScalarRandomRange(0, max: self.size.width), ScalarRandomRange(0, max: self.size.height))
        cat.xScale = 0
        cat.yScale = 0
        self.addChild(cat)
        
        cat.zRotation = -M_PI / 16
        let appear = SKAction.scaleTo(1.5, duration: 0.5)
        var leftWiggle = SKAction.rotateByAngle(M_PI/8, duration: 0.5)
        var rightWiggle = leftWiggle.reversedAction()
        var fullWiggle:SKAction = SKAction.sequence([leftWiggle, rightWiggle])
        //let wiggleWait = SKAction.repeatAction(fullWiggle, count: 10)
        
        var scaleUp = SKAction.scaleBy(1.8, duration: 0.25)
        var scaleDown = scaleUp.reversedAction()
        var fullScale = SKAction.sequence([scaleUp, scaleDown, scaleUp, scaleDown])
        
        var group = SKAction.group([fullScale, fullWiggle])
        var groupWait = SKAction .repeatAction(group, count: 10)
        
        
        let disappear = SKAction.scaleTo(0.0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        cat.runAction(SKAction.sequence([appear, groupWait, disappear, removeFromParent]))
    
    }
    
    func boundsCheckPlayer()
    {
        var newPosition = _zombie.position
        var newVelocity = _velocity
        
        let bottomLeft = CGPointZero
        let topRight = CGPointMake(self.size.width, self.size.height)
        
        if newPosition.x <= bottomLeft.x
        {
            newPosition.x = bottomLeft.x
            newVelocity.x = -newVelocity.x
        }
        
        if newPosition.y <= bottomLeft.y
        {
            newPosition.y = bottomLeft.y
            newVelocity.y = -newVelocity.y
        }
        if newPosition.x >= topRight.x
        {
            newPosition.x = topRight.x
            newVelocity.x = -newVelocity.x
        }
        if newPosition.y >= topRight.y
        {
            newPosition.y = topRight.y
            newVelocity.y = -newVelocity.y
        }
        _zombie.position = newPosition
        _velocity = newVelocity
    
    }
    func checkCollisions()
    {
        if !_ifZombieInvincible
        {
        self.enumerateChildNodesWithName("cat", usingBlock:
            {
                node, stop in
                var cat: SKSpriteNode = node as SKSpriteNode
                if CGRectIntersectsRect(cat.frame, self._zombie.frame)
                {
                    //cat.removeFromParent()
                    cat.name = "train"
                    self.runAction(SKAction.playSoundFileNamed("hitCat.wav", waitForCompletion: false));
                    cat.removeAllActions()
                    cat.zRotation = 0
                    var actionTurnGreen = SKAction.colorizeWithColor(UIColor.greenColor(), colorBlendFactor:1.0, duration:0.2)
                    cat.runAction(actionTurnGreen)
                }
            })
        }
    
        self.enumerateChildNodesWithName("enemy", usingBlock:{ node, stop in
            var enemy = node as SKSpriteNode
            var smallerFrame = CGRectInset(enemy.frame, 20, 20);
            if(CGRectIntersectsRect(smallerFrame, self._zombie.frame)){
                self.runAction(SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: false));
                enemy.hidden = true
                enemy.name = ""
                self.loseCats()
                self._lives--
                println("Lives left: \(self._lives)")

                self._ifZombieInvincible = true
                let blinkTimes = 10
                let blinkDuration = 3.0
                var blinkAction = SKAction.customActionWithDuration(blinkDuration, actionBlock:
                {  node, elapsedTime in
                    var slice = CFloat(blinkDuration) / CFloat(blinkTimes)
                    var remainder = fmodf(CFloat(elapsedTime), CFloat(slice))
                    node.hidden = remainder > slice / 2
                })
                var sequence = SKAction.sequence([blinkAction,SKAction.runBlock(
                    {
                        () in
                        self._zombie.hidden = false
                        self._ifZombieInvincible = false
                    })])
                self._zombie.runAction(sequence)
                
            }
            })
    }
    
    
    func moveTrain()
    {
        var targetPosition = _zombie.position
        var trainCount = 0
        self.enumerateChildNodesWithName("train", usingBlock: {
            (node, stop) in
            trainCount += 1
            if !node.hasActions()
            {
                let actionDuration = 0.3
                var offset:CGPoint = self.CGPointSubstract(targetPosition, b: node.position)
                var direction:CGPoint = self.CGPointNormalize(offset)
                var amountToMovePerSec:CGPoint = self.CGPointMultiplyScalar(direction, b:self.CAT_MOVE_POINTS_PER_SEC)
                var amountToMove:CGPoint = self.CGPointMultiplyScalar(amountToMovePerSec, b: actionDuration)
                var moveAction:SKAction = SKAction.moveByX(amountToMove.x, y: amountToMove.y, duration: actionDuration)
                node.runAction(moveAction)
                targetPosition = node.position
            }
        })
        if trainCount >= 5 && !_gameOver
        {
            _gameOver = true
            println("You Win!")
            _backgroundMusicPlayer.stop()
            let gameOverScene: SKScene = GameOverScene(size: self.size, won: true)
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            self.view.presentScene(gameOverScene, transition: reveal)
        }
        
    }
    func loseCats()
    {
        var loseCount = 0
        self.enumerateChildNodesWithName("train", usingBlock:
            {
                (node: SKNode!, stop: CMutablePointer<ObjCBool>) in
                var randomSpot = node.position
                randomSpot.x += self.ScalarRandomRange(-100, max: 100)
                randomSpot.y += self.ScalarRandomRange(-100, max: 100)
                
                node.name = ""
                var group = SKAction.group([SKAction.rotateByAngle(M_PI * 4, duration: 1.0), SKAction.moveTo(randomSpot, duration: 1.0), SKAction.scaleTo(0, duration: 1.0)])
                node.runAction(SKAction.sequence([group, SKAction.removeFromParent()]))
            
                loseCount++
                if loseCount >= 2
                {
                    stop.withUnsafePointer { $0.memory = true }
                }
            })
       
    
    }
    func playBackgroundMusic(filename: NSString)
    {
        var error:NSErrorPointer?
        var backgroundMusicURL:NSURL = NSBundle.mainBundle().URLForResource(filename, withExtension: nil)
        _backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: backgroundMusicURL, error:error!)
        _backgroundMusicPlayer.numberOfLoops = -1
        _backgroundMusicPlayer.prepareToPlay()
        _backgroundMusicPlayer.play()
    }
    // MARK:  - helper methods
    func CGPointAdd (a:CGPoint, b:CGPoint) ->CGPoint
    {
        return CGPointMake(a.x + b.x, a.y + b.y)
    }
    func CGPointSubstract (a:CGPoint, b:CGPoint) ->CGPoint
    {
        return CGPointMake(a.x - b.x, a.y - b.y)
    }
    func CGPointMultiplyScalar (a:CGPoint, b:CGFloat) ->CGPoint
    {
        return CGPointMake(a.x * b, a.y * b)
    }
    func CGPointLength (a:CGPoint) ->CGFloat
    {
        return sqrt(a.x * a.x + a.y * a.y)
    }
    func CGPointNormalize (a: CGPoint) -> CGPoint{
        var length = CGPointLength(a)
        return CGPointMake(a.x / length,  a.y / length)
    }
    func CGPointToAngle (a:CGPoint) -> CGFloat{
        return atan2(a.y, a.x)
    }
    func ScalarSign( a: CGFloat) -> CGFloat
    {
        return a >= 0 ? 1 : -1
    }
    //returns the shortest angle between two angles
    func ScalarShortestAngleBetween(a: CGFloat, b: CGFloat) -> CGFloat{
        let differentce = b - a
        var angle = fmod(differentce, M_PI * 2)
        if angle >= M_PI
        {
            angle -= M_PI * 2
        }
        else
        {
            angle += M_PI * 2
        }
        return angle
    }
    func ScalarRandomRange (min:CGFloat, max:CGFloat) ->CGFloat{
        
     return (CGFloat)(floorf((CFloat(arc4random()) / CFloat(ARC4RANDOM_MAX)) * CFloat(max - min) + CFloat(min)))
    }
    
}
