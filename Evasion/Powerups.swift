//
//  Powerups.swift
//  Evasion
//
//  Created by Matt Finch and Max Bennett on 2020-04-22.
//  Copyright © 2020 Matt Finch and Max Bennett. All rights reserved.
//

import Foundation
import SpriteKit
import simd

class PowerUp {
    var coordinates: Vector
    var scene: GameScene
    var status: Bool
    var shapeNode: SKSpriteNode?
    let size: CGFloat = 20
    var type: String?
    init(initialCoordinates: Vector, gScene: GameScene) {
        coordinates = initialCoordinates
        scene = gScene
        status = true
    }
//    func move(playerPosition: Vector) {}
//    var getPosition: Vector {
//        get { coordinates }
//    }
//    var checkStatus: Bool {
//        get { status }
//    }
} //End Entity

//class Freeze: Powerup {
//    init(pos: Vector, grid: (Int, Int), dir: Vector, gScene: GameScene) {
//
//        super.init(initialCoordinates: pos, grid: grid, gScene: gScene)
//    }
//    override func move(playerPosition: Vector) {
//        coordinates += direction
//    }
//    class func spawn(grid: (Int, Int), enemies: inout [Enemy], gScene: GameScene) {}
//} //End Enemy
//
//class Shield: Powerup
