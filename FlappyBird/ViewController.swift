//
//  ViewController.swift
//  FlappyBird
//
//  Created by MTBS049 on 2024/05/31.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    var scene:GameScene!

    override func viewDidLoad() {
        super.viewDidLoad()

       
        // SKViewに型を変換する
        let skView = self.view as! SKView

        // FPSを表示する
        skView.showsFPS = true

        // ノードの数を表示する
        skView.showsNodeCount = true
        
        // ビューと同じサイズでシーンを作成する
         scene = GameScene(size:skView.frame.size)

       // if let scene = scene {
            // ビューにシーンを表示する
            skView.presentScene(scene)
        //}
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown(_:)))
           swipeDown.direction = .down
           self.view.addGestureRecognizer(swipeDown)

    }
    @objc func handleSwipeDown(_ sender: UISwipeGestureRecognizer) {
          // 下向きのスワイプジェスチャが認識されたときに実行するアクション
        if let gameScene = scene {
            gameScene.handleSwipeDown()
          }
      }
    
    // ステータスバーを消す --- ここから ---
   override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
}




