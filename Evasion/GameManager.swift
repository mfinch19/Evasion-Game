//
//  GameManager.swift
//  Evasion
//
//  Created by Matt Finch and Max Bennett on 2020-04-22.
//  Copyright © 2020 Matt Finch and Max Bennett. All rights reserved.
//

import SpriteKit

class GameManager {
    var scene: GameScene!
    var running: Bool = false
    var score: Int = 0
    var numRows: Int
    var numCols: Int
    var player: Player?
    var enemies: [Enemy] = []
    var maxEnemies: Int = 5
    let endMaxEnemies: Int = 15 //change back
    var nextTime: Double?
    var dt: Double = 0.01
    let dtEnd: Double = 0.001
    var timer: Double = 5.0 //change back
    var probs: [Double] = [1.0, 0.0, 0.0] //change back to 1, 0, 0
    let halfProbs: [Double] = [0.4, 0.6, 0] //change back to [0.4, 0.6, 0]
    let endProbs: [Double] = [0.3, 0.3, 0.4]
    
    init(scene: GameScene) {
        self.scene = scene
        numRows = scene.numRows
        numCols = scene.numCols
    } // end constructor
    
    func initGame() {
        let yInit = Int.random(in: 2..<(numRows - 2))
        let xInit = Int.random(in: 2..<(numCols - 2))
        player = Player(initialCoordinates: Vector(xInit, yInit), grid: (numRows, numCols), gScene: scene)
        let playerNode = SKSpriteNode(imageNamed: "player.png")
        playerNode.size = CGSize(width: 40, height: 40)
        //let playerNode = SKShapeNode(circleOfRadius: CGFloat(player!.size))
        let xyPos = scene.pointToCoordinate(player!.getPosition, 550, 1100)
        playerNode.position = CGPoint(x: xyPos.0, y: xyPos.1)
        playerNode.zPosition = 3
        //playerNode.strokeColor = SKColor.systemGray
        //playerNode.fillColor = player!.colour
        player!.shapeNode = playerNode
        
        scene.background.addChild(playerNode)
        score = 0
        timer = 5.0
        probs = [1.0, 0.0, 0.0]
        maxEnemies = 5
        render()
        running = true
    } // end initGame
    
    func swipe(coordinate: Vector) {
        if running {
            updatePositions(direction: coordinate)
            render()
            if collisionCheck(direction: coordinate) {
                endGame()
            } else {
                score += 1
                if timer < 5.0 {
                    timer += min(1.0, 5.0 - timer)
                }
                if score % 20 == 0 {
                    if score < 100 {
                        for i in 0...2 {
                            probs[i] = (probs[i] + halfProbs[i]) / 2
                        }
                    } else {
                        for i in 0...2 {
                            probs[i] = (probs[i] + endProbs[i]) / 2
                        }
//                        dt = (dt + dtEnd) / 2
                        if Bool.random() {
                            spawnPowerUp()
                        }
                    }
                    maxEnemies = (maxEnemies + endMaxEnemies) / 2
//                    print(probs.reduce(0, +)) //REMOVE
//                    print(maxEnemies) //REMOVE
                }
            }
            render()
            enemyCollisionCheck()
        }
    } // end swipe
    
    func spawnPowerUp() {
        let rand = Double.random(in: 0..<1)
        var powerUp: PowerUp
        
        if rand < 0.3 {
            
            
            
            
        }
    }
    
    func animateNodes(_ pos: [Vector], _ nodes: [SKNode]) {
        assert (pos.count == nodes.count)
        for (p, node) in zip(pos, nodes) {
            let point = scene.pointToCoordinate(p, 550, 1100)
            node.run(.sequence([
                .repeatForever(.sequence([
                    .group([
                        .move(to: CGPoint(x: point.0, y: point.1), duration: 0.1)
                    ]),
                ]))
            ]))
        }
    }
    
    func render() {
        let newPositions = enemies.map({ $0.getPosition }) + [player!.getPosition]
        let nodes = enemies.map({ $0.shapeNode! }) + [player!.shapeNode!]
        animateNodes(newPositions, nodes)
        clearEnemies()
        scene.currentScore.text = "Score: \(score)"
        //scene.timerLabel.text = "\(round(timer * 100) / 100.0)"
    } // end renderChange
    
    func clearEnemies() {
        for e in (enemies.filter { !$0.status }) {
            e.shapeNode!.run(.sequence([
                    .repeatForever(.sequence([
                        .group([
                            .scale(to: 0, duration: 0.9)
                            
                        ]),
                    ]))
            ]))
            //node.removeFromParent()
        }
        
        for e in (enemies.filter { !$0.status }) {
            
            e.shapeNode!.removeFromParent()
        }
        enemies = enemies.filter { $0.status }
    }
    
