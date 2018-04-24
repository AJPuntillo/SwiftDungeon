//
//  GameManager.swift
//  SwiftDungeon
//
//  Created by Puntillo Andrew J. on 3/12/18.
//  Copyright © 2018 Puntillo Andrew J. All rights reserved.
//

import Foundation
import GameKit

class GameManager {
    
    // Map
    let map = Map(imageNamed: "SDP_Tilemap_Ground-Water")
    private var mapStartPosition = CGSize()
    private var mapMovement:CGFloat = 7
    
    // Entities
    let player = Player()
    var enemies:[Enemy] = []
    private var maxEnemies = 3
    private let enemyFactory = EnemyFactory()
    
    // Loading check
    var loading: Bool = false
    
    // UI
    var joystick: Joystick?
    var timerLabel: SKLabelNode!
    var victoryLabel: SKLabelNode!
    var finalScoreLabel: SKLabelNode!
    
    // Scene
    weak var scene: GameScene?
    
    // Timer
    var deltaTime: TimeInterval = 0.0
    private var lastUpdateTime: TimeInterval?
    var timer:Double = 0.0
    var spawnInterval:Int = 3
    var timerCap:Int = 3
    
    var levelTimer:Double = 0.0
    var finalScore:Double = 0.0
    var firstLoop:Bool = true
    
    func startGame(size: CGSize) {
        mapStartPosition = size
        
        // Make Map
        map.zPosition = -1
        map.position = CGPoint(x: mapStartPosition.width + 1580, y: mapStartPosition.height / 2 + 50)
        map.setScale(2.5)
        map.physicsBody = SKPhysicsBody(texture: map.texture!, size: map.size)
        map.physicsBody?.isDynamic = false;
        
        // Make Player
        player.zPosition = 1
        player.position = map.playerSpawn
        player.setScale(5)
        
        //Init the Joystick
        joystick = Joystick()
        joystick?.start(size: size)
        
        // Add children to scene
        populateLevel()
        
        // Populate level with enemies
        populateEnemies()
    }

    func update(_ currentTime: TimeInterval) {
        guard let lastUpdateTime = lastUpdateTime else {
            self.lastUpdateTime = currentTime
            return
        }
        
        deltaTime = currentTime - lastUpdateTime
        
        self.lastUpdateTime = currentTime
        
        //Check Victory
        if (map.endOfLevel) {
            Victory()
            return
        }
        
        // Update Player
        player.update(currentTime)
        player.setDirection(dir: (joystick?.dirVector)!)
        
        //Jump
        if ((joystick?.dirVector.y)! > CGFloat(0.4)) {
            player.jump()
        }
        
        //Checking if the player is grounded
        if ((player.physicsBody?.allContactedBodies().count) != 0) {
            player.state = PlayerState.IDLE
        }
        else {
            player.state = PlayerState.JUMPING
        }
        
        //Limiting BG movement
        if (player.position.x >= (scene?.size.width)! - 400 && (joystick?.dirVector.x)! < CGFloat(0.0)) {
            map.moveForward(mapMovement)
            for enemy in (enemies) {
                enemy.shiftEnemy(mapMovement)
            }
        }
        
        //Falling into the water
        if (player.position.y < 400) {
            player.isDead = true;
        }
        
        
        // Update Enemies and check for collisions
        var enemiesToBeDeleted: [Int] = []
        
        for enemy in (enemies) {
            if(!loading) {
                enemy.update(currentTime)
            }
            
            let playerCollision = enemy.collision(items: [player]).first
            
            if let _ = playerCollision  {
                if (enemy.isAnimating) {
                    player.isDead = true
                }
            }
            
            if (enemy.isDead) {
                enemy.removeFromParent()
                enemiesToBeDeleted.append(enemies.index(of: enemy)!)
            }
        }
        
        deleteEnemies(enemiesToBeDeleted)
 
        
        // Check to reload level
        if (player.isDead) {
            player.resetPlayer()
            reloadLevel()
        }
        
        populateEnemies()
        
        levelTimer += deltaTime
        timerLabel.text = "TIME: \(Int(levelTimer))"
    }
    
    private func reloadLevel() {
        // Fade out
        UIView.animate(withDuration: 1.0, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.scene?.view?.alpha = 0.0
        }, completion: {
            (finished: Bool) -> Void in
            
            // Fade in
            UIView.animate(withDuration: 1.0, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.scene?.view?.alpha = 1.0
                
                // Set properties and add children when screen is faded
                self.resetLevel()

            }, completion: nil)
        })
    }
    
    public func resetLevel() {
        scene?.removeAllChildren()
        enemies.removeAll()
        player.position = self.map.playerSpawn
        map.position = CGPoint(x: mapStartPosition.width + 1580, y: mapStartPosition.height / 2 + 50)
        levelTimer = 0
        
        populateLevel()
        populateEnemies()
    }
    
    private func populateLevel() {
        scene?.addChild(map)
        scene?.addChild(player)
        scene?.addChild((joystick?.joystick)!)
        scene?.addChild((joystick?.joystickBase)!)
        
        timerLabel = SKLabelNode(fontNamed: "Arial")
        timerLabel.text = "\(Int(levelTimer))"
        timerLabel.position = CGPoint(x: 200, y: 1200)
        timerLabel.zPosition = 1000
        timerLabel.setScale(2)
        scene?.addChild(timerLabel)
    }
    
    private func populateEnemies() {
        if (timer > Double(timerCap)) {
            for _ in 0..<maxEnemies {
                
                let randomIndex = Int(arc4random_uniform(UInt32(map.enemySpawns.count)))
                let randomLifetime = Double(arc4random_uniform(3) + 1)
                let randomBounce = CGFloat(arc4random_uniform(100) + 1)
                let randomVelocity = (CGFloat)(CGFloat(arc4random_uniform(1000)) - 500)
                let eTemp = enemyFactory.createEnemy(randomLifetime, randomBounce, randomVelocity)
                eTemp.position = map.enemySpawns[randomIndex]
                eTemp.setScale(5)
                scene?.addChild(eTemp)
                enemies.append(eTemp)
            }
            timer = 0
            let randomMaxEnemies = Int(arc4random_uniform(4) + 1)
            maxEnemies = randomMaxEnemies
            let randomSpawnInterval = Int(arc4random_uniform(2))
            spawnInterval = randomSpawnInterval
        }
        timer += deltaTime
    }
    
    //Helper function to properly remove the enemies from the array
    private func deleteEnemies(_ enemyIndex: [Int]) {
        let reversedIndex = enemyIndex.reversed()
        
        for index in reversedIndex {
            enemies.remove(at: index)
        }
    }
    
    func Victory() {
        if (firstLoop) {
            victoryLabel = SKLabelNode(fontNamed: "Arial")
            victoryLabel.text = "YOU WIN"
            victoryLabel.position = CGPoint(x: (scene?.size.width)! / 2, y: (scene?.size.height)! / 2)
            victoryLabel.zPosition = 1000
            victoryLabel.setScale(4)
            scene?.addChild(victoryLabel)
            
            finalScore = levelTimer
            
            finalScoreLabel = SKLabelNode(fontNamed: "Arial")
            finalScoreLabel.text = "FINAL TIME: \(Int(finalScore))"
            finalScoreLabel.position = CGPoint(x: (scene?.size.width)! / 2, y: ((scene?.size.height)! / 2) - 100)
            finalScoreLabel.zPosition = 1000
            finalScoreLabel.setScale(2)
            scene?.addChild(finalScoreLabel)
            
            timerLabel.isHidden = true
        }
    }
    
}

