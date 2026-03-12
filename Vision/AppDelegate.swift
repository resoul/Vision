import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        
        let container = AppDependencyContainer()
        let factory = ModuleFactory(container: container)
        (container.themeManager as? ThemeManager)?.apply(
            (container.themeManager as? ThemeManager)?.theme ?? .dark
        )

        appCoordinator = AppCoordinator(
            window: window,
            factory: factory,
            languageManager: container.languageManager
        )
        appCoordinator?.start()

        return true
    }

    private func startMainFlow() {
        guard let window else { return }

        let container = AppDependencyContainer()
        let factory = ModuleFactory(container: container)
        (container.themeManager as? ThemeManager)?.apply(
            (container.themeManager as? ThemeManager)?.theme ?? .dark
        )

        appCoordinator = AppCoordinator(
            window: window,
            factory: factory,
            languageManager: container.languageManager
        )
        appCoordinator?.start()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        print("applicationWillResignActive", "Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state. Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.", application)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground", "Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.", application)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("applicationWillEnterForeground", "Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.", application)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive", "Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.", application)
    }
}
