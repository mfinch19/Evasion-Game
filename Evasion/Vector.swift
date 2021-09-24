//
//  Coordinates.swift
//  Evasion
//
//  Created by Matt Finch and Max Bennett on 2020-04-22.
//  Copyright © 2020 Matt Finch and Max Bennett. All rights reserved.
//

import Foundation

struct Vector: CustomStringConvertible {
    
    var at: (Int, Int)
    
    init(_ x: Int, _ y: Int) {
        at = (x, y)
    }
    
    var X: Int {
        get { at.0 }
    }
    
    var Y: Int {
        get { at.1 }
    }
    
    public var description: String { return "(\(X), \(Y))" }
    
    public var swapped: Vector { return Vector(Y, X) }
    
    static let up: Vector = Vector(0, -1)
    static let down: Vector = Vector(0, 1)
    static let left: Vector = Vector(-1, 0)
    static let right: Vector = Vector(1, 0)
    static let leftUp: Vector = Vector(-1, -1)
    static let leftDown: Vector = Vector(-1, 1)
    static let rightUp: Vector = Vector(1, -1)
    static let rightDown: Vector = Vector(1, 1)
    static let none: Vector = Vector(0, 0)
    
    static func +(v1: Vector, v2: Vector) -> Vector {
        let sumX: Int = v1.X + v2.X
        let sumY: Int = v1.Y + v2.Y
        let sum: Vector = Vector(sumX, sumY)
        return sum
    }
    
    static func +=(v1: inout Vector, v2: Vector) {
        v1 = v1 + v2
    }
    
    static func ==(v1: Vector, v2: Vector) -> Bool {
        return (v1.X == v2.X && v1.Y == v2.Y)
    }

    static func *(a: Int, v: Vector) -> Vector {
        return Vector(a * v.X, a * v.Y)
    }
    
    static func *=(v: inout Vector, a: Int) {
        v = a * v
    }
    
    static func -(v1: Vector, v2: Vector) -> Vector {
        return v1 + -1 * v2
    }
} // End Coordinate
