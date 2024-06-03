//
//  ViewController.swift
//  yamanashi-ar
//
//  Created by Kyoya Yamaguchi on 2023/11/30.
//

import UIKit
import ARKit
import ARCore
import SceneKit.ModelIO
import SafariServices

class ViewController: UIViewController, ARSessionDelegate {
    @IBOutlet var scnView: ARSCNView!
    var arSession: ARSession!
    var scene: SCNScene!
    
    var garSessionManager: GARSessionManager!
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        //oldest
//        garSessionManager = GARSessionManager(scene: scene, presetAnchors: [
//            AnchorData(
//                location: CLLocationCoordinate2DMake(35.66679084934921, 138.57183915187446),
//                altitude: 2,
//                heading: 90,
//                siteInfo: SiteInfo(iconType: .restaurant, name: "Pizzeria Siro Kofu", rating: 4.8)
//            ),
//            AnchorData(
//                location: CLLocationCoordinate2DMake(35.666753260132616, 138.57179556597717),
//                altitude: 2,
//                heading: 90,
//                siteInfo: SiteInfo(iconType: .japanesefood, name: "Japanese Dining RYU", rating: 4.3)
//            ),
//            AnchorData(
//                location: CLLocationCoordinate2DMake(35.66681972221472, 138.57161921073836),
//                altitude: 2,
//                heading: 90,
//                siteInfo: SiteInfo(iconType: .museum, name: "Yamanashi Wine Tasting", rating: 4.5)
//            ),
//            AnchorData(
//                location: CLLocationCoordinate2DMake(35.666784856867054, 138.571609823007),
//                altitude: 2,
//                heading: 90,
//                siteInfo: SiteInfo(iconType: .museum, name: "Yamanashi Wine Tasting", rating: 4.5)
//            ),
//            AnchorData(
//                location: CLLocationCoordinate2DMake(35.666760342160366, 138.5717633794697),
//                altitude: 2,
//                heading: 90,
//                siteInfo: SiteInfo(iconType: .clothes, name: "Outdoor Clothing", rating: 5.0)
//            ),
//            AnchorData(
//                location: CLLocationCoordinate2DMake(35.666776685299, 138.5716802309921 ),
//                altitude: 2,
//                heading: 90,
//                siteInfo: SiteInfo(iconType: .cafe, name: "Coffee Stand Kofu", rating: 2.3)
//            ),
//            AnchorData(
//                location: CLLocationCoordinate2DMake(35.666742909475474, 138.57182775248464),
//                altitude: 2,
//                heading: 90,
//                siteInfo: SiteInfo(iconType: .gift, name: "Shingenmochi Shop", rating: 4.8)
//            ),
//
//            AnchorData(
//                location: CLLocationCoordinate2DMake(35.666727924902766, 138.57174494031102),
//                altitude: 2,
//                heading: 90,
//                siteInfo: SiteInfo(iconType: .gift, name: "Jewelry Shop Saito", rating: 3.8)
//            ),
//        ])
        //full
//        garSessionManager = GARSessionManager(scene: scene, presetAnchors: [
//            AnchorData(
//                location: CLLocationCoordinate2DMake(35.66679084934921, 138.57183915187446),
//                altitude: 2,
//                heading: 90,
//                siteInfo: SiteInfo(iconType: .restaurant, name: "Pizzeria Siro Kofu", rating: 4.8, object: .pizza)
//            ),
//            AnchorData(
//                location: CLLocationCoordinate2DMake(35.666753260132616, 138.57179556597717),
//                altitude: 2,
//                heading: 90,
//                siteInfo: SiteInfo(iconType: .japanesefood, name: "Japanese Dining KUU", rating: 4.3, object: .houtou)
//            ),
//            AnchorData(
//                location: CLLocationCoordinate2DMake(35.66681972221472, 138.57161921073836),
//                altitude: 2,
//                heading: 90,
//                siteInfo: SiteInfo(iconType: .museum, name: "Yamanashi Wine Tasting", rating: 4.5, object: .wine)
//            ),
//            AnchorData(
//                location: CLLocationCoordinate2DMake(35.666784856867054, 138.571609823007),
//                altitude: 2,
//                heading: 90,
//                siteInfo: SiteInfo(iconType: .museum, name: "Yamanashi Wine Tasting", rating: 4.5, object: .wine)
//            ),
//            AnchorData(
//                location: CLLocationCoordinate2DMake(35.666760342160366, 138.5717633794697),
//                altitude: 2,
//                heading: 90,
//                siteInfo: SiteInfo(iconType: .clothes, name: "Japanese Clothing", rating: 3.0, object: .wine)
//            ),
//            AnchorData(
//                location: CLLocationCoordinate2DMake(35.666776685299, 138.5716802309921 ),
//                altitude: 2,
//                heading: 90,
//                siteInfo: SiteInfo(iconType: .cafe, name: "Coffee Stand Kofu", rating: 4.8, object: .coffee)
//            ),
//            AnchorData(
//                location: CLLocationCoordinate2DMake(35.666742909475474, 138.57182775248464),
//                altitude: 2,
//                heading: 90,
//                siteInfo: SiteInfo(iconType: .gift, name: "Shingenmochi Shop", rating: 4.0)
//            ),
//
//            AnchorData(
//                location: CLLocationCoordinate2DMake(35.666727924902766, 138.57174494031102),
//                altitude: 2,
//                heading: 90,
//                siteInfo: SiteInfo(iconType: .gift, name: "Jewelry Shop Saito", rating: 3.8, object: .ring)
//            ),
//        ])
        garSessionManager = GARSessionManager(scene: scene, presetAnchors: [
            AnchorData(
                location: CLLocationCoordinate2DMake(35.66679084934921, 138.57183915187446),
                altitude: 2,
                heading: 90,
                siteInfo: SiteInfo(iconType: .restaurant, name: "Pizzeria Siro Kofu", rating: 4.8)
            ),
            AnchorData(
                location: CLLocationCoordinate2DMake(35.666753260132616, 138.57179556597717),
                altitude: 2,
                heading: 90,
                siteInfo: SiteInfo(iconType: .japanesefood, name: "Japanese Dining KUU", rating: 4.3, object: .houtou)
            ),
            AnchorData(
                location: CLLocationCoordinate2DMake(35.66681972221472, 138.57161921073836),
                altitude: 2,
                heading: 90,
                siteInfo: SiteInfo(iconType: .museum, name: "Yamanashi Wine Tasting", rating: 4.5)
            ),
            AnchorData(
                location: CLLocationCoordinate2DMake(35.666784856867054, 138.571609823007),
                altitude: 2,
                heading: 90,
                siteInfo: SiteInfo(iconType: .museum, name: "Yamanashi Wine Tasting", rating: 4.5)
            ),
            AnchorData(
                location: CLLocationCoordinate2DMake(35.666760342160366, 138.5717633794697),
                altitude: 2,
                heading: 90,
                siteInfo: SiteInfo(iconType: .clothes, name: "Japanese Clothing", rating: 3.0)
            ),
            AnchorData(
                location: CLLocationCoordinate2DMake(35.666776685299, 138.5716802309921 ),
                altitude: 2,
                heading: 90,
                siteInfo: SiteInfo(iconType: .cafe, name: "Coffee Stand Kofu", rating: 4.8, object: .coffee)
            ),
//            AnchorData(
//                location: CLLocationCoordinate2DMake(35.666742909475474, 138.57182775248464),
//                altitude: 2,
//                heading: 90,
//                siteInfo: SiteInfo(iconType: .gift, name: "Shingenmochi Shop", rating: 4.0)
//            ),

//. sa            AnchorData(
//. sa                location: CLLocationCoordinate2DMake(35.666727924902766, 138.57174494031102),
//. sa                altitude: 2,
//. sa                heading: 90,
//. sa                siteInfo: SiteInfo(iconType: .gift, name: "Jewelry Shop Saito", rating: 3.8)
//. sa            ),
        ])
        
