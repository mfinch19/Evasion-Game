//
//  Entities.swift
//  Game_1
//
//  Created by Matt Finch and Max Bennett on 2020-04-22.
//  Copyright © 2020 Matt Finch and Max Bennett. All rights reserved.
//

import Foundation
import SpriteKit
import simd


class Entity {
    //var colour: SKColor = SKColor.red
    var coordinates: Vector
    var arena: (Int, Int)
    var scene: GameScene
    var status: Bool
    //var shapeNode: SKShapeNode?
    var shapeNode: SKSpriteNode?
    init(initialCoordinates: Vector, grid: (Int, Int), gScene: GameScene) {
        coordinates = initialCoordinates
        arena = grid
        scene = gScene
        status = true
    }
    func move(playerPosition: Vector) {}
    var getPosition: Vector {
        get { coordinates }
    }
    var checkStatus: Bool {
        get { status }
    }
} //End Entity

class Enemy: Entity {
    let size: CGFloat = 20
    //var iconDict: [String:String] = [:]
    var direction: Vector
    init(pos: Vector, grid: (Int, Int), dir: Vector, gScene: GameScene) {
        self.direction = dir
        super.init(initialCoordinates: pos, grid: grid, gScene: gScene)
    }
    override func move(playerPosition: Vector) {
        coordinates += direction
    }
    class func spawn(grid: (Int, Int), enemies: inout [Enemy], gScene: GameScene) {}
} //End Enemy

class Player: Entity {
    let size: CGFloat = 25
//    var powerUp: GameManager.PowerUp = GameManager.PowerUp.none
    func move(direction: Vector) {
        let xPos = getPosition.X
        let yPos = getPosition.Y
        let xDir = direction.X
        let yDir = direction.Y
        if !((xPos == 0 && xDir == -1) ||
             (xPos == arena.1  - 1 && xDir == 1) ||
             (yPos == 0 && yDir == -1) ||
             (yPos == arena.0 - 1 && yDir == 1)) {
            coordinates += direction
        }
    }
} //End Player

class Rook: Enemy {
    let iconDict = ["(0, 1)" : "down.png",
                    "(0, -1)" : "up.png",
                    "(1, 0)" : "right.png",
                    "(-1, 0)" : "left.png"]
    override init(pos: Vector, grid: (Int, Int), dir: Vector, gScene: GameScene) {
        super.init(pos: pos, grid: grid, dir: dir, gScene: gScene)
        //self.colour = SKColor.green
        //let node = SKShapeNode(circleOfRadius: size)
        let node = SKSpriteNode(imageNamed: iconDict[dir.description]!)
        node.size = CGSize(width: 30, height: 30)
        let xyPos = scene.pointToCoordinate(pos, 550, 1100)
        node.position = CGPoint(x: xyPos.0, y: xyPos.1)
        node.zPosition = 4
//        node.strokeColor = SKColor.systemGray
//        node.fillColor = colour
        shapeNode = node
        scene.background.addChild(shapeNode!)
    }
//    func getIconPath(dir: Vector) -> String {
//        return iconDict[dir.description]!
//    }
    override class func spawn(grid: (Int, Int), enemies: inout [Enemy], gScene: GameScene) {
        let colNum: Int = Int.random(in: 0..<(grid.1))
        let rowNum: Int = Int.random(in: 0..<(grid.0))
        var position: Vector
        var direction: Vector
        var rook: Rook
        let anchor = Int.random(in: 0..<4)
        switch anchor {
        case 0:
            position = Vector(colNum, -1)
            direction = Vector.down
        case 1:
            position = Vector(grid.1, rowNum)
            direction = Vector.left
        case 2:
            position = Vector(colNum, grid.0)
            direction = Vector.up
        default:
            position = Vector(-1, rowNum)
            direction = Vector.right
        }
        rook = Rook(pos: position, grid: grid, dir: direction, gScene: gScene)
        enemies.append(rook)
    }
    
    override func move(playerPosition: Vector) {
        super.move(playerPosition: playerPosition)
        if (getPosition.X < 0 || getPosition.X >= arena.1 ||
            getPosition.Y < 0 || getPosition.Y >= arena.0 ) {
            status = false
        }
    }
} //End Simple Enemy

class Bishop: Enemy {
    let iconDict = ["(1, 1)" : "rightDown.png",
                    "(-1, -1)" : "leftUp.png",
                    "(1, -1)" : "rightUp.png",
                    "(-1, 1)" : "leftDown.png"]
    let maxRebounds: Int = 2
    var countRebounds: Int = 0
    override init(pos: Vector, grid: (Int, Int), dir: Vector, gScene: GameScene) {
        super.init(pos: pos, grid: grid, dir: dir, gScene: gScene)
        //self.colour = SKColor.purple
        let node = SKSpriteNode(imageNamed: iconDict[dir.description]!)
        node.size = CGSize(width: 30, height: 30)
        let xyPos = scene.pointToCoordinate(pos, 550, 1100)
        node.position = CGPoint(x: xyPos.0, y: xyPos.1)
        node.zPosition = 4
        shapeNode = node
        scene.background.addChild(shapeNode!)
    }
    override class func spawn(grid: (Int, Int), enemies: inout [Enemy], gScene: GameScene) {
        let colNum: Int = Int.random(in: 0..<(grid.1))
        let rowNum: Int = Int.random(in: 0..<(grid.0))
        var position: Vector
        var direction: Vector
        var bishop: Bishop
        let anchor = Int.random(in: 0..<4)
        switch anchor {
        case 0:
            position = Vector(colNum, -1)
            if Bool.random() {
                direction = Vector.leftDown
            } else {
                direction = Vector.rightDown
            }
        case 1:
            position = Vector(grid.1, rowNum)
            if Bool.random() {
                direction = Vector.leftDown
            } else {
                direction = Vector.leftUp
            }
        case 2:
            position = Vector(colNum, grid.0)
            if Bool.random() {
                direction = Vector.leftUp
            } else {
                direction = Vector.rightUp
            }
        default:
            position = Vector(-1, rowNum)
            if Bool.random() {
                direction = Vector.rightDown
            } else {
                direction = Vector.rightUp
            }
        }
        bishop = Bishop(pos: position, grid: grid, dir: direction, gScene: gScene)
        enemies.append(bishop)
    }
    
