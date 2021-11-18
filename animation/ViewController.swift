import UIKit
import SceneKit
import ARKit
import AVFoundation

class ViewController: UIViewController, ARSCNViewDelegate, AVAudioPlayerDelegate,
                      UIGestureRecognizerDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var panduliPlayer: AVAudioPlayer!
    var salamuriPlayer: AVAudioPlayer!
    var animations = [String: CAAnimation]()
    var idle:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //画面がタップされたことを検知
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapCallback(_:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        initSalamuriPlayer()
        initPanduriPlayer()
        
        // デリゲートを設定
        sceneView.delegate = self
        // シーンを作成して登録
        sceneView.scene = SCNScene()
        // ライトの追加
        sceneView.autoenablesDefaultLighting = true;
        //sceneView内に表示するNodeに無指向性の光を追加するオプションです。
        // 画像認識の参照用画像をアセットから取得
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resource Group", bundle: nil)!
        sceneView.session.run(configuration)
        
        // DAEアニメーションの読み込み
        loadAnimations()
    }
    
    /// サラムリの音声を初期化するメソッド
    func initSalamuriPlayer() {
        // 再生する audio ファイルのパスを取得
        let audioPath2 = Bundle.main.path(forResource: "jojia2", ofType:"mp3")!
        let audioUrl = URL(fileURLWithPath: audioPath2)
        
        // auido を再生するプレイヤーを作成する
        var audioError:NSError?
        do {
            salamuriPlayer = try AVAudioPlayer(contentsOf: audioUrl)
        } catch let error as NSError {
            audioError = error
            salamuriPlayer = nil
        }
        // エラーが起きたとき
        if let error = audioError {
            print("Error \(error.localizedDescription)")
        }
        
        salamuriPlayer.delegate = self
        salamuriPlayer.prepareToPlay()
    }
    /// パンドゥリの音声を初期化するメソッド
    func initPanduriPlayer() {
        // 再生する audio ファイルのパスを取得
        let audioPath = Bundle.main.path(forResource: "jojia", ofType:"mp3")!
        let audioUrl = URL(fileURLWithPath: audioPath)
        // auido を再生するプレイヤーを作成する
        var audioError:NSError?
        do {
            panduliPlayer = try AVAudioPlayer(contentsOf: audioUrl)
        } catch let error as NSError {
            audioError = error
            panduliPlayer = nil
        }
        // エラーが起きたとき
        if let error = audioError {
            print("Error \(error.localizedDescription)")
        }
        panduliPlayer.delegate = self
        panduliPlayer.prepareToPlay()
    }
    @objc private func tapCallback(_ sender: UITapGestureRecognizer) {
        //タップした時にタップした座標を取得する
        let touchPoint = sender.location(in: self.sceneView)
        let results = self.sceneView.hitTest(touchPoint, options: [SCNHitTestOption.searchMode : SCNHitTestSearchMode.all.rawValue])
        //タップされたノードを検出
        if let result = results.last {
            guard let hitNodeName2 = result.node.name else { return }
            guard let targetNode = result.node.parent else { return }
            
            switch hitNodeName2 {
            case "obj_0_マテリアル":
                self.playSalamuri(targetNode: targetNode)
            case "_material_1":
                self.playPanduri(targetNode: targetNode)
            default:
                return
            }
        }
    }
    
    /// パンドゥリを再生するメソッド
    /// もし、サラムリが再生されていたら止める
    func playPanduri(targetNode: SCNNode) {
        print("*** playPanduri() ***")
        
        let actMove = SCNAction.move(by: SCNVector3(0, 0, 0.1), duration: 0.2)
        targetNode.runAction(actMove)
        
        // *** サラムリを止める ***
        if salamuriPlayer.isPlaying {
            salamuriPlayer.stop()
        }
        
        //音楽再生停止
        if ( panduliPlayer.isPlaying ){
            panduliPlayer.stop()
            //button.setTitle("Stop", for: UIControl.State())
        } else{
            panduliPlayer.play()
            //button.setTitle("Play", for: UIControl.State())
        }
    }
    
    /// サラムリを再生するメソッド
    /// もし、パンドゥリが再生されていたら止める
    func playSalamuri(targetNode: SCNNode) {
        print("*** playSaramuri() ***")
        let actMove2 = SCNAction.move(by: SCNVector3(0, 0, 0.1), duration: 0.2)
        targetNode.runAction(actMove2)
        
        // *** パンドゥリを止める ***
        if panduliPlayer.isPlaying {
            panduliPlayer.stop()
        }
        
        //音楽再生停止
        if ( salamuriPlayer.isPlaying ){
            print("audioPlayer.isPlaying")
            salamuriPlayer.stop()
            //button.setTitle("Stop", for: UIControl.State())
        } else{
            print("!audioPlayer.isPlaying")
            salamuriPlayer.play()
            //doli.runAction(SCNAction .repeatForever(SCNAction .rotateBy(x: 0, y: 0.1, z: 0, duration: 1)))
            //button.setTitle("Play", for: UIControl.State())
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 画像認識の参照用画像をアセットから取得
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resource Group", bundle: nil)!
        // ビューのセッションの実行
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // ビューのセッションの一時停止
        sceneView.session.pause()
    }
    
    func loadAnimations () {
        
//        if(anchor.name == "MusicTicket_Panduri") {
//            // scnファイルからシーンを読み込む
//            let scene = SCNScene(named: "art.scnassets/animation/idleFixed.dae")!
//            // シーンからノードを検索
//            let modelNode = (scene.rootNode.childNode(withName: "Cube", recursively: false))!
//            //モデルが回り続ける
////            let rotate = SCNAction.rotateBy(x: 0, y: 1.28, z: 0, duration: 1)
////            modelNode.runAction(SCNAction.repeatForever(rotate))
//            // 検出面の子要素にする
//            modelNode.position = SCNVector3(0, -1, -2)
//            node.addChildNode(modelNode)
//        }
        // idleアニメーションのキャラクターを読み込む
        let idleScene = SCNScene(named: "art.scnassets/animation/idleFixed.dae")!
        // すべてのアニメーションモデルの親となるノード。
        let node = SCNNode()
        // 親ノードにすべての子ノードを追加する
        for child in idleScene.rootNode.childNodes {
            node.addChildNode(child)
        }
        
        // いくつかのプロパティを設定する
        node.position = SCNVector3(0, -1, -2)
        node.scale = SCNVector3(0.2, 0.2, 0.2)
        
        // シーンにノードを追加
        sceneView.scene.rootNode.addChildNode(node)
        
        // すべてのDAEアニメーションの読み込み
        loadAnimation(withKey: "dancing", sceneName: "art.scnassets/animation/DancingFixed", animationIdentifier: "DancingFixed-1")
    }
    
    func loadAnimation(withKey: String, sceneName:String, animationIdentifier:String) {
        let sceneURL = Bundle.main.url(forResource: sceneName, withExtension: "dae")
        let sceneSource = SCNSceneSource(url: sceneURL!, options: nil)
        
        if let animationObject = sceneSource?.entryWithIdentifier(animationIdentifier, withClass: CAAnimation.self) {
            // アニメーションの再生数
            animationObject.repeatCount = 3
            // アニメーション間のスムーズな移行を実現するために
            animationObject.fadeInDuration = CGFloat(1)
            animationObject.fadeOutDuration = CGFloat(0.5)
            
            // アニメーションを保存して後で使用する
            animations[withKey] = animationObject
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: sceneView)
        
        // 3Dオブジェクトがタッチされたかどうか試してみる
        var hitTestOptions = [SCNHitTestOption: Any]()
        hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
        
        let hitResults: [SCNHitTestResult]  = sceneView.hitTest(location, options: hitTestOptions)
        
        if hitResults.first != nil {
            if(idle) {
                playAnimation(key: "dancing")
            } else {
                stopAnimation(key: "dancing")
            }
            idle = !idle
            return
        }
    }
    
    
    func playAnimation(key: String) {
        // アニメーションを追加して、すぐに再生を開始
        sceneView.scene.rootNode.addAnimation(animations[key]!, forKey: key)
    }
    
    func stopAnimation(key: String) {
        // スムーズな切り替えでアニメーションを停止
        sceneView.scene.rootNode.removeAnimation(forKey: key, blendOutDuration: CGFloat(0.5))
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Pユーザーにエラーメッセージを送信する
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // セッションが中断されたことを、オーバーレイで表示するなどして、ユーザーに知らせる。
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // 一貫したトラッキングが必要な場合は、トラッキングをリセットしたり、既存のアンカーを取り除いたりする。
        
    }
    
    // マーカーが検出されたとき呼ばれる
//    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//
//        if(anchor.name == "MusicTicket_Panduri") {
//            // scnファイルからシーンを読み込む
//            let scene = SCNScene(named: "art.scnassets/animation/idleFixed.dae")!
//            // シーンからノードを検索
//            let modelNode = (scene.rootNode.childNode(withName: "Cube", recursively: false))!
//            //モデルが回り続ける
//            let rotate = SCNAction.rotateBy(x: 0, y: 1.28, z: 0, duration: 1)
//            modelNode.runAction(SCNAction.repeatForever(rotate))
//            // 検出面の子要素にする
//            modelNode.position = SCNVector3(0, 0, 0)
//            for child in scene.rootNode.childNodes {
//                node.addChildNode(child)
//            }
//        }
//
//        if(anchor.name == "MusicTicket_Salamuri") {
//            // scnファイルからシーンを読み込む
//            let scene = SCNScene(named: "art.scnassets/saramuri.scn")
//            // シーンからノードを検索
//            let modelNode2 = (scene?.rootNode.childNode(withName: "obj_0_マテリアル", recursively: false))!
//            //モデルが回り続ける
//            let rotate = SCNAction.rotateBy(x: 0, y: 1.28, z: 0, duration: 1)
//            modelNode2.runAction(SCNAction.repeatForever(rotate))
//            // 検出面の子要素にする
//            modelNode2.position = SCNVector3(0, 0, 0)
//            node.addChildNode(modelNode2)
//        }
//
//
//    }
//
    
}
