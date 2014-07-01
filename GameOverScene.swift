//
//  GameOverScene.swift
//  Zombie_Swift
//
//  Created by Hazel Jiang on 7/1/14.
//  Copyright (c) 2014 Hazel Jiang. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene
{

    init(size: CGSize, won:Bool)
    {
        super.init(size: size)
        var bg:SKSpriteNode
        if won
        {
            bg = SKSpriteNode(imageNamed:"YouWin.png")
            self.runAction(SKAction.sequence([SKAction.waitForDuration(0.1), SKAction.playSoundFileNamed("win.wav", waitForCompletion: false)]))
        }
        else
        {
            bg = SKSpriteNode(imageNamed:"YouLose.png")
            self.runAction(SKAction.sequence([SKAction.waitForDuration(0.1), SKAction.playSoundFileNamed("lose.wav", waitForCompletion: false)]))
        
        }
        bg.position = CGPointMake(self.size.width/2, self.size.height/2)
        bg.setScale(2.0)
        self.addChild(bg)
        
        
        let wait = SKAction.waitForDuration(3.0)
        let block = SKAction.runBlock(
            {
                let myScene = GameScene(size: self.size)
                let reveal = SKTransition.flipHorizontalWithDuration(0.5)
                self.view.presentScene(myScene, transition: reveal)
        })
        self.runAction(SKAction.sequence([wait, block]))
        
        
    
    }
    
    
}
