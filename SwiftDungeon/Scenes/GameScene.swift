//
//  GameScene.swift
//  SwiftDungeon
//
//  Created by Puntillo Andrew J. on 2/28/18.
//  Copyright © 2018 Puntillo Andrew J. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var gameManager: GameManager?
    
    var stickActive:Bool = false
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        backgroundColor = #colorLiteral(red: 0.4305377305, green: 0.4890032411, blue: 0.7309067845, alpha: 1)
        gameManager = GameManager()
        gameManager?.scene = self
        gameManager?.startGame(size: size)
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        gameManager?.update(currentTime)
        
        if (gameManager?.map.endOfLevel)! {
            spawnParticleEffect(_position: (gameManager?.player.position)!)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            gameManager?.joystick?.onBegin(loc: location)
            
            if (gameManager?.map.endOfLevel)! {
                gameManager?.resetLevel()
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            gameManager?.joystick?.onMoved(loc: location)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        gameManager?.joystick?.onEnded()
    }
    
    func spawnParticleEffect(_position: CGPoint){
        let particle = SKEmitterNode(fileNamed: "Explosion.sks")
        particle?.name = "BOOM"
        particle?.position = _position
        particle?.targetNode = self
        gameManager?.scene?.addChild(particle!)
    }
    
}

