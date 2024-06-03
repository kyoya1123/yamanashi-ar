//
//  GARSessionManager.swift
//  yamanashi-ar
//
//  Created by Kyoya Yamaguchi on 2023/12/01.
//

import Foundation
import ARCore
import CoreLocation
import SceneKit
import SwiftUI
    
@MainActor
class GARSessionManager: NSObject {
    
    let apiKey = "AIzaSyABEsbUs-mPQLJ4aS3_7MGBZK_hCPrDBoE"
    
    enum LocalizationState : Int {
        case pretracking = 0
        case localizing = 1
        case localized = 2
        case failed = -1
    }
    
    var garSession: GARSession!
    var localizationState: LocalizationState = .failed
    var lastStartLocalizationDate: Date!
    var restoredPresetAnchors: Bool = false
    var markerNodes: [UUID : SCNNode] = [:]
    var siteInfoDict: [UUID : SiteInfo] = [:]
    var scene: SCNScene!
    var presetAnchors: [AnchorData]!
    
    init(scene: SCNScene, presetAnchors: [AnchorData]) {
        self.scene = scene
        self.presetAnchors = presetAnchors
    }
    
    func setup() {
        do {
            garSession = try GARSession(apiKey: apiKey, bundleIdentifier: "com.kyoya.yamanashi-ar")
        } catch {
            print("Failed to create GARSession（GARSessionの作成に失敗しました）: \(error.localizedDescription)")
            return
        }
        
        var error: NSError? = nil
        let configuration = GARSessionConfiguration()
        configuration.geospatialMode = .enabled
        garSession.setConfiguration(configuration, error: &error)
        if let error = error {
            print("Failed to configure GARSession（GARSessionの設定に失敗しました）: \(error.code)")
        }
        localizationState = .pretracking
        lastStartLocalizationDate = Date()
    }
    
    func updateLocalizationState(_ garFrame: GARFrame) {
        let geospatialTransform = garFrame.earth!.cameraGeospatialTransform
        let now = Date()
        
        if garFrame.earth?.earthState != .enabled {
            localizationState = .failed
        } else if garFrame.earth?.trackingState != .tracking {
            localizationState = .pretracking
        } else {
            if localizationState == .pretracking {
                localizationState = .localizing
            } else if localizationState == .localizing {
                if geospatialTransform != nil
                    && geospatialTransform!.horizontalAccuracy <= 10
                    && geospatialTransform!.headingAccuracy <= 15 {
                    localizationState = .localized
                    if !restoredPresetAnchors {
                        addPresetAnchors()
                        restoredPresetAnchors = true
                    }
                } else if now.timeIntervalSince(lastStartLocalizationDate) >= 3 * 60.0 {
                    localizationState = .failed
                }
            } else {
                if geospatialTransform == nil
                    || geospatialTransform!.horizontalAccuracy > 20
                    || geospatialTransform!.headingAccuracy > 25 {
                    localizationState = .localizing
                    lastStartLocalizationDate = now
                }
            }
        }
    }
    
    func updateMarkerNodes(_ garFrame: GARFrame) {
        var currentAnchorIDs: Set<UUID> = []
        
        for anchor in garFrame.anchors {
            if anchor.trackingState != .tracking {
                continue
            }
            var node = markerNodes[anchor.identifier]
            if node == nil {
                if anchor.terrainState == .success || anchor.terrainState == .none {
                    let siteInfo = siteInfoDict[anchor.identifier]!
                    node = markerNode(siteInfo: siteInfo)
                    if let additionalNode = siteInfo.object?.node {
                        additionalNode.position = node!.position
                        additionalNode.position.y -= 0.7
                        node?.addChildNode(additionalNode)
                    }
                    markerNodes[anchor.identifier] = node
                    scene.rootNode.addChildNode(node!)
                }
            }
            guard let node = node else { return }
            node.simdTransform.columns.3 = anchor.transform.columns.3
//            node.isHidden = localizationState != .localized
            currentAnchorIDs.insert(anchor.identifier)
        }
        
//        for anchorID in markerNodes.keys {
//            if !currentAnchorIDs.contains(anchorID) {
//                guard let node = markerNodes[anchorID] else { continue }
//                node.removeFromParentNode()
//                markerNodes.removeValue(forKey: anchorID)
//            }
//        }
    }
    