    override func move(playerPosition: Vector) {
        super.move(playerPosition: playerPosition)
        if ((coordinates.X < 0 || coordinates.X >= arena.1) ||
            (coordinates.Y < 0 || coordinates.Y >= arena.0)) {
            if countRebounds < maxRebounds {
                rebound()
            } else {
                status = false
            }
        }
    }
    
    func rebound() {
        if !(coordinates.X < 0 || coordinates.X >= arena.1) {
            if (coordinates.Y < 0) {
                coordinates += Vector(0, 2)
                direction += Vector(0, 2)
            } else {
                coordinates += Vector(0, -2)
                direction += Vector(0, -2)
            }
        } else if !(coordinates.Y < 0 || coordinates.Y >= arena.0) {
            if (coordinates.X < 0) {
                coordinates += Vector(2, 0)
                direction += Vector(2, 0)
            } else {
                coordinates += Vector(-2, 0)
                direction += Vector(-2, 0)
            }
        } else {
            if (coordinates.X < 0) {
                if (coordinates.Y < 0) {
                    coordinates += Vector(2, 2)
                    direction += Vector(2, 2)
                } else {
                    coordinates += Vector(2, -2)
                    direction += Vector(2, -2)
                }
            } else {
                if (coordinates.Y < 0) {
                    coordinates += Vector(-2, 2)
                    direction += Vector(-2, 2)
                } else {
                    coordinates += Vector(-2, -2)
                    direction += Vector(-2, -2)
                }
            }
        }
        shapeNode!.removeFromParent()
        let node = SKSpriteNode(imageNamed: iconDict[direction.description]!)
        node.size = CGSize(width: 30, height: 30)
        let xyPos = scene.pointToCoordinate(coordinates, 550, 1100)
        node.position = CGPoint(x: xyPos.0, y: xyPos.1)
        shapeNode = node
        scene.background.addChild(shapeNode!)
        countRebounds += 1
    }
    
} //End Complex Enemy


class Hunter: Enemy {
    var lifetime: Int = 10
    var label: SKLabelNode = SKLabelNode(fontNamed: "Avenir")
    override init(pos: Vector, grid: (Int, Int), dir: Vector, gScene: GameScene) {
        super.init(pos: pos, grid: grid, dir: dir, gScene: gScene)
        //self.colour = SKColor.orange
//        let node = SKShapeNode(circleOfRadius: size)
        let xyPos = scene.pointToCoordinate(pos, 550, 1100)
        let node = SKSpriteNode(imageNamed: "lifetime10.png")
        node.size = CGSize(width: 30, height: 30)
        node.position = CGPoint(x: xyPos.0, y: xyPos.1)
        node.zPosition = 4
        shapeNode = node
        print("spawning hunter")
        scene.background.addChild(shapeNode!)
    }
    
    class func spawn(grid: (Int, Int), enemies: inout [Enemy], playerPosition: Vector, gScene: GameScene) {
        let colNum: Int = Int.random(in: 0..<(grid.1))
        let rowNum: Int = Int.random(in: 0..<(grid.0))
        var position: Vector
        var direction: Vector
        var h: Hunter
        let anchor = Int.random(in: 0..<4)
        switch anchor {
        case 0:
            position = Vector(colNum, -1)
        case 1:
            position = Vector(grid.1, rowNum)
        case 2:
            position = Vector(colNum, grid.0)
        default:
            position = Vector(-1, rowNum)
        }
        let vectorToPlayer = playerPosition - position
        direction = Vector(Int(sign(Float(vectorToPlayer.X))),Int(sign(Float(vectorToPlayer.Y))))
        h = Hunter(pos: position, grid: grid, dir: direction, gScene: gScene)
        enemies.append(h)
    }
    
    override func move(playerPosition: Vector) {
        lifetime -= 1
        shapeNode!.removeFromParent()
        let node = SKSpriteNode(imageNamed: "lifetime\(max(lifetime,1)).png")
        node.size = CGSize(width: 30, height: 30)
        let xyPos = scene.pointToCoordinate(coordinates, 550, 1100)
        node.position = CGPoint(x: xyPos.0, y: xyPos.1)
        shapeNode = node
        scene.background.addChild(shapeNode!)
        let vectorToPlayer = playerPosition - coordinates
        direction = Vector(Int(sign(Float(vectorToPlayer.X))),Int(sign(Float(vectorToPlayer.Y))))
        super.move(playerPosition: playerPosition)
        if (getPosition.X < 0 || getPosition.X >= arena.1 ||
            getPosition.Y < 0 || getPosition.Y >= arena.0 ) {
            status = false
        }
        if lifetime <= 0 {
            status = false
        }
    }
} //End Hunter class

