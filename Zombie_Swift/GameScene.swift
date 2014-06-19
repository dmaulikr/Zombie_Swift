//
//  GameScene.swift
//  Zombie_Swift
//
//  Created by Hazel Jiang on 6/18/14.
//  Copyright (c) 2014 Hazel Jiang. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    let ZOMBIE_MOVE_POINTS_PER_SEC = 120.0
    var _zombie = SKSpriteNode()
    var _lastUpdatetime = NSTimeInterval()
    var _dt = NSTimeInterval()
    var _velocity = CGPoint()
    var _lastTouchLocation = CGPoint()
    

    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        
        // Set background
        self.backgroundColor = SKColor.whiteColor()
        var bg: SKSpriteNode = SKSpriteNode(imageNamed:"background")
        bg.position = CGPointMake(self.size.width/2, self.size.height/2)
        bg.setScale(2.0)
        self.addChild(bg)
        _zombie = SKSpriteNode(imageNamed:"zombie1.png")
        _zombie.position = CGPointMake(300.0, 300.0)
        _zombie.setScale(2.0)
        self.addChild(_zombie)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            self.moveZombieToward(location)
        }
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
        if CGPointLength(distance) <= ZOMBIE_MOVE_POINTS_PER_SEC * _dt
        {
            _zombie.position = _lastTouchLocation
            _velocity = CGPointZero
        
        }
        else
        {
            self.moveSprite(_zombie, velocity:_velocity)
            self.boundsCheckPlayer()
            self.rotateZombie(_zombie, direction: _velocity)
        }
    }
    func moveSprite (sprite : SKSpriteNode, velocity :CGPoint)
    {
        var amountToMove = CGPointMultiplyScalar(velocity, b: _dt)
        sprite.position = CGPointAdd(sprite.position, b: amountToMove)
    }
    func moveZombieToward (location : CGPoint)
    {
        _lastTouchLocation = location
        var offset = CGPointSubstract(location, b: _zombie.position)
        var direction = CGPointNormalize(offset)
        _velocity = CGPointMultiplyScalar(direction, b: ZOMBIE_MOVE_POINTS_PER_SEC)
    }
    func rotateZombie(sprite: SKSpriteNode, direction: CGPoint)
    {
        sprite.zRotation = atan2(direction.y, direction.x)
    
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
    
    
    //math box - helper methods
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
}