    func markerNode(siteInfo: SiteInfo) -> SCNNode {
        let renderer = ImageRenderer(content: PopUpView(siteInfo: siteInfo))
        renderer.scale = 3
        let image = renderer.uiImage!
        let widthRatio = image.size.width / image.size.height
        let height = 0.5
        let plane = SCNPlane(width: height * widthRatio, height: height)
        plane.firstMaterial?.diffuse.contents = image
        return SCNNode(geometry: plane)
        //        guard let url = Bundle.main.url(forResource: "ramen", withExtension: "usdc") else { fatalError() }
        //        let scene = try! SCNScene(url: url, options: [.checkConsistency: true])
        //        return scene.rootNode
        //        let box = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        //        box.firstMaterial?.diffuse.contents = UIColor.blue
        //        return SCNNode(geometry: box)
    }
    
    func wineNode() -> SCNNode {
        guard let url = Bundle.main.url(forResource: "wine", withExtension: "usdc") else { fatalError() }
        let scene = try! SCNScene(url: url, options: [.checkConsistency: true])
        let node = scene.rootNode
        node.scale = SCNVector3(2, 2, 2)
        let action = SCNAction.rotateBy(x: 0, y: CGFloat(GLKMathDegreesToRadians(360)), z: 0, duration: 8)
        let forever = SCNAction.repeatForever(action)
        node.runAction(forever)
        return node
    }
    
    func pizzaNode() -> SCNNode {
        guard let url = Bundle.main.url(forResource: "pizza", withExtension: "usdz") else { fatalError() }
        let scene = try! SCNScene(url: url, options: [.checkConsistency: true])
        let node = scene.rootNode
        node.scale = SCNVector3(0.01, 0.01, 0.01)
        node.eulerAngles.x -= 0.4
        let action = SCNAction.rotateBy(x: 0, y: CGFloat(GLKMathDegreesToRadians(360)), z: 0, duration: 8)
        let forever = SCNAction.repeatForever(action)
        node.runAction(forever)
        return node
    }
    
    func addAnchor(anchorData: AnchorData) {
        // 3Dモデルの矢印はZ軸を指し、ヘディングは北から時計回りに計測されます。
        let angle = .pi / 180 * (180 - Float(anchorData.heading))
        let eastUpSouthQAnchor = simd_quaternion(angle, 0, 1, 0)
        do {
            let anchor = try garSession.createAnchorOnTerrain(
                coordinate: anchorData.location,
                altitudeAboveTerrain: anchorData.altitude,
                eastUpSouthQAnchor: eastUpSouthQAnchor
            )
            siteInfoDict[anchor.identifier] = anchorData.siteInfo
        } catch {
            print("Error adding anchor（追加エラー）: \(error.localizedDescription)")
        }
    }
    
    func updateFrame(frame: ARFrame) {
        guard garSession != nil, localizationState != .failed else { return }
        guard let garFrame = try? garSession.update(frame) else { return }
        updateLocalizationState(garFrame)
        updateMarkerNodes(garFrame)
    }
    
    func addPresetAnchors() {
        presetAnchors.forEach { anchorData in
            addAnchor(anchorData: anchorData)
        }
    }
}

struct AnchorData {
    var location: CLLocationCoordinate2D
    var altitude: Double
    var heading: Double
    var siteInfo: SiteInfo
}

enum SiteObject: String {
    case wine
    case houtou
    case pizza
    case coffee
    case geta
    case ring
    case sushi
    
    var node: SCNNode {
        guard let url = Bundle.main.url(forResource: self.rawValue, withExtension: fileExtension) else { fatalError() }
        let scene = try! SCNScene(url: url, options: [.checkConsistency: true])
        var node = scene.rootNode
        switch self {
        case .wine:
            node.scale = SCNVector3(2, 2, 2)
        case .houtou:
            node.scale = SCNVector3(0.3, 0.3, 0.3)
            node.eulerAngles.x += 6
        case .pizza:
            node.scale = SCNVector3(0.01, 0.01, 0.01)
            node.eulerAngles.x -= 0.4
        case .coffee:
            node.scale = SCNVector3(0.03, 0.03, 0.03)
        case .geta:
            node.scale = SCNVector3(0.01, 0.01, 0.01)
            node.eulerAngles.x -= 0.6
        case .ring:
            node.scale = SCNVector3(0.0003, 0.0003, 0.0003)
            node.eulerAngles.x += 1
        case .sushi:
            node.scale = SCNVector3(0.03, 0.03, 0.03)
            node.eulerAngles.x -= 0.4
        }
        let action = SCNAction.rotateBy(x: 0, y: CGFloat(GLKMathDegreesToRadians(360)), z: 0, duration: 8)
        let forever = SCNAction.repeatForever(action)
        node.runAction(forever)
        return node
    }
    
    var fileExtension: String {
        switch self {
        case .wine:
            "usdc"
        default:
            "usdz"
        }
    }
}
