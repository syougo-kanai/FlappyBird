//
//  GameScene.swift
//  FlappyBird
//
//  Created by MTBS049 on 2024/05/31.
//

import SpriteKit

struct Item: Codable {
    var score: Int
    var itemCount: Int
}

class GameScene: SKScene, SKPhysicsContactDelegate /* 追加 */ {

    var stageSpeed:CGFloat = 1
    var birdSpeed:Int = 20
    var gravityPower:Int = -6
    var creteWall:Double = 1
    var brustSpeed:Int = 25
    var wallCount: Int = 0  // 壁の生成数をカウントする変数
    var itemProbability: Int = 0
    
    var scrollNode:SKNode!
    var wallNode:SKNode!
    var bird:SKSpriteNode!    // 追加
    var whiteBirdTexture_A: SKTexture!
    var whiteBirdTexture_B: SKTexture!
    var birdTextures: [SKTexture]!
    var whiteBirdTextures:[SKTexture]!
    
    var ground:SKSpriteNode!
    let groundTexture = SKTexture(imageNamed: "ground")
    
    // 衝突判定カテゴリー ↓追加
    let birdCategory: UInt32 = 1 << 0       // 0...00001
    let groundCategory: UInt32 = 1 << 1     // 0...00010
    let wallCategory: UInt32 = 1 << 2       // 0...00100
    let scoreCategory: UInt32 = 1 << 3      // 0...01000
    let itemCategory: UInt32 = 1 << 4
    
    enum levelUp {
        case easy
        case nomal
        case hard
        case vHard
        case difficult
        case max
    }
    var level = levelUp.easy
    var levelLabel = "easy"
    // スコア用
    var score = 0  // ←追加
    var itemScore = 0
    var itemBonus = 0
    var scoreOrItems:Bool = true
    

    var scoreLabelNode:SKLabelNode!    // ←追加
    var bestScoreLabelNode:SKLabelNode!    // ←追加
    var levelLabelNode:SKLabelNode!
    var gameOverLabelNode:SKLabelNode!
    var resultLabelNodes: [SKLabelNode] = []
    var levelDisplayLabelNode:SKLabelNode!
    var itemScoreLabelNode:SKLabelNode!
    var bestItemScoreLabelNode:SKLabelNode!
    var bonusLabelNode:SKLabelNode!

    let userDefaults:UserDefaults = UserDefaults.standard
    
    let se = SoundClass()

    // SKView上にシーンが表示されたときに呼ばれるメソッド
    override func didMove(to view: SKView) {
        // 重力を設定
        physicsWorld.gravity = CGVector(dx: 0, dy: self.gravityPower)    // ←追加
        physicsWorld.contactDelegate = self // ←追加

        
        // 背景色を設定
        backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)

        
        // スクロールするスプライトの親ノード
        scrollNode = SKNode()
        addChild(scrollNode)
        // 壁用のノード
        wallNode = SKNode()   // 追加
        scrollNode.addChild(wallNode)   // 追加
        
