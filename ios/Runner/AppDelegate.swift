import UIKit
import Flutter
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        if #available(iOS 15.0, *){
            let displayLink = CADisplayLink(target: self, selector: #selector(step))
            displayLink.preferredFrameRateRange=CAFrameRateRange(minimum: 80, maximum: 120, preferred: 120)
            displayLink.add(to: .current, forMode: .default)
        }
        
        FirebaseApp.configure()
        if #available(iOS 10.0, *) {
          UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        }
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    @objc func step(displayLink : CADisplayLink){
        
    }
}