    private func updatePositions(direction: Vector) {
        print(probs) //DEBUGGING
        if enemies.count < maxEnemies {
            let rand = Double.random(in: 0..<1)
            if rand < probs[2] {
                Hunter.spawn(grid: (numRows, numCols), enemies: &enemies, playerPosition: player!.getPosition, gScene: scene)
            } else if rand < probs[2] + probs[1] {
                Bishop.spawn(grid: (numRows, numCols), enemies: &enemies, gScene: scene)
            } else {
                Rook.spawn(grid: (numRows, numCols), enemies: &enemies, gScene: scene)
            }
        }
        if enemies.count != 0 {
            for e in enemies {
                e.move(playerPosition: player!.getPosition)
            }
            //enemies = enemies.filter { $0.status }
        }
        if player != nil {
            player!.move(direction: direction)
        }
        //renderChange()
    } //end updatePlayerPosition
    
    func timeUpdate(time: Double) {
        if nextTime == nil {
            nextTime = time + dt
        } else {
            if time >= nextTime! && running {
                if timer <= 0 {
                    endGame()
                } else {
                    timer -= dt
                }
                nextTime = time + dt
                //scene.timerLabel.text = "\(round(timer * 100) / 100.0)"
                scene.timerBar.size = CGSize(width: scene.timerWidth * 550 * timer / 5, height: 20) //UNHARDCODE WIDTH!!!
            }
        }
    }
    
    func collisionCheck(direction: Vector) -> Bool {
        let currentPosition = player!.getPosition
        let prevPosition = currentPosition - direction
        for e in enemies {
            let currentEPosition = e.getPosition
            let prevEPosition = currentEPosition - e.direction
            if e.getPosition == currentPosition {
                print("\nCollision (same pos): ")
                print(player!.getPosition)
                print(e.getPosition)
                return true
            } else if (currentPosition == prevEPosition && currentEPosition == prevPosition) {
                print("\nCollision (swapped pos): ")
                print(player!.getPosition)
                print(e.getPosition)
                return true
            }
        }
        return false
    }
    
    func enemyCollisionCheck() {
        var toRemove : [Int] = []
        var e1 : Enemy
        var e2 : Enemy
        for i in 0..<enemies.count {//0..<enemies.count {
            for j in 0..<enemies.count {
                e1 = enemies[i]
                e2 = enemies[j]
                if e1 === e2 {
                    continue
                } else if e1.getPosition == e2.getPosition || (e1.getPosition - e1.direction == e2.getPosition && e2.getPosition - e2.direction == e1.getPosition) {
                    if !toRemove.contains(i) {
                        toRemove.append(i)
                    }
                }
            }
        }
        
        if !toRemove.isEmpty {
            
//            print("\n")
//            print("PRE:")
//            for e in enemies {
//                print(e.coordinates)
//            }
//            print("Enemy count: " + String(enemies.count))
//            print("\n")
//            print("Collision count: " + String(toRemove.count))
            
            for k in toRemove {
                enemies[k].shapeNode!.run(.sequence([
                    .repeatForever(.sequence([
                        .group([
                            .scale(to: 0, duration: 0.2)
                        ]),
                    ]))
                ]))
                

            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                for m in toRemove.reversed() {
                    print(m) //DEBUG
                    self.enemies[m].shapeNode!.removeFromParent() //INDEX OUT OF RANGE...STILL!!
                    self.enemies.remove(at: m)
                }
                
                print("POST:")
                for e in self.enemies {
                    print(e.coordinates)
                }
                print("Enemy count: " + String(self.enemies.count))
            }
            

            
        }
        
        
        

    }
    
    func endGame() {
        running = false
        scoreCheck()
        //PUT A BIG FAT X RIGHT IN THE MIDDLE OF THE SCREEN
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            for e in self.enemies {
                e.shapeNode!.removeFromParent()
            }
            self.enemies = []
            self.player!.shapeNode!.removeFromParent()
            self.player = nil
            self.scene.resetMenu()
        }
    }
    
    func scoreCheck() {
        if score > UserDefaults.standard.integer(forKey: "bestScore") {
            UserDefaults.standard.set(score, forKey: "bestScore")
        }
        scene.topScore.text = "Best Score: \(UserDefaults.standard.integer(forKey: "bestScore"))"
    }
    
    func deleteAllShapeNodes(nodes: inout [SKShapeNode]) {
        for node in nodes {
            node.run(.sequence([
                    .repeatForever(.sequence([
                        .group([
                            .scale(to: 0, duration: 0.9)
                            
                        ]),
                    ]))
            ]))
            node.removeFromParent()
        }
        nodes.removeAll(keepingCapacity: false)
    }

}