        // 各種スプライトを生成する処理をメソッドに分割
        setupGround()
        setupCloud()
        setupWall()   // 追加
        setupBird()
        // スコア表示ラベルの設定
              setupScoreLabel()   // 追加
            levelDisplay()
        for i in 0..<5 {
            let labelNode = SKLabelNode(fontNamed:"RoundedMplus1c-Bold")
            labelNode.name = "Node\(i)" // 名前を設定して識別しやすくする
            resultLabelNodes.append(labelNode)
            self.se.playBackgroundMusic(filename: "forest ambience.mp3")
        }
    }
    func setupGround() {
        // 地面の画像を読み込む
        
        groundTexture.filteringMode = .nearest
        
        // 必要な枚数を計算
        let needNumber = Int(self.frame.size.width / groundTexture.size().width) + 2
        
        // スクロールするアクションを作成
        // 左方向に画像一枚分スクロールさせるアクション
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 5)
        
        // 元の位置に戻すアクション
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
        
        // 左にスクロール->元の位置->左にスクロールと無限に繰り返すアクション
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround, resetGround]))
        
        // groundのスプライトを配置する
        for i in 0..<needNumber {
           // let sprite
            ground = SKSpriteNode(texture: groundTexture)
            ground.name = "ground"
            // スプライトの表示する位置を指定する
            ground.position = CGPoint(
                x: groundTexture.size().width / 2  + groundTexture.size().width * CGFloat(i),
                y: groundTexture.size().height / 2
            )
            
            // スプライトにアクションを設定する
            ground.run(repeatScrollGround)
            
            // スプライトに物理体を設定する
            ground.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())   // ←追加
            ground.physicsBody?.categoryBitMask = self.groundCategory
            // 衝突の時に動かないように設定する
            ground.physicsBody?.isDynamic = false   // ←追加

            
            // スプライトを追加する
            scrollNode.addChild(ground)
        }
    }
    func setupCloud() {
        // 雲の画像を読み込む
        let cloudTexture = SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = .nearest
        
        // 必要な枚数を計算
        let needCloudNumber = Int(self.frame.size.width / cloudTexture.size().width) + 2

        // スクロールするアクションを作成
        // 左方向に画像一枚分スクロールさせるアクション
        let moveCloud = SKAction.moveBy(x: -cloudTexture.size().width, y: 0, duration: 2)
        // 元の位置に戻すアクション
        let resetCloud = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0)
        
        // 左にスクロール->元の位置->左にスクロールと無限に繰り返すアクション
        let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud, resetCloud]))
        
        // スプライトを配置する
        for i in 0..<needCloudNumber {
            let sprite = SKSpriteNode(texture: cloudTexture)
            sprite.zPosition = -100 // 一番後ろになるようにする
            
            // スプライトの表示する位置を指定する
            sprite.position = CGPoint(
                x: cloudTexture.size().width / 2 + cloudTexture.size().width * CGFloat(i),
                y: self.size.height - cloudTexture.size().height / 2
            )
            
            // スプライトにアニメーションを設定する
            sprite.run(repeatScrollCloud)

            // スプライトを追加する
            scrollNode.addChild(sprite)
        }
    }
    func setupWall() {
        // 壁の画像を読み込む
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = .linear
        
        // 移動する距離を計算
        let movingDistance = self.frame.size.width + wallTexture.size().width
        
        // 画面外まで移動するアクションを作成
        let moveWall = SKAction.moveBy(x: -movingDistance, y: 0, duration:2)
        
        // 自身を取り除くアクションを作成
        let removeWall = SKAction.removeFromParent()
        
        // 2つのアニメーションを順に実行するアクションを作成
        let wallAnimation = SKAction.sequence([moveWall, removeWall])
        
        // 鳥の画像サイズを取得
        let birdSize = SKTexture(imageNamed: "bird_a").size()
        
        // 鳥が通り抜ける隙間の大きさを鳥のサイズの4倍とする
        let slit_length = birdSize.height * 4
        
        // 隙間位置の上下の振れ幅を60ptとする
        let random_y_range: CGFloat = 70
        let random_item_upper_range: CGFloat = 130
        let random_item_under_range: CGFloat = 20
        
        // 空の中央位置(y座標)を取得
        let groundSize = SKTexture(imageNamed: "ground").size()
        let sky_center_y = groundSize.height + (self.frame.size.height - groundSize.height) / 2
        
        // 空の中央位置を基準にして下側の壁の中央位置を取得
        let under_wall_center_y = sky_center_y - slit_length / 2 - wallTexture.size().height / 2
        
        // 壁を生成するアクションを作成
        let createWallAnimation = SKAction.run({
            // 壁をまとめるノードを作成
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width / 2, y: 0)
            wall.zPosition = -50 // 雲より手前、地面より奥
            
            // 下側の壁の中央位置にランダム値を足して、下側の壁の表示位置を決定する
            let random_y = CGFloat.random(in: -random_y_range...random_y_range)
            let under_wall_y = under_wall_center_y + random_y
            
            // 下側の壁を作成
            let under = SKSpriteNode(texture: wallTexture)
            under.position = CGPoint(x: 0, y: under_wall_y)
            
            // 下側の壁に物理体を設定する
             under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())    // ←追加
            under.physicsBody?.categoryBitMask = self.wallCategory
            under.physicsBody?.isDynamic = false    // ←追加

            
            // 壁をまとめるノードに下側の壁を追加
            wall.addChild(under)
            
            // 上側の壁を作成
            let upper = SKSpriteNode(texture: wallTexture)
            upper.position = CGPoint(x: 0, y: under_wall_y + wallTexture.size().height + slit_length)
            upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())    // ←追加
            upper.physicsBody?.categoryBitMask = self.wallCategory
                    upper.physicsBody?.isDynamic = false    // ←追加
            
            self.wallCount += 1
            var itemDrop = Int.random(in:0...self.itemProbability)
                  // 10個おきにアイテムを生成
            if self.wallCount % 11 == 5 || itemDrop == 3 || itemDrop == 5 {
           // if itemDrop == 3 || itemDrop == 5 {
                      // アイテムを作成
                      let itemTexture = SKTexture(imageNamed: "item_icon")
                      let item = SKSpriteNode(texture: itemTexture)
                      let randomItemPosition = CGFloat.random(in: random_item_under_range...random_item_upper_range)
                            item.position = CGPoint(x: 0, y: under_wall_y + wallTexture.size().height / 2 + randomItemPosition)
                            
                      // アイテムに物理体を設定
                      item.physicsBody = SKPhysicsBody(circleOfRadius: item.size.height / 2)
                      item.physicsBody?.categoryBitMask = self.itemCategory
                      item.physicsBody?.isDynamic = false
                      
                      // 壁をまとめるノードにアイテムを追加
                      wall.addChild(item)
                  }
        print(itemDrop)
            // --- ここから ---
                      // スコアカウント用の透明な壁を作成
                      let scoreNode = SKNode()
                      scoreNode.position = CGPoint(x: upper.size.width + birdSize.width / 2, y: self.frame.height / 2)

                      // 透明な壁に物理体を設定する
                      scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
                      scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
                      scoreNode.physicsBody?.isDynamic = false

                      // 壁をまとめるノードに透明な壁を追加
                      wall.addChild(scoreNode)
            
            // 壁をまとめるノードに上側の壁を追加
            wall.addChild(upper)
            
            // 壁をまとめるノードにアニメーションを設定
            wall.run(wallAnimation)
            
            // 壁を表示するノードに今回作成した壁を追加
            self.wallNode.addChild(wall)
        })
        
        // 次の壁作成までの時間待ちのアクションを作成
        let waitAnimation = SKAction.wait(forDuration: self.creteWall)
        
        if level != .easy{
            let wait = SKAction.wait(forDuration: 3.0)
            
            // 壁を作成->時間待ち->壁を作成を無限に繰り返すアクションを作成
            let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))
            
            let levelChangeAction = SKAction.sequence([wait,repeatForeverAnimation])
            
            // // 壁を表示するノードに壁の作成を無限に繰り返すアクションを設定
            wallNode.run(levelChangeAction, withKey: "ForeverAnimation")
        }else{
            // 壁を作成->時間待ち->壁を作成を無限に繰り返すアクションを作成
            let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))
            
            // // 壁を表示するノードに壁の作成を無限に繰り返すアクションを設定
            wallNode.run(repeatForeverAnimation, withKey: "ForeverAnimation")
        }
    }
    func setupBird() {
        // 鳥の画像を2種類読み込む
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = .linear
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = .linear
        whiteBirdTexture_A = SKTexture(imageNamed: "white_bird_A")
        whiteBirdTexture_A.filteringMode = .linear
        whiteBirdTexture_B = SKTexture(imageNamed: "white_bird_B")
        whiteBirdTexture_B.filteringMode = .linear
        
        birdTextures = [birdTextureA,birdTextureB]
        whiteBirdTextures = [whiteBirdTexture_A,whiteBirdTexture_B]
        
        // 2種類のテクスチャを交互に変更するアニメーションを作成
        let texturesAnimation = SKAction.animate(with: birdTextures, timePerFrame: 0.2)
        let flap = SKAction.repeatForever(texturesAnimation)
        
        // スプライトを作成
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        // 物理体を設定
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)    // ←追加
        // カテゴリー設定
        bird.physicsBody?.categoryBitMask = birdCategory    // ←追加
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory    // ←追加
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory |  scoreCategory | itemCategory   // ←追加
        
        // 衝突した時に回転させない
        bird.physicsBody?.allowsRotation = false    // ←追加
        
        // アニメーションを設定
        bird.run(flap)
        
        // スプライトを追加する
        addChild(bird)
    }
    func flashWhiteScreen(withColor color:UIColor) {
     
        let whiteNode = SKSpriteNode(color: color, size: self.size)
        whiteNode.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        whiteNode.zPosition = 100 // 最前面に表示する
        whiteNode.alpha = 0 // 最初は透明にする

        // シーンに追加
        self.addChild(whiteNode)

        // フェードインアクション
        let fadeIn = SKAction.fadeIn(withDuration: 0.1) // 0.1秒でフェードイン
        // フェードアウトアクション
        let fadeOut = SKAction.fadeOut(withDuration: 0.1) // 0.1秒でフェードアウト
        // アクションが完了したらノードを削除するアクション
        let remove = SKAction.removeFromParent()
        // シーケンスアクション
        let sequence = SKAction.sequence([fadeIn, fadeOut, remove])

        // 白いノードにアクションを実行
        whiteNode.run(sequence)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 鳥の速度をゼロにする
        if scrollNode.speed > 0 {
            bird.physicsBody?.velocity = CGVector.zero
            bird.physicsBody?.velocity = CGVector.init(dx: 0, dy: self.birdSpeed)
            // 鳥に縦方向の力を与える
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: self.birdSpeed))
        //    print("up")
        }else if bird.speed == 0 { // --- ここから ---
            restart()
        } // --- ここまで追加 ---
    }
    func handleSwipeDown() {
        // 下向きのスワイプが検出されたときに実行するアクションをここに記述
        print("Swipe down detected!")
        // 例: 鳥に縦方向の力を与える
        bird.physicsBody?.velocity = CGVector.zero
        print(scrollNode.speed)
        bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -15))
        //scrollNode.speed = stageSpeed
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // ゲームオーバーのときは何もしない
        if scrollNode.speed <= 0 {
            return
        }
        let contactA = contact.bodyA
        let contactB = contact.bodyB
        
      //  if (contactB.categoryBitMask & birdCategory) != 0 && (contactA.categoryBitMask & itemCategory) != 0 {
     if (contactB.categoryBitMask & itemCategory) == itemCategory {
            if let itemNode = contactB.node {
                // アイテムを削除
                itemNode.removeFromParent()
                print("itemScoreUp")
                itemScore += 1
                itemBonus += 1
                print("nextBonus\(itemBonus)")
                if itemBonus == 5 {
                    score += 5
                    itemBonus = 0
                    self.scoreLabelNode.text = "Score:\(score)"
                    self.bonusDisplay()
                }
                self.itemScoreLabelNode.text = "Get Item:\(itemScore)"    // ←追加
                self.bestScore(score: score)
                if level != .max{
                    self.se.playSoundEffectMusic(filename: "_ mac chime.mp3")
                }
            }
      //  } else if (contactB.categoryBitMask & birdCategory) != 0 && (contactA.categoryBitMask & itemCategory) != 0 {
        } else if (contactA.categoryBitMask & itemCategory) == itemCategory {
            if let itemNode = contactA.node {
                // アイテムを削除
                itemNode.removeFromParent()
                print("itemScoreUp")
                itemScore += 1
                itemBonus += 1
                print("nextBonus\(itemBonus)")
                if itemBonus == 5 {
                    score += 5
                    itemBonus = 0
                    self.scoreLabelNode.text = "Score:\(score)"
                    self.bonusDisplay()
                }
                self.itemScoreLabelNode.text = "Get Item:\(itemScore)"    // ←追加
                self.bestScore(score: score)
                if level != .max{
                    self.se.playSoundEffectMusic(filename: "_ mac chime.mp3")
                }
            }
    }else if (contactA.categoryBitMask & scoreCategory) == scoreCategory || (contactB.categoryBitMask & scoreCategory) == scoreCategory {
            // スコアカウント用の透明な壁と衝突した
         //   print("ScoreUp")
            score += 1
            self.scoreLabelNode.text = "Score:\(score)"    // ←追加
            // ベストスコア更新か確認する -- ここから ---
            self.bestScore(score: score)
        }else{
            
            self.updateNumbers(with: score,itemsScore: itemScore)
            
            // 壁か地面と衝突した
            print("GameOver")
            self.resetStartLabel()
            self.setupGameOver()
            // スクロールを停止させる
            scrollNode.speed = 0
            // 衝突後は地面と反発するのみとする(リスタートするまで壁と反発させない)
            bird.physicsBody?.collisionBitMask = groundCategory
            // 鳥が衝突した時の高さを元に、鳥が地面に落ちるまでの秒数(概算)+1を計算
            let duration = bird.position.y / 400.0 + 1.0
            // 指定秒数分、鳥をくるくる回転させる(回転速度は1秒に1周)
            let roll = SKAction.rotate(byAngle: 2.0 * Double.pi * duration, duration: duration)
            let brust = Int(duration)*(self.brustSpeed)
                self.creteWall = 1
            bird.run(roll, completion:{
                // 回転が終わったら鳥の動きを止める
                self.bird.speed = 0
                // 鳥の速度をゼロにする
                self.bird.physicsBody?.velocity = CGVector.zero
                // 鳥に縦方向の力を与える
                self.bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: brust))
                // すべての ground ノードの物理ボディを削除する
                self.scrollNode.enumerateChildNodes(withName: "ground", using: { (node, stop) in
                    node.physicsBody = nil
                })
            })
        }
    }
    
    //ベストスコアの更新、レベルアップの判定
    func bestScore(score:Int){
        var bestScore = userDefaults.integer(forKey: "BEST")
        if score > bestScore {
            bestScore = score
            bestScoreLabelNode.text = "Best Score:\(bestScore)"    // ←追加
            userDefaults.set(bestScore, forKey: "BEST")
        } // --- ここまで追加---
     
        print(score)
        //print(itemScore)
        if score >= 10 && level == .easy {
            print("levelup")
            print(level)
            self.level = .nomal
            print(level)
        }else if score >= 30 && level == .nomal {
            self.level = .hard
        }else if score >= 65 && level == .hard {
            self.level = .vHard
        }else if score >= 100 && level == .vHard {
            self.level = .difficult
        }
        
        if score >= 10 && level == .nomal || score >= 30 && level == .hard || score >= 65 && level == .vHard || score >= 100 && level == .difficult {
            switch level {
            case .nomal:
                backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)
                levelLabel = "nomal"
                self.stageSpeed = 1.3
                self.birdSpeed = 23
                self.gravityPower = -9
                self.creteWall = 1.2
                self.brustSpeed = 30
                itemProbability = 20
                print("nomal")
                self.se.playSoundEffectMusic(filename: "Cuckoo Clock Sound.mp3")
                self.se.stopBackgroundMusic()
                self.se.playBackgroundMusic(filename: "forest ambience.mp3")
                level = .hard
            case .hard:
                backgroundColor = UIColor(red: 0.85, green: 0.35, blue: 0.10, alpha: 1)
                levelLabel = "hard"
                self.stageSpeed = 1.6
                self.birdSpeed = 26
                self.gravityPower = -12
                self.creteWall = 1.4
                self.brustSpeed = 45
                itemProbability = 15
                print("hard")
                self.se.playSoundEffectMusic(filename: "Cuckoo Clock Sound.mp3")
                self.se.stopBackgroundMusic()
                self.se.playBackgroundMusic(filename: "forest ambience.mp3")
                level = .vHard
            case .vHard:
                backgroundColor = UIColor(red: 0.55, green: 0.35, blue: 0.30, alpha: 1)
                levelLabel = "veryhard"
                self.stageSpeed = 1.9
                self.birdSpeed = 29
                self.gravityPower = -14
                self.creteWall = 1.6
                self.brustSpeed = 60
                itemProbability = 10
                print("veryhard")
                bird.removeAllActions()
                let newTexturesAnimation = SKAction.animate(with: whiteBirdTextures, timePerFrame: 0.2)
                let flap = SKAction.repeatForever(newTexturesAnimation)
                bird.run(flap)
                self.se.stopBackgroundMusic()
                self.se.playBackgroundMusic(filename: "Shopping Mall, snack.mp3")
                level = .difficult
            case .difficult:
                backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1)
                levelLabel = "difficult"
                self.stageSpeed = 2.2
             //   scrollNode.speed = self.stageSpeed
                self.birdSpeed = 32
                self.gravityPower = -16
             //   flashWhiteScreen(withColor: .black)
             //   wallNode.removeAllActions()
                self.creteWall = 1.8
             //   self.setupWall()
                self.brustSpeed = 75
                itemProbability = 5
                scoreLabelNode.fontColor = .red
                bestScoreLabelNode.fontColor = .red
                levelLabelNode.fontColor = .red
                itemScoreLabelNode.fontColor = .red
                print("difficult")
              //  self.se.stopBackgroundMusic()
                self.se.playBackgroundMusic(filename: "morse code.mp3")
                level = .max
            case .easy , .max:
                break
            }
            scrollNode.speed = self.stageSpeed
            flashWhiteScreen(withColor: .black)
            wallNode.removeAllActions()
            self.setupWall()
            self.levelDisplay()
            bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
            print(bird.position)
            // bird.physicsBody?.velocity = CGVector.zero
            // 全ての壁を取りのぞく
            wallNode.removeAllChildren()
            physicsWorld.gravity = CGVector(dx: 0, dy: self.gravityPower)
            print("LevelUP")
            self.levelLabelNode.text =  "Level:\(levelLabel)"
        }
    }
    
    func resetPhysicsBodies() {
        // scrollNodeのすべての子ノードを列挙
        scrollNode.enumerateChildNodes(withName: "ground", using: { (node, stop) in
            // groundTextureのサイズに基づいて新しい物理ボディを設定
            if let groundNode = node as? SKSpriteNode {
                groundNode.physicsBody = SKPhysicsBody(rectangleOf: groundNode.size)
                groundNode.physicsBody?.isDynamic = false
                groundNode.physicsBody?.categoryBitMask = self.groundCategory
            }
        })
    }
    func restart() {
           // スコアを0にする
           score = 0
        itemBonus = 0
        self.scoreOrItems = true
        self.scoreLabelNode.text = "Score:\(score)"    // ←追加
           // 鳥を初期位置に戻し、壁と地面の両方に反発するように戻す
           bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
           bird.physicsBody?.velocity = CGVector.zero
           bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
           bird.zRotation = 0

        self.se.stopBackgroundMusic()
        self.se.playBackgroundMusic(filename: "forest ambience.mp3")
           // 全ての壁を取り除く
           wallNode.removeAllChildren()
        self.resetResultLabel()
        self.setupScoreLabel()
        self.birdSpeed = 20
        self.gravityPower = -6
        self.creteWall = 1
        level = .easy
        levelLabel = "easy"
        self.levelLabelNode.text = "Level:\(levelLabel)"
        self.levelDisplay()
        wallNode.removeAllActions()
        self.creteWall = 1
        self.wallCount = 0
        self.setupWall()
           // 鳥の羽ばたきを戻す
           bird.speed = 1
        itemProbability = 0
        physicsWorld.gravity = CGVector(dx: 0, dy: self.gravityPower)
        self.resetPhysicsBodies()
        backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)
        self.scoreLabelNode.fontColor = .black
        self.bestScoreLabelNode.fontColor = .black
        self.levelLabelNode.fontColor = .black
        self.itemScoreLabelNode.fontColor = .black
        let newTexturesAnimation = SKAction.animate(with: birdTextures, timePerFrame: 0.2)
        let flap = SKAction.repeatForever(newTexturesAnimation)
        bird.run(flap)
           // スクロールを再開させる
           scrollNode.speed = 1
       }
    
    func saveItems(_ items: [Item]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(items) {
            UserDefaults.standard.set(encoded, forKey: "items")
        }
    }

    func loadItems() -> [Item] {
        if let savedItems = UserDefaults.standard.object(forKey: "items") as? Data {
            let decoder = JSONDecoder()
            if let loadedItems = try? decoder.decode([Item].self, from: savedItems) {
                return loadedItems
            }
        }
        return []
    }
    
    func updateNumbers(with newScore: Int, itemsScore: Int) {
        var items = loadItems()

        let newItem = Item(score: newScore, itemCount: itemsScore)
print("grthdfvjmvk")
        guard !items.isEmpty else {
            items.append(newItem)
            saveItems(items)
            return
        }
        let minItem = items.min(by: { $0.score < $1.score })
        if  newItem.score > minItem!.score {
            
                if let minIndex = items.firstIndex(where: { $0.score == minItem!.score }) {
                items[minIndex] = newItem
            }
        }else if newScore == minItem!.score {
            if newItem.itemCount > minItem!.itemCount {
                if let minIndex = items.firstIndex(where: { $0.score == minItem!.score }) {
                    items[minIndex] = newItem
                    
                }
            }
        }

        if items.count < 5 {
            items.append(newItem)
        }

        saveItems(items)
    }
    
    func setupScoreLabel() {
         // スコア表示を作成
         score = 0
         scoreLabelNode = SKLabelNode(fontNamed:"RoundedMplus1c-Bold")
         scoreLabelNode.fontColor = UIColor.black
         scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 75)
         scoreLabelNode.zPosition = 100 // 一番手前に表示する
         scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
       //  scoreLabelNode.fontName = "CustomFont-Bold" // カスタムフォントの名前を指定
         scoreLabelNode.text = "Score:999"
         self.addChild(scoreLabelNode)
        
        itemScore = 0
        itemScoreLabelNode = SKLabelNode(fontNamed:"RoundedMplus1c-Bold")
        itemScoreLabelNode.fontColor = UIColor.black
        itemScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 105)
        itemScoreLabelNode.zPosition = 100 // 一番手前に表示する
        itemScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
      // itemScoreLabelNode.fontName = "CustomFont-Bold" // カスタムフォントの名前を指定
        itemScoreLabelNode.text = "Get Item:\(itemScore)"
        self.addChild(itemScoreLabelNode)

         // ベストスコア表示を作成
         let bestScore = userDefaults.integer(forKey: "BEST")
         bestScoreLabelNode = SKLabelNode(fontNamed:"RoundedMplus1c-Bold")
         bestScoreLabelNode.fontColor = UIColor.black
         bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 135)
         bestScoreLabelNode.zPosition = 100 // 一番手前に表示する
         bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
     //    bestScoreLabelNode.fontName = "CustomFont-Bold" // カスタムフォントの名前を指定
         bestScoreLabelNode.text = "Best Score:\(bestScore)"
         self.addChild(bestScoreLabelNode)
        
        // 現在のレベル表示を作成
        levelLabelNode = SKLabelNode(fontNamed:"RoundedMplus1c-Bold")
        levelLabelNode.fontColor = UIColor.black
        levelLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 165)
        levelLabelNode.zPosition = 100
        levelLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
      //  levelLabelNode.fontName = "CustomFont-Bold" // カスタムフォントの名前を指定
        levelLabelNode.text = "Level:\(levelLabel)"
        self.addChild(levelLabelNode)
     }
    func setupGameOver(){
        let xCenter = self.frame.size.width/2
        // 現在のレベル表示を作成
        gameOverLabelNode = SKLabelNode(fontNamed:"RoundedMplus1c-Bold")
        gameOverLabelNode.fontColor = UIColor.black
        gameOverLabelNode.position = CGPoint(x: xCenter, y: self.frame.size.height - 120)
        gameOverLabelNode.zPosition = 100
        gameOverLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
       // gameOverLabelNode.fontName = "CustomFont-Bold" // カスタムフォントの名前を指定
        if level == .max{
            gameOverLabelNode.fontColor = .red
        }else {
            gameOverLabelNode.fontColor = .black
        }
        gameOverLabelNode.text = "GANE OVER"
        gameOverLabelNode.fontSize = 50
        self.addChild(gameOverLabelNode)
        
        
        scoreLabelNode = SKLabelNode(fontNamed:"RoundedMplus1c-Bold")
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.position = CGPoint(x: xCenter, y: self.frame.size.height - 160)
        scoreLabelNode.zPosition = 100 // 一番手前に表示する
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
     // scoreLabelNode.fontName = "CustomFont-Bold" // カスタムフォントの名前を指定
        scoreLabelNode.fontSize = 40
        scoreLabelNode.text = "Your Score:\(score)"
        if level == .max{
            scoreLabelNode.fontColor = .red
        }else {
            scoreLabelNode.fontColor = .black
        }
        self.addChild(scoreLabelNode)
        
        itemScoreLabelNode = SKLabelNode(fontNamed:"RoundedMplus1c-Bold")
        itemScoreLabelNode.fontColor = UIColor.black
        itemScoreLabelNode.position = CGPoint(x: xCenter, y: self.frame.size.height - 210)
        itemScoreLabelNode.zPosition = 100
        itemScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
      //  itemScoreLabelNode.fontName = "CustomFont-Bold" // カスタムフォントの名前を指定
        itemScoreLabelNode.fontSize = 40
        if level == .max{
            itemScoreLabelNode.fontColor = .red
        }else {
            itemScoreLabelNode.fontColor = .black
        }
        itemScoreLabelNode.text = "Get Item:\(itemScore)"
       
        self.addChild(itemScoreLabelNode)
        
        // 現在のレベル表示を作成
        levelLabelNode = SKLabelNode(fontNamed:"RoundedMplus1c-Bold")
        levelLabelNode.fontColor = UIColor.black
        levelLabelNode.position = CGPoint(x: xCenter, y: self.frame.size.height - 260)
        levelLabelNode.zPosition = 100
        levelLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
       // levelLabelNode.fontName = "CustomFont-Bold" // カスタムフォントの名前を指定
        levelLabelNode.fontSize = 40
        levelLabelNode.text = "Level:\(levelLabel)"
        if level == .max{
            levelLabelNode.fontColor = .red
        }else {
            levelLabelNode.fontColor = .black
        }
        self.addChild(levelLabelNode)
        
        var rankingScore = loadItems()
        //rankingScore.sort {$0[0] > $1[0]}
        rankingScore.sort {
            if $0.score == $1.score {
                return $0.itemCount > $1.itemCount
            }
            return $0.score > $1.score
        }
        
        
        print(rankingScore)
        let rankingOfset:CGFloat = 50
        for i in 0..<rankingScore.count {
            resultLabelNodes[i].fontColor = UIColor.black
            resultLabelNodes[i].position = CGPoint(x: xCenter, y: self.frame.size.height - 320 - rankingOfset * CGFloat(i))
            resultLabelNodes[i].zPosition = 100
            resultLabelNodes[i].horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
            resultLabelNodes[i].fontSize = 50
            resultLabelNodes[i].text = "\(i + 1)位:\(rankingScore[i].score)/\(rankingScore[i].itemCount)"
            if level == .max{
                resultLabelNodes[i].fontColor = .red
            }
            self.addChild(resultLabelNodes[i])
        }
    }
    
    func levelDisplay(){
        // 現在のレベル表示を作成
        levelDisplayLabelNode = SKLabelNode(fontNamed:"RoundedMplus1c-Bold")
        levelDisplayLabelNode.fontColor = UIColor.black
        levelDisplayLabelNode.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        levelDisplayLabelNode.zPosition = 100
        levelDisplayLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
      //  levelDisplayLabelNode.fontName = "CustomFont-Bold" // カスタムフォントの名前を指定
        levelDisplayLabelNode.fontSize = 40
        levelDisplayLabelNode.text = "\(levelLabel)"
        levelDisplayLabelNode.alpha = 0
        if level == .max{
            levelDisplayLabelNode.fontColor = .red
        }else {
            levelDisplayLabelNode.fontColor = .black
        }
        self.addChild(levelDisplayLabelNode)
        
        // フェードインアクション
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
         // 一定時間待機
         let wait = SKAction.wait(forDuration: 1.0)
         // フェードアウトアクション
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
         
         let delet = SKAction.removeFromParent()
         // シーケンスアクション
         let sequence = SKAction.sequence([fadeIn, wait, fadeOut,delet])
         
         // ラベルノードにアクションを実行
        levelDisplayLabelNode.run(sequence)
    }
    
    func bonusDisplay(){
        // 現在のレベル表示を作成
        bonusLabelNode = SKLabelNode(fontNamed:"RoundedMplus1c-Bold")
        bonusLabelNode.fontColor = UIColor.black
        bonusLabelNode.position = CGPoint(x: self.bird.position.x, y: self.bird.position.y)
        bonusLabelNode.zPosition = 100
        bonusLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
      // カスタムフォントの名前を指定
        bonusLabelNode.fontSize = 25
        bonusLabelNode.text = "Bonus+5"
        bonusLabelNode.alpha = 0
        if level == .max{
            bonusLabelNode.fontColor = .red
        }else {
            bonusLabelNode.fontColor = .black
        }
        self.addChild(bonusLabelNode)
        
        // フェードインアクション
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
         // 一定時間待機
         let wait = SKAction.wait(forDuration: 1.0)
         // フェードアウトアクション
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
         
         let delet = SKAction.removeFromParent()
         // シーケンスアクション
         let sequence = SKAction.sequence([fadeIn, wait, fadeOut,delet])
         
         // ラベルノードにアクションを実行
        bonusLabelNode.run(sequence)
    }
  
    func resetStartLabel(){
        scoreLabelNode.removeFromParent()
        bestScoreLabelNode.removeFromParent()
        levelLabelNode.removeFromParent()
        itemScoreLabelNode.removeFromParent()
    }
    func resetResultLabel(){
        scoreLabelNode.removeFromParent()
        levelLabelNode.removeFromParent()
        gameOverLabelNode.removeFromParent()
        itemScoreLabelNode.removeFromParent()
        for i in 0..<resultLabelNodes.count{
            resultLabelNodes[i].removeFromParent()
        }
    }

}
