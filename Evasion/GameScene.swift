//
//  GameScene.swift
//  Evasion
//
//  Created by Matt Finch and Max Bennett on 2020-04-22.
//  Copyright © 2020 Matt Finch and Max Bennett. All rights reserved.
//

import SpriteKit
import GameplayKit
import UIKit

class GameScene: SKScene {
    
    var logo: SKLabelNode!
    var topScore: SKLabelNode!
    var playButton: SKShapeNode!
    var playButtonBG: SKShapeNode!
    var game: GameManager!
    var currentScore: SKLabelNode!
//    var timerLabel: SKLabelNode!
    var background: SKShapeNode!
    var sceneGrid: [(node: SKShapeNode, x: Int, y: Int)] = []
    var timerBar: SKSpriteNode!
    let numRows = 20
    let numCols = 10
    let cellSize: CGFloat = 55
    let timerWidth = 0.9
    
    enum PowerUp {
        case none
        case freeze
        case shield
        case stealth
    }
    
    override func didMove(to view: SKView) {
         initializeMenu()
         game = GameManager(scene: self)
         initializeGameView()
         
         let swipeRight:UISwipeGestureRecognizer =
         UISwipeGestureRecognizer(target: self, action: #selector(swipeR))
         swipeRight.direction = .right
         view.addGestureRecognizer(swipeRight)
         
         let swipeLeft:UISwipeGestureRecognizer =
         UISwipeGestureRecognizer(target: self, action: #selector(swipeL))
         swipeLeft.direction = .left
         view.addGestureRecognizer(swipeLeft)
         
         let swipeUp:UISwipeGestureRecognizer =
         UISwipeGestureRecognizer(target: self, action: #selector(swipeU))
         swipeUp.direction = .up
         view.addGestureRecognizer(swipeUp)
         
         let swipeDown:UISwipeGestureRecognizer =
         UISwipeGestureRecognizer(target: self, action: #selector(swipeD))
         swipeDown.direction = .down
         view.addGestureRecognizer(swipeDown)
     } //end didMove
     
     @objc func swipeR() {
        game.swipe(coordinate: Vector.right)
     }
     @objc func swipeL() {
         game.swipe(coordinate: Vector.left)
     }
     @objc func swipeU() {
         game.swipe(coordinate: Vector.up)
     }
     @objc func swipeD() {
         game.swipe(coordinate: Vector.down)
     }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event:
        UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = self.nodes(at: location)
            for node in touchedNode {
                if node.name == "play_button_BG" {
                    start()
                }
            }
        }
    } //end touchesBegan
    
    
    
    //Perform necessary animations to start the game
    private func start() {
        print("Start")
        logo.run(SKAction.move(by: CGVector(dx:-50, dy: 600),duration: 0.5)) {
            self.logo.isHidden = true
        }
        playButton.run(SKAction.scale(to: 0, duration: 0.3)) {
            self.playButton.isHidden = true
        }
        playButtonBG.run(SKAction.scale(to: 0, duration: 0.3)) {
            self.playButtonBG.isHidden = true
        }
        let bottomCorner = CGPoint(x: 0, y: (frame.size.height / -2) + 20) //MAYBE?
        topScore.run(SKAction.move(to: bottomCorner, duration: 0.3)) {
            self.background.setScale(0)
            self.currentScore.setScale(0)
            //self.timerLabel.setScale(0)
            self.timerBar.setScale(0)
            self.background.isHidden = false
            self.currentScore.isHidden = false
            self.timerBar.isHidden = false
            //self.timerLabel.isHidden = false
            self.background.run(SKAction.scale(to: 1, duration: 0.3))
            self.currentScore.run(SKAction.scale(to: 1, duration: 0.3))
            //self.timerLabel.run(SKAction.scale(to: 1, duration: 0.3))
            self.timerBar.run(SKAction.scale(to: 1, duration: 0.3))
            self.game.initGame()
        }
        game.score = 0
    } //end startGame
    
    private func initializeMenu() {
        logo = SKLabelNode(fontNamed: "Avenir")
        logo.zPosition = 1
        logo.position = CGPoint(x: 0, y: (frame.size.height / 2) - 200)
        logo.fontSize = 60
        logo.text = "Evasion"
        logo.fontColor = SKColor.systemBlue
        self.addChild(logo)
        
        topScore = SKLabelNode(fontNamed: "Avenir")
        topScore.position = CGPoint(x: 0, y: logo.position.y - 50)
        topScore.zPosition = 1
        topScore.fontSize = 40
        topScore.text = "Best Score: \(UserDefaults.standard.integer(forKey: "bestScore"))"
        topScore.fontColor = SKColor.white
        self.addChild(topScore)
        
        playButtonBG = SKShapeNode(circleOfRadius: 100)
        playButtonBG.name = "play_button_BG"
        playButtonBG.zPosition = 1
        playButtonBG.position = CGPoint(x: 0, y: (frame.size.height / -2) + 200)
        playButtonBG.fillColor = SKColor.systemBlue
        playButtonBG.strokeColor = SKColor.black
        self.addChild(playButtonBG)
        
        playButton = SKShapeNode()
        playButton.name = "play_button"
        playButton.zPosition = 2
        playButton.position = CGPoint(x: 0, y: (frame.size.height / -2) + 200)
        playButton.fillColor = SKColor.cyan
        let topCorner = CGPoint(x: -40, y: 50)
        let bottomCorner = CGPoint(x: -40, y: -50)
        let middle = CGPoint(x: 60, y: 0)
        let path = CGMutablePath()
        path.addLine(to: topCorner)
        path.addLines(between: [topCorner, bottomCorner, middle])
        playButton.path = path
        self.addChild(playButton)
    } //end initializeMenu
    
    private func initializeGameView() {
        currentScore = SKLabelNode(fontNamed: "Avenir")
        currentScore.zPosition = 2
        currentScore.position = CGPoint(x: 0, y: (frame.size.height / -2) + 65)
        currentScore.fontSize = 40
        currentScore.text = "Score: 0"
        currentScore.fontColor = SKColor.white
        currentScore.isHidden = true
        self.addChild(currentScore)
        
//        timerLabel = SKLabelNode(fontNamed: "Avenir")
//        timerLabel.zPosition = 1
//        timerLabel.position = CGPoint(x: 0, y: (frame.size.height / 2) - 100)
//        timerLabel.fontSize = 40
//        timerLabel.text = "\(game.timer)"
//        timerLabel.fontColor = SKColor.white
//        timerLabel.isHidden = true
//        self.addChild(timerLabel)
        
        timerBar = SKSpriteNode(color: SKColor.white, size: CGSize(width: timerWidth * 550, height: 20))
        timerBar.zPosition = 1
        timerBar.position = CGPoint(x: 0, y: (frame.size.height / 2) - 100)
        timerBar.isHidden = true
        self.addChild(timerBar)
        
        let width = 550 //UNHARDCODE
        let height = 1100 //UNHARDCODE
        let rect = CGRect(x: -width / 2, y: -height / 2, width: width, height: height)
        background = SKShapeNode(rect: rect, cornerRadius: 0.02)
        background.fillColor = SKColor.systemTeal
        background.zPosition = 2
        background.isHidden = true
        self.addChild(background)
        createGameBoard(width: CGFloat(width), height: CGFloat(height))
    } //end initializeGameView
    
    func pointToCoordinate(_ point: (Int, Int), _ width: CGFloat, _ height: CGFloat) -> (CGFloat, CGFloat) {
        let x = CGFloat(point.0)
        let y = CGFloat(point.1)
        let xC = (cellSize * x) - (width / 2) + cellSize / 2
        let yC = -(cellSize * y) + (height / 2) - cellSize / 2
        return (xC, yC)
    }
    
    func pointToCoordinate(_ point: Vector, _ width: CGFloat, _ height: CGFloat) -> (CGFloat, CGFloat) {
        return pointToCoordinate(point.at, width, height)
    }
    
    private func createGameBoard(width: CGFloat, height: CGFloat) {
//        var x = CGFloat(width / -2) + (cellSize / 2)
//        var y = CGFloat(height / -2) + (cellSize / 2)
//        for i in 0...numRows - 1 {
//            for j in 0...numCols - 1 {
//                let cellNode = SKShapeNode(rectOf: CGSize(width: cellSize, height: cellSize))
//                cellNode.strokeColor = SKColor.systemTeal
//                cellNode.zPosition = 2
//                let xyPos = pointToCoordinate((j, i), width, height)
//                cellNode.position = CGPoint(x: xyPos.0, y: xyPos.1)
//                //cellNode.name = "\(i)x\(j)"
//                sceneGrid.append((node: cellNode, x: i, y: j))
//                background.addChild(cellNode)
//                //print("\(i),\(j) : \(x),\(y)")
////                x += cellSize
//            }
//
//        }
    } //end createGameBoard
    
    override func update(_ currentTime: TimeInterval) {
        game.timeUpdate(time: currentTime)
    }
    
    func resetMenu() {
        print("RESET MENU")
        currentScore.run(SKAction.scale(to: 2, duration: 0.3)) {
            self.currentScore.run(SKAction.move(to: CGPoint(x: 0, y: 275 / 2), duration: 0.3))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.currentScore.run(SKAction.scale(to: 0, duration: 0.3)) {
                self.currentScore.isHidden = true
//                self.timerLabel.isHidden = true
//                self.timerLabel.run(SKAction.scale(to: 0, duration: 0.3))
                self.timerBar.isHidden = true
                self.timerBar.run(SKAction.scale(to: 0, duration: 0.3))
                
                self.background.run(SKAction.scale(to: 0, duration: 0.4)) {
                self.background.isHidden = true
                self.logo.isHidden = false
                    self.currentScore.run(SKAction.move(to: CGPoint(x: 0, y: (self.frame.size.height / -2) + 65), duration: 0.3))
                self.logo.run(SKAction.move(to: CGPoint(x: 0, y: (self.frame.size.height / 2) - 200), duration: 0.3)) {
                    self.playButton.isHidden = false
                    self.playButtonBG.isHidden = false
                    self.playButton.run(SKAction.scale(to: 1, duration: 0.3))
                    self.playButtonBG.run(SKAction.scale(to: 1, duration: 0.3))
                
            }
        }
        
        
//                self.bestScore.run(SKAction.move(to: CGPoint(x: 0, y: self.scene.gameLogo.position.y - 50), duration: 0.3))
            }
        }
    }
    
}
