//
//  GameManager.swift
//  SwiftDungeon
//
//  Created by Toro Juan D. on 3/12/18.
//  Copyright © 2018 Toro Juan D. All rights reserved.
//

import Foundation
import GameKit

class GameManager {
    
    // Map
    private let map = Map(imageNamed: "SDP_Tilemap_Ground-Water")
    private var mapStartPosition = CGSize()
    
    // Entities
    let player = Player()
    var enemies:[Enemy] = []
    private var maxEnemies = 3
    private let enemyFactory = EnemyFactory()
    
    // Loading check
    var loading: Bool = false
    
    // UI
    var joystick: Joystick?
    var attackButton: AttackButton?
    
    // Scene
    weak var scene: GameScene?
    
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
        
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        //player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: player.size.width, height: player.size.height))
        player.physicsBody?.usesPreciseCollisionDetection = true;
        player.physicsBody?.isDynamic = true;
        player.physicsBody?.affectedByGravity = true;
        player.physicsBody?.allowsRotation = false;
        
        //Init the Joystick
        joystick = Joystick()
        joystick?.start(size: size)
        
        //Init the Attack Button
        attackButton = AttackButton()
        attackButton?.start(size: size)
        
        // Add children to scene
        populateLevel()
        
        // Populate level with enemies
        //populateEnemies()
    }

    func update(_ currentTime: TimeInterval) {
        
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
            if (map.position.x >= -1580) {
                map.position.x -= 10
            }
        }
        
        //Falling into the water
        if (player.position.y < 400) {
            player.isDead = true;
        }
        
        /*
        // Update Enemies and check for collisions
        var enemiesToBeDeleted: [Int] = []
        
        for enemy in (enemies) {
            if(!loading) {
                enemy.update(currentTime)
            }
            enemy.targetPosition = player.position
            
            let playerCollision = enemy.collision(items: [player]).first
            
            if let _ = playerCollision  {
                if player.isAttacking {
                    enemy.removeFromParent()
                    enemiesToBeDeleted.append(enemies.index(of: enemy)!)
                }
                else {
                    player.takeDamage()
                    print(player.health)
                }
            }
        }
        
        deleteEnemies(enemiesToBeDeleted)
        */
        
        // Check to reload level
        if (player.isDead || enemies.count == 0) {
            player.resetPlayer()
            reloadLevel()
        }
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
                self.populateLevel()
                self.populateEnemies()
                
            }, completion: nil)
        })
    }
    
    private func resetLevel() {
        scene?.removeAllChildren()
        enemies.removeAll()
        player.position = self.map.playerSpawn
        map.position = CGPoint(x: mapStartPosition.width + 1580, y: mapStartPosition.height / 2 + 50)
    }
    
    private func populateLevel() {
        scene?.addChild(map)
        scene?.addChild(player)
        scene?.addChild((joystick?.joystick)!)
        scene?.addChild((joystick?.joystickBase)!)
        scene?.addChild((attackButton)!)
    }
    
    private func populateEnemies() {
        for _ in 0..<maxEnemies {
            let randomIndex = Int(arc4random_uniform(UInt32(map.enemySpawns.count)))
            let eTemp = enemyFactory.createEnemy()
            eTemp.position = map.enemySpawns[randomIndex]
            eTemp.setScale(5)
            scene?.addChild(eTemp)
            enemies.append(eTemp)
        }
    }
    
    //Helper function to properly remove the enemies from the array
    private func deleteEnemies(_ enemyIndex: [Int]) {
        let reversedIndex = enemyIndex.reversed()
        
        for index in reversedIndex {
            enemies.remove(at: index)
        }
    }
    
}

