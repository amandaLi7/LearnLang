//
//  ViewController.swift
//  LearnLang
//
//  Created by Xinyue Amanda Li on 10/31/19.
//  Copyright © 2019 Xinyue Amanda Li. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit

class ViewController: UIViewController, ARSKViewDelegate {

    let model = ImageClassifier()
    
    @IBOutlet weak var sceneView: ARSKView!
    
    var mlpredictiontext: String = ""
    let translationArray: [String: [String]] = ["backpack": ["la mochila", "书包"], "bookcase": ["la estantería", "书架"], "calculator": ["la calculadora", "计算器"], "carpet": ["la alfombra", "地毯"], "clock": ["el reloj", "钟"], "computer": ["la computadora", "计算机"], "curtain:window shade": ["la cortina", "窗帘"], "door": ["la puerta", "门"], "drinking cup": ["el vaso", "杯子"], "floor": ["el suelo", "地板"], "lamp": ["la lámpara", "灯"], "notebook": ["el cuaderno", "笔记本"], "paper": ["el papel", "纸"], "pencil": ["el lápiz", "铅笔"], "phone": ["el teléfono", "电话"], "shoe": ["los zapatos", "鞋子"], "wall": ["la pared", "墙"], "watch": ["el reloj", "手表"], "water bottle": ["la botella de agua", "水瓶"]]
    var engSpanOrChinese: Int = 0 //0 - English, 1 - Spanish, 2 - Chinese
    let languages = ["English", "Spanish", "Chinese"]
    
    @IBOutlet weak var languagePicker: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        sceneView.delegate = self
    
        if let scene = SKScene(fileNamed: "Scene") {
            sceneView.presentScene(scene)
        }
        
        //languagePicker = UISegmentedControl(items: languages)
        //languagePicker.addTarget(self, action: #selector(languageChosen), for: .valueChanged)
        self.view.addSubview(languagePicker)
        sceneView.bringSubviewToFront(languagePicker)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(gestureRecognize:)))
        view.addGestureRecognizer(tapGesture)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        sceneView.session.run(configuration)
    }
    
    @IBAction func languageChosen(_ sender: Any) {
        switch languagePicker.selectedSegmentIndex
        {
        case 0:
            engSpanOrChinese = 0;
            break
        case 1:
            engSpanOrChinese = 1;
            break
        case 2:
            engSpanOrChinese = 2;
            break
        default:
            engSpanOrChinese = 0;
            break
        }
    }
    
    
    @objc func handleTap(gestureRecognize: UITapGestureRecognizer) -> SKNode?{
        // HIT TEST : REAL WORLD
        // Get Screen Centre
        let spriteNode = SKLabelNode(text: "")
        spriteNode.fontColor = UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1)
        spriteNode.fontName = "Helvetica-Bold"
        spriteNode.isUserInteractionEnabled = true
        let pixbuff: CVPixelBuffer? = sceneView.session.currentFrame?.capturedImage
        if pixbuff != nil {
            getPredictionFromModel(cvbuffer: pixbuff!)
            spriteNode.text = "\(mlpredictiontext)"
            if mlpredictiontext == "curtain:window shade"{
                let audio = SKAction.playSoundFileNamed("curtain,window shade.m4a", waitForCompletion: false)
                spriteNode.run(audio)

            } else {
                let audio = SKAction.playSoundFileNamed("\(mlpredictiontext).m4a", waitForCompletion: false)
                spriteNode.run(audio)

            }
            spriteNode.horizontalAlignmentMode = .center
            spriteNode.verticalAlignmentMode = .center
        } else {
            spriteNode.text = "FAILED!"
            spriteNode.horizontalAlignmentMode = .center
            spriteNode.verticalAlignmentMode = .center
        }
        return spriteNode
    }
    
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        // Create and configure a node for the anchor added to the view's session.
        let spriteNode = SKLabelNode(text: "")
        spriteNode.fontColor = UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1)
        spriteNode.fontName = "Helvetica-Bold"
        spriteNode.isUserInteractionEnabled = true
        let pixbuff: CVPixelBuffer? = sceneView.session.currentFrame?.capturedImage
        if pixbuff != nil {
            getPredictionFromModel(cvbuffer: pixbuff!)
            spriteNode.text = "\(mlpredictiontext)"
            if mlpredictiontext == "curtain:window shade"{
                let audio = SKAction.playSoundFileNamed("curtain,window shade.m4a", waitForCompletion: false)
                spriteNode.run(audio)

            } else {
                let audio = SKAction.playSoundFileNamed("\(mlpredictiontext).m4a", waitForCompletion: false)
                spriteNode.run(audio)

            }
            spriteNode.horizontalAlignmentMode = .center
            spriteNode.verticalAlignmentMode = .center
        } else {
            spriteNode.text = "FAILED!"
            spriteNode.horizontalAlignmentMode = .center
            spriteNode.verticalAlignmentMode = .center
        }
        return spriteNode
    }
    
    func getPredictionFromModel(cvbuffer: CVPixelBuffer?){
        do {
            let object = try model.prediction(image: cvbuffer!)
            let objInEng = object.classLabel
            
            if engSpanOrChinese == 1{
                //in spanish
                for key in translationArray.keys{
                    if key == objInEng{
                        mlpredictiontext = translationArray[key]![0]
                    }
                }
            } else if engSpanOrChinese == 2{
                //in chinese
                for key in translationArray.keys{
                    if key == objInEng{
                        mlpredictiontext = translationArray[key]![1]
                    }
                }
            } else if engSpanOrChinese == 0{
                mlpredictiontext = objInEng
            }
        } catch {
            print(error)
        }
    }

}

/*public class Scene: SKScene {
    
    public override required init(size:CGSize) {
        super.init(size:size)
    }
    
    public required init(coder: NSCoder) {
        super.init(coder:coder)!
    }
}*/