        locationManager.delegate = self
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpARSession()
    }
    
    func setupScene() {
        scnView.automaticallyUpdatesLighting = true
        scnView.autoenablesDefaultLighting = true
        scene = scnView.scene
    }
    
    func setUpARSession() {
        arSession = scnView.session
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravity
        configuration.planeDetection = .horizontal
        arSession.delegate = self
        arSession.run(configuration)
    }
    
    func checkLocationPermission() {
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
            garSessionManager.setup()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            print("Location permission denied or restricted.")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let location = touches.first?.location(in: view),
           let firstHitNode = scnView.hitTest(location, options: nil).first?.node {
            print(firstHitNode.name ?? "")
            showDetailView()
        }
    }
    
    func showDetailView() {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        guard let detailView = storyboard.instantiateViewController(identifier: "detailView") as? DetailViewController else { return }
//        if let sheet = detailView.sheetPresentationController {
//            sheet.detents = [.medium()]
//            sheet.largestUndimmedDetentIdentifier = .medium
//            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
//            sheet.prefersEdgeAttachedInCompactHeight = true
//            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
//        }
//        present(detailView, animated: true, completion: nil)
        let url = URL(string: "https://koshuyumekouji.com/en/shop/build_D2_02.html")
        let safariView = SFSafariViewController(url: url!)
        present(safariView, animated: true)
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        garSessionManager.updateFrame(frame: frame)
        if let camera = scnView.pointOfView {
            garSessionManager.markerNodes.forEach {
                $0.value.eulerAngles = camera.eulerAngles
            }
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ locationManager: CLLocationManager) {
        checkLocationPermission()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
